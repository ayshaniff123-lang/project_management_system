import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/project.dart';
import 'add_project_page.dart';
import 'project_detail_page.dart';
import '../pages/role_selection.dart';

class HomePage extends StatefulWidget {
  final String role;

  const HomePage({super.key, required this.role});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isTeacher = false;
  bool _loadingRole = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final teacherStatus = await SupabaseService.isTeacher();
    if (mounted) {
      setState(() {
        _isTeacher = teacherStatus;
        _loadingRole = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('College Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RoleSelectionPage()),
                );
              }
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Project>>(
        stream: SupabaseService.projectsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final projects = snapshot.data ?? [];

          if (projects.isEmpty) {
            return const Center(child: Text('No projects yet'));
          }

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];
              return Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    p.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(p.abstract ?? ''),
                  trailing: Text(
                    p.projectType,
                    style: const TextStyle(color: Colors.blue),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailPage(project: p),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      // ✅ Show Add button ONLY for teachers
      floatingActionButton: _loadingRole
          ? null
          : _isTeacher
              ? FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const AddProjectPage()),
                    );

                    if (result == true) {
                      setState(() {}); // refresh list
                    }
                  },
                )
              : null,
    );
  }
}