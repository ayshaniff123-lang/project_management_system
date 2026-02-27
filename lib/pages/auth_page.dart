import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';

class AuthPage extends StatefulWidget {
  final String selectedRole; // 'student' or 'faculty'

  const AuthPage({super.key, required this.selectedRole});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isSignUp = false;
  bool _isLoading = false;

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        // 1. Sign up user in Supabase Auth
        final response = await SupabaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (response.user != null) {
          // 2. Create the profile in your 'public.users' table
          await SupabaseService.createProfile(
            id: response.user!.id,
            name: _nameController.text.trim(),
            role: widget.selectedRole.toLowerCase(),
          );
        }
      } else {
        // Log in existing user
        await SupabaseService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_isSignUp ? "Register" : "Login"} as ${widget.selectedRole}')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            if (_isSignUp)
              TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 20),
            _isLoading 
              ? const CircularProgressIndicator() 
              : ElevatedButton(onPressed: _handleAuth, child: Text(_isSignUp ? 'Sign Up' : 'Login')),
            TextButton(
              onPressed: () => setState(() => _isSignUp = !_isSignUp),
              child: Text(_isSignUp ? 'Already have an account? Login' : 'Create new account'),
            ),
          ],
        ),
      ),
    );
  }
}