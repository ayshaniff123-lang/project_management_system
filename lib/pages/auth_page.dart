import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'home_page.dart';
import 'faculty_dashboard_page.dart';

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
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    setState(() => _isLoading = true);
    setState(() => _errorMessage = null);

    try {
      if (_isSignUp) {
        // Faculty cannot sign up - only sign in (managed via Supabase backend)
        if (widget.selectedRole == 'faculty') {
          throw Exception('Faculty can only sign in. Contact your administrator to create your account.');
        }

        // Sign up user (for students only)
        await SupabaseService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        await Future.delayed(const Duration(seconds: 1));

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

        await Future.delayed(const Duration(seconds: 1));

        final user = SupabaseService.currentUser;
        if (user == null) {
          throw Exception('Login failed. Check email/password.');
        }
      }

      // Navigate based on role
      if (mounted) {
        final isFaculty = widget.selectedRole == 'faculty';
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => isFaculty
                ? const FacultyDashboardPage()
                : HomePage(role: widget.selectedRole),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFaculty = widget.selectedRole == 'faculty';

    return Scaffold(
      appBar: AppBar(
        title: Text('${_isSignUp && !isFaculty ? "Register" : "Login"} as ${widget.selectedRole}'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              if (_isSignUp && !isFaculty)
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_isSignUp && !isFaculty) const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _handleAuth,
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            _isSignUp ? 'Sign Up' : 'Login',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 16),
              if (!isFaculty)
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(_isSignUp
                      ? 'Already have an account? Login'
                      : 'Create new account'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}