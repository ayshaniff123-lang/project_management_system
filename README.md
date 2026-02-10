# project_management_system

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Quick Setup & Initialization

**Purpose:** A small project-management system for a college where teachers upload project records and students can browse them.

- **Prerequisites:** Flutter SDK, Dart SDK, a Supabase project (create at https://app.supabase.com).
- **Files:** Copy `.env.example` to `.env` and fill `SUPABASE_URL` and `SUPABASE_ANON_KEY` (do not commit `.env`).

**Install packages:**

```bash
flutter pub get
```

**Add `.env` asset for web builds:** `pubspec.yaml` already includes `.env` under `assets` so `flutter_dotenv` can load it on web.

**Initialize at app start:** in `main.dart` do:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/supabase_service.dart';

Future<void> main() async {
	WidgetsFlutterBinding.ensureInitialized();
	await dotenv.load();
	await SupabaseService.init();
	runApp(const MyApp());
}
```

## Supabase configuration (recommended)

- Create a Supabase project and enable the Email/Password provider in Auth.
- Create the `users` and `projects` tables (you may use the existing schema in the workspace as reference).
- Create a storage bucket (e.g. `project-files`) and decide whether files are public or private.

### Minimal Row-Level Security (RLS) policies

Enable RLS on the `projects` and `users` tables and add policies like:

- Allow authenticated users to read `projects`:

```sql
CREATE POLICY "Allow authenticated select on projects" ON public.projects
FOR SELECT USING (auth.role() = 'authenticated');
```

- Allow only teachers to insert/update/delete projects (example uses `users.role`):

```sql
CREATE POLICY "Teachers can insert projects" ON public.projects
FOR INSERT WITH CHECK (
	EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'teacher')
);
CREATE POLICY "Teachers can update projects" ON public.projects
FOR UPDATE USING (
	EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'teacher')
) WITH CHECK (
	EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'teacher')
);
CREATE POLICY "Teachers can delete projects" ON public.projects
FOR DELETE USING (
	EXISTS (SELECT 1 FROM public.users u WHERE u.id = auth.uid() AND u.role = 'teacher')
);
```

- For `users` table, allow authenticated inserts and allow users to update their own profile:

```sql
CREATE POLICY "Allow authenticated insert users" ON public.users
FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Allow authenticated read users" ON public.users
FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Allow users update own profile" ON public.users
FOR UPDATE USING (auth.uid() = id) WITH CHECK (auth.uid() = id);
```

## Current status (what's done)

- **Dependencies added:** `supabase_flutter`, `flutter_dotenv` in `pubspec.yaml`.
- **Service:** `lib/services/supabase_service.dart` updated with initialization, auth helpers, project fetch/stream/insert, and storage upload helper.
- **Model:** `lib/models/project.dart` mapping fixed to always include `title` in `toMap()`.
- **Assets & env:** `.env` declared in `pubspec.yaml` for web; `.env.example` created; `.env` added to `.gitignore`.
- **Git ignore:** root `.gitignore` expanded with common Flutter/IDE ignores.

## Pending / next tasks

- Configure Supabase DB and Storage (create tables, buckets).
- Add/verify RLS policies in Supabase SQL editor and enable RLS on relevant tables.
- Implement authentication UI and call `SupabaseService.signUp` / `signIn` / `createProfile`.
- Wire upload UI and test storage uploads and public/private URL handling.
- Run `flutter pub get` and test on target platforms.

## How I can help next

- I can run `flutter pub get` and report results here.
- I can add an example authentication flow and a simple upload UI.
- I can generate the exact SQL to create the tables and constraints if you want.

---

If you want me to proceed with one of the next tasks, tell me which and I'll continue.
