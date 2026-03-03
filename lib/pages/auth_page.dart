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
      // Sign up user
      await SupabaseService.signUp(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Wait until the session is available
      await Future.delayed(const Duration(seconds: 1)); // small delay for Web

      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('User not authenticated yet. Try refreshing.');
      }

      // Create profile
      final success = await SupabaseService.createProfile(
        id: user.id,
        name: _nameController.text.trim(),
        role: widget.selectedRole.toLowerCase(),
      );

      if (!success) {
        throw Exception('Failed to create user profile');
      }
    } else {
      // Login existing user
      await SupabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      await Future.delayed(const Duration(seconds: 1)); // wait for session

      final user = SupabaseService.currentUser;
      if (user == null) {
        throw Exception('Login failed. Check email/password.');
      }
    }

    // Navigate to home
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