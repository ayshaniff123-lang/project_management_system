import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';

class AddProjectPage extends StatefulWidget {
  /// Optionally pass known FK values from the parent screen
  final String? guideId;
  final String? studentId;
  final String? domainId;

  const AddProjectPage({
    super.key,
    this.guideId,
    this.studentId,
    this.domainId,
  });

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _abstractCtrl = TextEditingController();
  final _domainCtrl = TextEditingController();
  final _guideCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();

  String _projectType = 'mini';
  bool _extensionPossible = false;
  bool _loading = false;

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

    // Build strongly-typed Project — FK ids passed separately to insertProject
    final project = Project(
      title: _titleCtrl.text.trim(),
      abstract: _nullIfEmpty(_abstractCtrl.text),
      domain: _nullIfEmpty(_domainCtrl.text),
      domainId: widget.domainId,           // FK from parent if available
      projectType: _projectType,
      guideName: _nullIfEmpty(_guideCtrl.text),
      guideId: widget.guideId,             // FK from parent if available
      studentId: widget.studentId,         // FK from parent if available
      teamMembers: _parseTeamMembers(_teamCtrl.text),
      contactEmail: _nullIfEmpty(_emailCtrl.text),
      contactPhone: _nullIfEmpty(_phoneCtrl.text),
      githubLink: _nullIfEmpty(_githubCtrl.text),
      year: int.tryParse(_yearCtrl.text.trim()),
      extensionPossible: _extensionPossible,
    );

    final ok = await SupabaseService.insertProject(
      project,
      guideId: widget.guideId,
      studentId: widget.studentId,
      domainId: widget.domainId,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insert failed. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Title — required (NOT NULL in DB)
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

              // Abstract
              TextFormField(
                controller: _abstractCtrl,
                decoration: const InputDecoration(
                  labelText: 'Abstract',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),

              // Domain (text label — not the FK uuid)
              TextFormField(
                controller: _domainCtrl,
                decoration: const InputDecoration(
                  labelText: 'Domain',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Project Type — constrained to mini | major in DB
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
                validator: (val) =>
                    (val != 'mini' && val != 'major')
                        ? 'Select a valid project type'
                        : null,
              ),
              const SizedBox(height: 12),

              // Guide Name (text — guide_id FK handled separately)
              TextFormField(
                controller: _guideCtrl,
                decoration: const InputDecoration(
                  labelText: 'Guide Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Team Members → stored as text[] in DB
              TextFormField(
                controller: _teamCtrl,
                decoration: const InputDecoration(
                  labelText: 'Team Members (comma separated)',
                  hintText: 'Alice, Bob, Charlie',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Contact Email
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),

              // Contact Phone
              TextFormField(
                controller: _phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),

              // GitHub Link
              TextFormField(
                controller: _githubCtrl,
                decoration: const InputDecoration(
                  labelText: 'GitHub Link',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),

              // Year → integer in DB
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
                      return 'Enter a valid year (e.g. 2024)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Extension Possible → boolean in DB, default false
              SwitchListTile(
                title: const Text('Extension Possible'),
                value: _extensionPossible,
                onChanged: (val) => setState(() => _extensionPossible = val),
              ),
              const SizedBox(height: 20),

              // Submit
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
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text('Submit', style: TextStyle(fontSize: 16)),
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