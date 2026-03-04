# Supabase RLS Policy Changes Required

## Summary
Based on the simplified role structure (Student → Read-only, Faculty → Full CRUD), the following RLS policies need to be updated in Supabase.

## Current Database Schema
```sql
-- Users table
CREATE TABLE public.users (
  id uuid PRIMARY KEY,
  name text,
  role public.user_role,
  department text,
  project_level public.project_level
);

-- Projects table
CREATE TABLE public.projects (
  id uuid PRIMARY KEY,
  title text NOT NULL,
  abstract text,
  domain text,
  project_type text CHECK (project_type IN ('mini', 'major')),
  guide_name text,
  team_members text[],
  contact_email text,
  contact_phone text,
  github_link text,
  year integer,
  extension_possible boolean DEFAULT false,
  created_at timestamp DEFAULT now(),
  student_id uuid REFERENCES users(id),
  guide_id uuid REFERENCES users(id),
  domain_id uuid REFERENCES domains(id)
);

-- Domains table
CREATE TABLE public.domains (
  id uuid PRIMARY KEY,
  domain_name text UNIQUE NOT NULL
);
```

## RLS Policies to Update/Create

### 1. **PROJECTS Table Policies**

#### A. Students - Read-Only (SELECT)
```sql
CREATE POLICY "Students can read projects"
ON public.projects
FOR SELECT
USING (auth.role() = 'authenticated' AND 
       EXISTS (SELECT 1 FROM public.users 
               WHERE users.id = auth.uid() AND users.role = 'student'))
```

#### B. Faculty - INSERT
```sql
CREATE POLICY "Faculty can insert projects"
ON public.projects
FOR INSERT
WITH CHECK (auth.role() = 'authenticated' AND 
            EXISTS (SELECT 1 FROM public.users 
                    WHERE users.id = auth.uid() AND users.role = 'faculty'))
```

#### C. Faculty - UPDATE
```sql
CREATE POLICY "Faculty can update projects"
ON public.projects
FOR UPDATE
USING (auth.role() = 'authenticated' AND 
       EXISTS (SELECT 1 FROM public.users 
               WHERE users.id = auth.uid() AND users.role = 'faculty'))
WITH CHECK (auth.role() = 'authenticated' AND 
            EXISTS (SELECT 1 FROM public.users 
                    WHERE users.id = auth.uid() AND users.role = 'faculty'))
```

#### D. Faculty - DELETE
```sql
CREATE POLICY "Faculty can delete projects"
ON public.projects
FOR DELETE
USING (auth.role() = 'authenticated' AND 
       EXISTS (SELECT 1 FROM public.users 
               WHERE users.id = auth.uid() AND users.role = 'faculty'))
```

#### E. Public READ (Optional - if you want non-authenticated users to view)
```sql
CREATE POLICY "Public can read projects"
ON public.projects
FOR SELECT
USING (true)
```

### 2. **DOMAINS Table Policies**

#### A. authenticated users can read domains
```sql
CREATE POLICY "Authenticated users can read domains"
ON public.domains
FOR SELECT
USING (auth.role() = 'authenticated')
```

#### B. Public read (Optional)
```sql
CREATE POLICY "Public can read domains"
ON public.domains
FOR SELECT
USING (true)
```

### 3. **USERS Table Policies**

#### A. Users can view all profiles
```sql
CREATE POLICY "Users can view all profiles"
ON public.users
FOR SELECT
USING (true)
```

#### B. Users can insert their own profile
```sql
CREATE POLICY "Users can insert their own profile"
ON public.users
FOR INSERT
WITH CHECK (id = auth.uid())
```

#### C. Users can update their own profile
```sql
CREATE POLICY "Users can update their own profile"
ON public.users
FOR UPDATE
USING (id = auth.uid())
WITH CHECK (id = auth.uid())
```

## Important Implementation Notes

### Faculty Account Creation
- **Faculty cannot self-register** through the app
- Faculty accounts must be created directly via Supabase (manually or via backend API)
- When creating faculty accounts:
  1. Add user in Auth section
  2. In `users` table, set `role = 'faculty'`

### Student Account Creation
- Students CAN signup through the app
- The app automatically creates their profile with `role = 'student'`

### Role Values
Ensure the `user_role` enum (or check constraint) contains:
- `'student'`
- `'faculty'`
- Remove or deprecate: `'teacher'`, `'admin'`

## Steps to Apply Changes in Supabase Dashboard

1. **Go to Authentication > Users section**
   - Create faculty accounts manually (one-time setup)
   - Set password for each faculty member
   - Faculty uses these credentials to sign in

2. **Go to SQL Editor**
   - Drop existing conflicting policies (search for "teacher", "admin" policies)
   - Run the policy creation SQL scripts above

3. **Test the policies**
   - Login as student → should see projects (read-only)
   - Login as faculty → should see all CRUD operations available
   - Verify students cannot see Add, Edit, Delete buttons

## Key Differences from Previous Setup

| Operation | Students | Faculty |
|-----------|----------|---------|
| Read Projects | ✅ Yes | ✅ Yes |
| Create Projects | ❌ No | ✅ Yes |
| Edit Projects | ❌ No | ✅ Yes |
| Delete Projects | ❌ No | ✅ Yes |
| Self-Register | ✅ Yes | ❌ No (Admin only) |
| Sign In | ✅ Yes | ✅ Yes |

