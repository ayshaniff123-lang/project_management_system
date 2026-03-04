import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/project.dart';
import 'add_project_page.dart';
import 'role_selection.dart';

class FacultyDashboardPage extends StatefulWidget {
  const FacultyDashboardPage({super.key});

  @override
  State<FacultyDashboardPage> createState() => _FacultyDashboardPageState();
}

class _FacultyDashboardPageState extends State<FacultyDashboardPage> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _deleteProject(String projectId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project'),
        content: const Text('Are you sure you want to delete this project?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await SupabaseService.deleteProject(projectId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Project deleted successfully'
                : 'Failed to delete project'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _editProject(Project project) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => EditProjectPage(project: project),
      ),
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Project updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RoleSelectionPage(),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search projects',
                hintText: 'Title, domain, guide name...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Project>>(
              stream: SupabaseService.projectsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                var projects = snapshot.data ?? [];

                // Filter projects by search query
                if (_searchQuery.isNotEmpty) {
                  final query = _searchQuery.toLowerCase();
                  projects = projects
                      .where((p) =>
                          p.title.toLowerCase().contains(query) ||
                          (p.abstract?.toLowerCase().contains(query) ?? false) ||
                          (p.domain?.toLowerCase().contains(query) ?? false) ||
                          (p.guideName?.toLowerCase().contains(query) ?? false))
                      .toList();
                }

                if (projects.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'No projects yet'
                              : 'No projects found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: projects.length,
                  padding: const EdgeInsets.all(8.0),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return ProjectCard(
                      project: project,
                      onEdit: () => _editProject(project),
                      onDelete: () => _deleteProject(project.id!),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Project',
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(builder: (_) => const AddProjectPage()),
          );

          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Project added successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProjectCard({
    required this.project,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title and Type
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    project.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Chip(
                  label: Text(project.projectType.toUpperCase()),
                  backgroundColor: project.projectType == 'major'
                      ? Colors.orange.shade200
                      : Colors.blue.shade200,
                  labelStyle: const TextStyle(fontSize: 11),
                )
              ],
            ),
            const SizedBox(height: 8),
            // Abstract
            if (project.abstract != null && project.abstract!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  project.abstract!,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            // Meta info
            Row(
              children: [
                if (project.domain != null)
                  Expanded(
                    child: Text(
                      '📚 ${project.domain}',
                      style: const TextStyle(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (project.year != null)
                  Expanded(
                    child: Text(
                      '📅 ${project.year}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            if (project.guideName != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  '👨‍🏫 Guide: ${project.guideName}',
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditProjectPage extends StatefulWidget {
  final Project project;

  const EditProjectPage({required this.project, super.key});

  @override
  State<EditProjectPage> createState() => _EditProjectPageState();
}

class _EditProjectPageState extends State<EditProjectPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleCtrl;
  late TextEditingController _abstractCtrl;
  late TextEditingController _domainCtrl;
  late TextEditingController _guideCtrl;
  late TextEditingController _teamCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _githubCtrl;
  late TextEditingController _yearCtrl;

  late String _projectType;
  late bool _extensionPossible;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.project.title);
    _abstractCtrl =
        TextEditingController(text: widget.project.abstract ?? '');
    _domainCtrl = TextEditingController(text: widget.project.domain ?? '');
    _guideCtrl = TextEditingController(text: widget.project.guideName ?? '');
    _teamCtrl = TextEditingController(
        text: widget.project.teamMembers.join(', '));
    _emailCtrl = TextEditingController(text: widget.project.contactEmail ?? '');
    _phoneCtrl = TextEditingController(text: widget.project.contactPhone ?? '');
    _githubCtrl = TextEditingController(text: widget.project.githubLink ?? '');
    _yearCtrl =
        TextEditingController(text: widget.project.year?.toString() ?? '');
    _projectType = widget.project.projectType;
    _extensionPossible = widget.project.extensionPossible;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _abstractCtrl.dispose();
    _domainCtrl.dispose();
    _guideCtrl.dispose();
    _teamCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _githubCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTeamMembers(String raw) {
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  String? _nullIfEmpty(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final updatedProject = Project(
      id: widget.project.id,
      title: _titleCtrl.text.trim(),
      abstract: _nullIfEmpty(_abstractCtrl.text),
      domain: _nullIfEmpty(_domainCtrl.text),
      domainId: widget.project.domainId,
      projectType: _projectType,
      guideName: _nullIfEmpty(_guideCtrl.text),
      guideId: widget.project.guideId,
      studentId: widget.project.studentId,
      teamMembers: _parseTeamMembers(_teamCtrl.text),
      contactEmail: _nullIfEmpty(_emailCtrl.text),
      contactPhone: _nullIfEmpty(_phoneCtrl.text),
      githubLink: _nullIfEmpty(_githubCtrl.text),
      year: int.tryParse(_yearCtrl.text.trim()),
      extensionPossible: _extensionPossible,
    );

    final ok = await SupabaseService.updateProject(updatedProject);

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Update failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Project')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                  labelText: 'Title *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    (val == null || val.trim().isEmpty)
                        ? 'Title is required'
                        : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _abstractCtrl,
                decoration: const InputDecoration(
                  labelText: 'Abstract',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _domainCtrl,
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _projectType,
                decoration: const InputDecoration(
                  labelText: 'Project Type *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'mini', child: Text('Mini')),
                  DropdownMenuItem(value: 'major', child: Text('Major')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _projectType = val);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _guideCtrl,
                decoration: const InputDecoration(
                  labelText: 'Guide Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teamCtrl,
                decoration: const InputDecoration(
                  labelText: 'Team Members (comma separated)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _githubCtrl,
                decoration: const InputDecoration(
                  labelText: 'GitHub Link',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _yearCtrl,
                decoration: const InputDecoration(
                  labelText: 'Year',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val != null && val.trim().isNotEmpty) {
                    if (int.tryParse(val.trim()) == null) {
                      return 'Enter a valid year';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Extension Possible'),
                value: _extensionPossible,
                onChanged: (val) =>
                    setState(() => _extensionPossible = val),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Update', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
