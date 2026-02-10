import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/project.dart';
import 'add_project_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('College Projects')),
      body: StreamBuilder<List<Project>>(
        stream: SupabaseService.projectsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final projects = snapshot.data ?? [];
          if (projects.isEmpty) return const Center(child: Text('No projects yet'));
          return ListView.builder(
            itemCount: projects.length,
            itemBuilder: (context, i) {
              final p = projects[i];
              return ListTile(
                title: Text(p.title),
                subtitle: Text(p.abstract ?? ''),
                onTap: () {},
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddProjectPage())),
      ),
    );
  }
}
