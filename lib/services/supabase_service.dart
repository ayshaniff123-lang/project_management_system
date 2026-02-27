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
  // Add this guard clause at the very top
  if (Supabase.instance.client.supabaseUrl.isNotEmpty) {
    return; // Already initialized, don't do it again
  }

  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  if (url.isEmpty || anonKey.isEmpty) {
    throw Exception('SUPABASE_URL or SUPABASE_ANON_KEY not found in .env');
  }

  await Supabase.initialize(
    url: url,
    anonKey: anonKey,
  );
}

  // ===============================
  // AUTH
  // ===============================
  static User? get currentUser => _client.auth.currentUser;

  static Future<AuthResponse> signUp(String email, String password) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
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

  /// Inserts a [Project] into Supabase.
  /// [guideId]   → UUID of the guide user (optional, overrides project.guideId)
  /// [studentId] → UUID of the student (defaults to currently logged-in user)
  /// [domainId]  → UUID from domains table (optional, overrides project.domainId)
  static Future<bool> insertProject(
    Project project, {
    String? guideId,
    String? studentId,
    String? domainId,
  }) async {
    try {
      // Validate project_type against DB check constraint
      if (project.projectType != 'mini' && project.projectType != 'major') {
        print("insertProject error: project_type must be 'mini' or 'major'");
        return false;
      }

      final user = currentUser;
      if (user == null) {
        print('insertProject error: no authenticated user');
        return false;
      }

      // Start from model's toMap()
      final Map<String, dynamic> payload = project.toMap();

      // FK: student_id — default to logged-in user if not provided
      payload['student_id'] = studentId ?? project.studentId ?? user.id;

      // FK: guide_id — override if provided
      if (guideId != null) payload['guide_id'] = guideId;

      // FK: domain_id — override if provided
      if (domainId != null) payload['domain_id'] = domainId;

      // Sanitize: replace empty strings with null to avoid DB constraint issues
      payload.updateAll((key, value) {
        if (value is String && value.trim().isEmpty) return null;
        return value;
      });

      await _client.from('projects').insert(payload);

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
    // Update this to include 'faculty' or 'teacher' based on your preference
    return role == 'teacher' || role == 'faculty';
  } catch (e) {
    return false;
  }
}
}

