import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'role_selection.dart';
import 'home_page.dart';
import 'faculty_dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final uuid = prefs.getString('user_uuid');
    final role = prefs.getString('user_role');

    // Add a slight delay for a smooth startup transition
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    if (uuid != null && role != null) {
      if (role == 'faculty') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const FacultyDashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(role: role)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RoleSelectionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E), // Primary Color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_special_rounded, color: Colors.white, size: 80),
          ],
        ),
      ),
    );
  }
}
