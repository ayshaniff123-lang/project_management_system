import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/project.dart';
import 'add_project_page.dart';
import '../pages/role_selection.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
                  MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
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
          if (projects.isEmpty) return const Center(child: Text('No projects yet'));

          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(p.abstract ?? ''),
                  trailing: Text(p.projectType ?? '', style: const TextStyle(color: Colors.blue)),
                  onTap: () {},
                ),
              );
            },
          );
        },
      ),
      // ONLY show the add button if the user is NOT a teacher
      floatingActionButton: _loadingRole || _isTeacher 
          ? null 
          : FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddProjectPage()),
              ),
            ),
    );
  }
}