import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project.dart';
import 'dart:typed_data';


class SupabaseService {
  static late final SupabaseClient client;

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

    client = Supabase.instance.client;
  }

  // ===============================
  // AUTH
  // ===============================
  static User? get currentUser => client.auth.currentUser;

  static Future<AuthResponse> signUp(String email, String password) async {
    return await client.auth.signUp(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
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
      await client.from('users').insert({
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

  static Future<bool> isTeacher() async {
    final user = currentUser;
    if (user == null) return false;

    try {
      final data = await client
          .from('users')
          .select('role')
          .eq('id', user.id)
          .single();

      final role = data['role'];
      return role.toString().toLowerCase() == 'teacher';
    } catch (e) {
      print('isTeacher error: $e');
      return false;
    }
  }

  // ===============================
  // PROJECTS
  // ===============================
  static Stream<List<Project>> projectsStream() {
    return client
        .from('projects')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map(
                (row) =>
                    Project.fromMap(Map<String, dynamic>.from(row)),
              )
              .toList(),
        );
  }

  static Future<List<Project>> fetchProjects() async {
    try {
      final data = await client
          .from('projects')
          .select()
          .order('created_at', ascending: false);

      return (data as List)
          .map(
            (e) => Project.fromMap(Map<String, dynamic>.from(e)),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch projects: $e');
    }
  }

  static Future<bool> insertProject(
    Project project, {
    String? guideId,
    String? studentId,
  }) async {
    try {
      final user = currentUser;
      final payload = project.toMap();

      if (guideId != null) {
        payload['guide_id'] = guideId;
      } else if (user != null) {
        payload['guide_id'] = user.id;
      }

      if (studentId != null) {
        payload['student_id'] = studentId;
      }

      await client.from('projects').insert(payload);
      return true;
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
  Uint8List bytes, // ✅ FIXED
) async {
  try {
    await client.storage.from(bucket).uploadBinary(path, bytes);
    return client.storage.from(bucket).getPublicUrl(path);
  } catch (e) {
    print('uploadFile error: $e');
    return null;
  }
}

}