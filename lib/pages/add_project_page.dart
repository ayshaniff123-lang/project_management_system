import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';

class AddProjectPage extends StatefulWidget {
  const AddProjectPage({super.key});

  @override
  State<AddProjectPage> createState() => _AddProjectPageState();
}

class _AddProjectPageState extends State<AddProjectPage> {
  final _titleCtrl = TextEditingController();
  final _abstractCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    setState(() => _loading = true);
    final p = Project(title: _titleCtrl.text, abstract: _abstractCtrl.text);
    final ok = await SupabaseService.insertProject(p);
    setState(() => _loading = false);
    if (ok) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insert failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Project')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _abstractCtrl, decoration: const InputDecoration(labelText: 'Abstract')),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _submit, child: _loading ? const CircularProgressIndicator() : const Text('Submit'))
          ],
        ),
      ),
    );
  }
}
