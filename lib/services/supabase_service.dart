import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import 'dart:typed_data';

class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ===============================
  // INIT
  // ===============================
  static Future<void> init() async {
    final url = dotenv.env['SUPABASE_URL'] ?? '';
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    if (url.isEmpty || anonKey.isEmpty) {
      throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env');
    }

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
    );
    print("Supabase initialized");
  }

  // ===============================
  // AUTH
  // ===============================
  static User? get currentUser => _client.auth.currentUser;

  /// Sign up user
  static Future<User?> signUp(String email, String password) async {
    try {
      final AuthResponse res = await _client.auth.signUp(
        email: email,
        password: password,
      );
      if (res.user != null) {
        print("Signup successful: ${res.user!.email}");
        return res.user;
      } else {
        print("Signup failed: ${res.session?.accessToken ?? 'No session'}");
        return null;
      }
    } catch (e) {
      print("Signup error: $e");
      return null;
    }
  }

  /// Sign in user
  static Future<User?> signIn(String email, String password) async {
    try {
      final AuthResponse res = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (res.user != null) {
        print("Login successful: ${res.user!.email}");
        return res.user;
      } else {
        print("Login failed: ${res.session?.accessToken ?? 'No session'}");
        return null;
      }
    } catch (e) {
      print("Login error: $e");
      return null;
    }
  }

  /// Sign out user
  static Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      print("User signed out");
    } catch (e) {
      print("Sign out error: $e");
    }
  }

  // ===============================
  // USERS / PROFILE
  // ===============================
  static Future<bool> createProfile({
    required String id,
    String? name,
    String? role,
    String? department,
    String? projectLevel,
  }) async {
    try {
      await _client.from('users').insert({
        'id': id,
        if (name != null) 'name': name,
        if (role != null) 'role': role,
        if (department != null) 'department': department,
        if (projectLevel != null) 'project_level': projectLevel,
      });
      return true;
    } catch (e) {
      print('createProfile error: $e');
      return false;
    }
  }

  // ===============================
  // PROJECTS
  // ===============================
  static Stream<List<Project>> projectsStream() {
    return _client
        .from('projects')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows
            .map((row) => Project.fromMap(Map<String, dynamic>.from(row)))
            .toList());
  }

  static Future<List<Project>> fetchProjects() async {
    try {
      final data = await _client
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map((e) => Project.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  /// Inserts a project (only teachers/faculty can insert)
  static Future<bool> insertProject(
    Project project, {
    String? guideId,
    String? studentId,
    String? domainId,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        print('insertProject error: no authenticated user');
        return false;
      }

      // Check if user is a teacher/faculty
      final isTeacher = await SupabaseService.isTeacher();
      if (!isTeacher) {
        print('insertProject error: only teachers/faculty can add projects');
        return false;
      }

      // Validate project_type
      if (project.projectType != 'mini' && project.projectType != 'major') {
        print("insertProject error: project_type must be 'mini' or 'major'");
        return false;
      }

      final Map<String, dynamic> payload = project.toMap();

      // Only assign student_id if provided
      payload['student_id'] = studentId ?? project.studentId;

      // Assign guide_id if provided
      if (guideId != null) payload['guide_id'] = guideId;

      // Assign domain_id if provided
      if (domainId != null) payload['domain_id'] = domainId;

      // Sanitize empty strings
      payload.updateAll((key, value) {
        if (value is String && value.trim().isEmpty) return null;
        return value;
      });

      await _client.from('projects').insert(payload);
      print("Project inserted successfully");
      return true;
    } on PostgrestException catch (e) {
      print('insertProject PostgrestException → ${e.code}: ${e.message}');
      return false;
    } catch (e) {
      print('insertProject error: $e');
      return false;
    }
  }

  // ===============================
  // STORAGE
  // ===============================
  static Future<String?> uploadFile(
    String bucket,
    String path,
    Uint8List bytes,
  ) async {
    try {
      await _client.storage.from(bucket).uploadBinary(path, bytes);
      return _client.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      print('uploadFile error: $e');
      return null;
    }
  }

  /// Updates an existing project (only the logged-in faculty can update)
  static Future<bool> updateProject(Project project) async {
    try {
      if (project.id == null) {
        print('updateProject error: project id is required');
        return false;
      }

      final user = currentUser;
      if (user == null) {
        print('updateProject error: no authenticated user');
        return false;
      }

      // Check if user is faculty
      final isFaculty = await SupabaseService.isFaculty();
      if (!isFaculty) {
        print('updateProject error: only faculty can update projects');
        return false;
      }

      // Validate project_type
      if (project.projectType != 'mini' && project.projectType != 'major') {
        print("updateProject error: project_type must be 'mini' or 'major'");
        return false;
      }

      final Map<String, dynamic> payload = project.toMap();

      // Sanitize empty strings
      payload.updateAll((key, value) {
        if (value is String && value.trim().isEmpty) return null;
        return value;
      });

      await _client
          .from('projects')
          .update(payload)
          .eq('id', project.id!);

      print("Project updated successfully");
      return true;
    } on PostgrestException catch (e) {
      print('updateProject PostgrestException → ${e.code}: ${e.message}');
      return false;
    } catch (e) {
      print('updateProject error: $e');
      return false;
    }
  }

  /// Deletes a project (only faculty can delete)
  static Future<bool> deleteProject(String projectId) async {
    try {
      if (projectId.isEmpty) {
        print('deleteProject error: project id is required');
        return false;
      }

      final user = currentUser;
      if (user == null) {
        print('deleteProject error: no authenticated user');
        return false;
      }

      // Check if user is faculty
      final isFaculty = await SupabaseService.isFaculty();
      if (!isFaculty) {
        print('deleteProject error: only faculty can delete projects');
        return false;
      }

      await _client.from('projects').delete().eq('id', projectId);

      print("Project deleted successfully");
      return true;
    } on PostgrestException catch (e) {
      print('deleteProject PostgrestException → ${e.code}: ${e.message}');
      return false;
    } catch (e) {
      print('deleteProject error: $e');
      return false;
    }
  }

  // ===============================
  // ROLE CHECK
  // ===============================
  static Future<bool> isTeacher() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final data = await _client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = (data['role'] as String?)?.toLowerCase();
      return role == 'teacher' || role == 'faculty';
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isFaculty() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final data = await _client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = (data['role'] as String?)?.toLowerCase();
      return role == 'faculty';
    } catch (e) {
      return false;
    }
  }
}