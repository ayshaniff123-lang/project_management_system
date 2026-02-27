import 'package:flutter/material.dart';
import 'home_page.dart';
import 'auth_page.dart';

void main() {
  runApp(const ProjectRepoApp());
}

class ProjectRepoApp extends StatelessWidget {
  const ProjectRepoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Repository',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Georgia',
        scaffoldBackgroundColor: const Color(0xFF0A0E1A),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4ECDC4),
          secondary: const Color(0xFFFF6B6B),
          surface: const Color(0xFF141928),
        ),
      ),
      home: const RoleSelectionPage(),
    );
  }
}

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _titleSlide;
  late Animation<Offset> _card1Slide;
  late Animation<Offset> _card2Slide;

  //int? _hoveredIndex;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _card1Slide = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _card2Slide = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

 /* void _onRoleSelected(String role, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Continuing as $role...',
          style: const TextStyle(
            color: Color(0xFF0A0E1A),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: role == 'Faculty'
            ? const Color(0xFF4ECDC4)
            : const Color(0xFFFF6B6B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Navigate to respective login screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage(role: role)));
    Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const HomePage(),
    ),
  );
  }*/
void _onRoleSelected(String role, BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      // Ensure the role is lowercase ('student' or 'faculty') to match DB constraints
      builder: (_) => AuthPage(selectedRole: role.toLowerCase()),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background grid pattern
          CustomPaint(
            size: Size(size.width, size.height),
            painter: _GridPainter(),
          ),
          // Glowing orbs
          Positioned(
            top: -100,
            right: -80,
            child: _GlowOrb(color: const Color(0xFF4ECDC4).withOpacity(0.15), size: 350),
          ),
          Positioned(
            bottom: -80,
            left: -60,
            child: _GlowOrb(color: const Color(0xFFFF6B6B).withOpacity(0.12), size: 300),
          ),
          // Content
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _titleSlide,
                        child: Column(
                          children: [
                            // Logo mark
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4ECDC4).withOpacity(0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.folder_special_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                            ),
                            const SizedBox(height: 28),
                            const Text(
                              'PROJECT',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 6,
                                color: Color(0xFF4ECDC4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Repository',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: -1,
                                height: 1,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Centralized project management\nfor students and faculty',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.45),
                                height: 1.6,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 52),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SELECT YOUR ROLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 3,
                            color: Color(0xFF4ECDC4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          // Student Card
                          Expanded(
                            child: SlideTransition(
                              position: _card1Slide,
                              child: _RoleCard(
                                role: 'Student',
                                subtitle: 'Submit & track your\nproject submissions',
                                icon: Icons.school_rounded,
                                gradientColors: const [Color(0xFFFF6B6B), Color(0xFFEE5A24)],
                                glowColor: const Color(0xFFFF6B6B),
                                accentColor: const Color(0xFFFF6B6B),
                                features: const ['Submit Projects', 'View Feedback', 'Track Status'],
                                onTap: () => _onRoleSelected('Student', context),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Faculty Card
                          Expanded(
                            child: SlideTransition(
                              position: _card2Slide,
                              child: _RoleCard(
                                role: 'Faculty',
                                subtitle: 'Review & manage\nstudent projects',
                                icon: Icons.person_pin_rounded,
                                gradientColors: const [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                                glowColor: const Color(0xFF4ECDC4),
                                accentColor: const Color(0xFF4ECDC4),
                                features: const ['Review Projects', 'Add Remarks', 'Manage Domains'],
                                onTap: () => _onRoleSelected('Faculty', context),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                      Text(
                        'Your data is secure and role-restricted',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.25),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String role;
  final String subtitle;
  final IconData icon;
  final List<Color> gradientColors;
  final Color glowColor;
  final Color accentColor;
  final List<String> features;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.glowColor,
    required this.accentColor,
    required this.features,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pressController;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          widget.onTap();
        },
        onTapCancel: () => _pressController.reverse(),
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: const Color(0xFF141928),
              border: Border.all(
                color: _isHovered
                    ? widget.glowColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.07),
                width: 1.5,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(0.2),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon box
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: LinearGradient(
                      colors: widget.gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.glowColor.withOpacity(0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 26),
                ),
                const SizedBox(height: 18),
                Text(
                  widget.role,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.45),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                // Feature tags
                ...widget.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: widget.accentColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            f,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.6),
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 18),
                // CTA
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: _isHovered
                        ? LinearGradient(colors: widget.gradientColors)
                        : LinearGradient(
                            colors: widget.gradientColors
                                .map((c) => c.withOpacity(0.15))
                                .toList(),
                          ),
                  ),
                  child: Center(
                    child: Text(
                      'Continue →',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _isHovered
                            ? Colors.white
                            : widget.accentColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowOrb({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 1;

    const spacing = 40.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}