import 'package:flutter/material.dart';
import '../models/project.dart';

// ═══════════════════════════════════════════════════════════
// DESIGN TOKENS
// ═══════════════════════════════════════════════════════════
const _primaryColor = Color(0xFF1A1A2E);
const _accentColor = Color(0xFF6C63FF);
const _bgColor = Color(0xFFF4F6FB);
const _cardColor = Color(0xFFFFFFFF);
const _labelColor = Color(0xFF7B8CA6);
const _textColor = Color(0xFF1A1A2E);
const _borderColor = Color(0xFFE2E8F0);

class ProjectDetailPage extends StatelessWidget {
  final Project project;

  const ProjectDetailPage({required this.project, super.key});

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isMajor = project.projectType == 'major';

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
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
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isMajor
                            ? [const Color(0xFF1A1A2E), const Color(0xFFE65100)]
                            : [
                                const Color(0xFF1A1A2E),
                                const Color(0xFF6C63FF),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Decorative circles
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -20,
                    bottom: 30,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                  ),
                  // Content
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isMajor
                                    ? Icons.rocket_rounded
                                    : Icons.science_rounded,
                                color: Colors.white,
                                size: 13,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                isMajor ? 'MAJOR PROJECT' : 'MINI PROJECT',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Title
                        Text(
                          project.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        // Created date
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: Colors.white.withOpacity(0.7),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Created: ${_formatDate(project.createdAt)}',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body Content ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Abstract ────────────────────────────────────
                  if (project.abstract != null &&
                      project.abstract!.isNotEmpty) ...[
                    _sectionCard(
                      icon: Icons.description_rounded,
                      title: 'Abstract',
                      child: Text(
                        project.abstract!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _labelColor,
                          height: 1.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Project Information ──────────────────────────
                  _sectionCard(
                    icon: Icons.info_outline_rounded,
                    title: 'Project Information',
                    child: Column(
                      children: [
                        if (project.domain != null)
                          _detailRow(
                            icon: Icons.category_rounded,
                            label: 'Domain',
                            value: project.domain!,
                            iconColor: const Color(0xFF4CAF50),
                          ),
                        if (project.guideName != null)
                          _detailRow(
                            icon: Icons.person_rounded,
                            label: 'Guide',
                            value: project.guideName!,
                            iconColor: const Color(0xFFFF9800),
                          ),
                        if (project.year != null)
                          _detailRow(
                            icon: Icons.calendar_today_rounded,
                            label: 'Year',
                            value: '${project.year}',
                            iconColor: Colors.redAccent,
                          ),
                        if (project.githubLink != null)
                          _detailRow(
                            icon: Icons.code_rounded,
                            label: 'GitHub',
                            value: project.githubLink!,
                            iconColor: _primaryColor,
                            isLast: true,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Team Members ────────────────────────────────
                  if (project.teamMembers.isNotEmpty) ...[
                    _sectionCard(
                      icon: Icons.group_rounded,
                      title: 'Team Members',
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: project.teamMembers
                            .map((member) => _memberChip(member))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Contact Information ─────────────────────────
                  if (project.contactEmail != null ||
                      project.contactPhone != null) ...[
                    _sectionCard(
                      icon: Icons.contact_mail_rounded,
                      title: 'Contact Information',
                      child: Column(
                        children: [
                          if (project.contactEmail != null)
                            _detailRow(
                              icon: Icons.email_rounded,
                              label: 'Email',
                              value: project.contactEmail!,
                              iconColor: _accentColor,
                            ),
                          if (project.contactPhone != null)
                            _detailRow(
                              icon: Icons.phone_rounded,
                              label: 'Phone',
                              value: project.contactPhone!,
                              iconColor: const Color(0xFF4CAF50),
                              isLast: true,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Extension Badge ─────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: project.extensionPossible
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: project.extensionPossible
                            ? const Color(0xFFA5D6A7)
                            : const Color(0xFFEF9A9A),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: project.extensionPossible
                                ? const Color(0xFF4CAF50).withOpacity(0.15)
                                : Colors.red.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            project.extensionPossible
                                ? Icons.check_circle_rounded
                                : Icons.cancel_rounded,
                            color: project.extensionPossible
                                ? const Color(0xFF4CAF50)
                                : Colors.redAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Extension Status',
                              style: TextStyle(
                                fontSize: 12,
                                color: _labelColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              project.extensionPossible
                                  ? 'Extension Possible'
                                  : 'Extension Not Possible',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: project.extensionPossible
                                    ? const Color(0xFF2E7D32)
                                    : Colors.red.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section Card ──────────────────────────────────────────────
  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
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
          const Divider(color: _borderColor, height: 24),
          child,
        ],
      ),
    );
  }

  // ── Detail Row ────────────────────────────────────────────────
  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 17),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _labelColor,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: _textColor,
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(color: _borderColor, height: 1),
      ],
    );
  }

  // ── Member Chip ───────────────────────────────────────────────
  Widget _memberChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: _accentColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _accentColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 13,
              color: _accentColor,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _accentColor,
            ),
          ),
        ],
      ),
    );
  }
}
