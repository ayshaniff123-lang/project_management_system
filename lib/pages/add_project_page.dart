import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/supabase_service.dart';

class AddProjectPage extends StatefulWidget {
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

class _AddProjectPageState extends State<AddProjectPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _abstractCtrl = TextEditingController();
  String? _selectedDomainName;
  List<Map<String, dynamic>> _domains = [];
  bool _isLoadingDomains = true;
  final _guideCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _relevantDescriptionCtrl = TextEditingController();

  String _projectType = 'mini';
  bool _extensionPossible = false;
  bool _socialRelevant = false;
  bool _loading = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Design tokens
  static const _primaryColor = Color(0xFF1A1A2E);
  static const _accentColor = Color(0xFF6C63FF);
  static const _cardColor = Color(0xFFFFFFFF);
  static const _bgColor = Color(0xFFF4F6FB);
  static const _labelColor = Color(0xFF7B8CA6);
  static const _textColor = Color(0xFF1A1A2E);
  static const _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadDomains();
  }

  Future<void> _loadDomains() async {
    final domains = await SupabaseService.fetchDomains();
    if (mounted) {
      setState(() {
        _domains = domains;
        _isLoadingDomains = false;
        if (widget.domainId != null) {
          try {
            _selectedDomainName = _domains.firstWhere(
              (d) => d['id'] == widget.domainId,
            )['domain_name'];
          } catch (e) {
            _selectedDomainName = null;
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleCtrl.dispose();
    _abstractCtrl.dispose();
    _guideCtrl.dispose();
    _teamCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _githubCtrl.dispose();
    _yearCtrl.dispose();
    _relevantDescriptionCtrl.dispose();
    super.dispose();
  }

  List<String> _parseTeamMembers(String raw) =>
      raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

  String? _nullIfEmpty(String value) {
    final t = value.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final project = Project(
      title: _titleCtrl.text.trim(),
      abstract: _nullIfEmpty(_abstractCtrl.text),
      domain: _selectedDomainName,
      domainId: _selectedDomainName != null
          ? _domains.firstWhere(
              (d) => d['domain_name'] == _selectedDomainName,
            )['id']
          : widget.domainId,
      projectType: _projectType,
      guideName: _nullIfEmpty(_guideCtrl.text),
      guideId: widget.guideId,
      studentId: widget.studentId,
      teamMembers: _parseTeamMembers(_teamCtrl.text),
      contactEmail: _nullIfEmpty(_emailCtrl.text),
      contactPhone: _nullIfEmpty(_phoneCtrl.text),
      githubLink: _nullIfEmpty(_githubCtrl.text),
      year: int.tryParse(_yearCtrl.text.trim()),
      extensionPossible: _extensionPossible,
      socialRelevant: _socialRelevant,
      relevantDescription: _socialRelevant
          ? _nullIfEmpty(_relevantDescriptionCtrl.text)
          : null,
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
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Insert failed. Please try again.'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            // ── Hero App Bar ──────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: _primaryColor,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: const Text(
                  'New Project',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF1A1A2E), Color(0xFF6C63FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    // Decorative circles
                    Positioned(
                      right: -30,
                      top: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 40,
                      bottom: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Form Body ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionCard(
                        icon: Icons.auto_stories_rounded,
                        title: 'Project Info',
                        children: [
                          _field(
                            controller: _titleCtrl,
                            label: 'Project Title',
                            hint: 'Enter a descriptive title',
                            icon: Icons.title_rounded,
                            required: true,
                            validator: (val) =>
                                (val == null || val.trim().isEmpty)
                                ? 'Title is required'
                                : null,
                          ),
                          const SizedBox(height: 16),
                          _field(
                            controller: _abstractCtrl,
                            label: 'Abstract',
                            hint: 'Brief description of your project...',
                            icon: Icons.description_rounded,
                            maxLines: 4,
                          ),
                          const SizedBox(height: 16),
                          if (_isLoadingDomains)
                            const SizedBox(height: 0)
                          else
                            DropdownButtonFormField<String>(
                              value: _selectedDomainName,
                              decoration: InputDecoration(
                                labelText: 'Domain',
                                hintText: 'Select a domain',
                                hintStyle: TextStyle(
                                  color: _labelColor.withOpacity(0.6),
                                  fontSize: 13,
                                ),
                                labelStyle: const TextStyle(
                                  color: _labelColor,
                                  fontSize: 13,
                                ),
                                prefixIcon: const Icon(
                                  Icons.category_rounded,
                                  color: _accentColor,
                                  size: 18,
                                ),
                                filled: true,
                                fillColor: _bgColor,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: _borderColor,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: _borderColor,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: _accentColor,
                                    width: 1.8,
                                  ),
                                ),
                              ),
                              items: _domains.map((d) {
                                return DropdownMenuItem<String>(
                                  value: d['domain_name'] as String,
                                  child: Text(
                                    d['domain_name'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: _textColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedDomainName = val;
                                });
                              },
                            ),
                          const SizedBox(height: 16),
                          _projectTypeSelector(),
                          const SizedBox(height: 16),
                          _field(
                            controller: _yearCtrl,
                            label: 'Year',
                            hint: 'e.g. 2024',
                            icon: Icons.calendar_today_rounded,
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
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        icon: Icons.people_alt_rounded,
                        title: 'Team & Guide',
                        children: [
                          _field(
                            controller: _guideCtrl,
                            label: 'Guide Name',
                            hint: 'Faculty guide name',
                            icon: Icons.person_rounded,
                          ),
                          const SizedBox(height: 16),
                          _field(
                            controller: _teamCtrl,
                            label: 'Team Members',
                            hint: 'Alice, Bob, Charlie',
                            icon: Icons.group_rounded,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _sectionCard(
                        icon: Icons.contact_mail_rounded,
                        title: 'Contact & Links',
                        children: [
                          _field(
                            controller: _emailCtrl,
                            label: 'Contact Email',
                            hint: 'team@example.com',
                            icon: Icons.email_rounded,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 16),
                          _field(
                            controller: _phoneCtrl,
                            label: 'Contact Phone',
                            hint: '+91 98765 43210',
                            icon: Icons.phone_rounded,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _field(
                            controller: _githubCtrl,
                            label: 'GitHub Link',
                            hint: 'https://github.com/...',
                            icon: Icons.code_rounded,
                            keyboardType: TextInputType.url,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Extension toggle card
                      Container(
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SwitchListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 4,
                          ),
                          secondary: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: _accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.extension_rounded,
                              color: _accentColor,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Extension Possible',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: _textColor,
                              fontSize: 15,
                            ),
                          ),
                          subtitle: const Text(
                            'Can this project be extended further?',
                            style: TextStyle(color: _labelColor, fontSize: 12),
                          ),
                          value: _extensionPossible,
                          activeColor: _accentColor,
                          onChanged: (val) =>
                              setState(() => _extensionPossible = val),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Socially relevant toggle card
                      Container(
                        decoration: BoxDecoration(
                          color: _cardColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 4,
                              ),
                              secondary: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: _accentColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.public_rounded,
                                  color: _accentColor,
                                  size: 20,
                                ),
                              ),
                              title: const Text(
                                'Socially Relevant',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: _textColor,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: const Text(
                                'Does this project have a social impact?',
                                style: TextStyle(
                                  color: _labelColor,
                                  fontSize: 12,
                                ),
                              ),
                              value: _socialRelevant,
                              activeColor: _accentColor,
                              onChanged: (val) =>
                                  setState(() => _socialRelevant = val),
                            ),
                            if (_socialRelevant) ...[
                              const Divider(color: _borderColor, height: 1),
                              Padding(
                                padding: const EdgeInsets.all(20),
                                child: _field(
                                  controller: _relevantDescriptionCtrl,
                                  label: 'Relevant Description',
                                  hint: 'Describe the social impact...',
                                  icon: Icons.volunteer_activism_rounded,
                                  maxLines: 3,
                                  required: true,
                                  validator: (val) =>
                                      (val == null || val.trim().isEmpty)
                                      ? 'Description is required'
                                      : null,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentColor,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: _accentColor.withOpacity(
                              0.5,
                            ),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.rocket_launch_rounded, size: 20),
                                    SizedBox(width: 10),
                                    Text(
                                      'Submit Project',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Card ──────────────────────────────────────────────
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: _accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(color: _borderColor, height: 24),
          ...children,
        ],
      ),
    );
  }

  // ── Text Field ────────────────────────────────────────────────
  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(
        fontSize: 14,
        color: _textColor,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        hintText: hint,
        hintStyle: TextStyle(color: _labelColor.withOpacity(0.6), fontSize: 13),
        labelStyle: const TextStyle(color: _labelColor, fontSize: 13),
        prefixIcon: Icon(icon, color: _accentColor, size: 18),
        filled: true,
        fillColor: _bgColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _accentColor, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
      validator: validator,
    );
  }

  // ── Project Type Selector ─────────────────────────────────────
  Widget _projectTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Project Type *',
          style: TextStyle(
            color: _labelColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _typeChip('mini', 'Mini', Icons.science_rounded),
            const SizedBox(width: 12),
            _typeChip('major', 'Major', Icons.rocket_rounded),
          ],
        ),
      ],
    );
  }

  Widget _typeChip(String value, String label, IconData icon) {
    final selected = _projectType == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _projectType = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? _accentColor : _bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _accentColor : _borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? Colors.white : _labelColor,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : _labelColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
