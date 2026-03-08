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

class ProjectComparisonPage extends StatelessWidget {
  final Project projectA;
  final Project projectB;

  const ProjectComparisonPage({
    required this.projectA,
    required this.projectB,
    super.key,
  });

  int _calculateScore(Project p1, Project p2) {
    int score = 0;
    if (p1.projectType == 'major' && p2.projectType == 'mini') score++;
    if (p1.extensionPossible && !p2.extensionPossible) score++;
    if (p1.socialRelevant && !p2.socialRelevant) score++;
    // Add point for having GitHub link when other doesn't
    if ((p1.githubLink?.isNotEmpty ?? false) &&
        (p2.githubLink?.isEmpty ?? true))
      score++;
    // Slightly favor projects with more team members as a proxy for scale
    if (p1.teamMembers.length > p2.teamMembers.length) score++;
    return score;
  }

  @override
  Widget build(BuildContext context) {
    int scoreA = _calculateScore(projectA, projectB);
    int scoreB = _calculateScore(projectB, projectA);

    String winnerText;
    Color winnerColor;
    if (scoreA > scoreB) {
      winnerText = '${projectA.title} is favored by metrics';
      winnerColor = const Color(0xFF4CAF50);
    } else if (scoreB > scoreA) {
      winnerText = '${projectB.title} is favored by metrics';
      winnerColor = const Color(0xFF4CAF50);
    } else {
      winnerText = 'Both projects are evenly matched';
      winnerColor = const Color(0xFFFF9800);
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180,
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
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1A1A2E), Color(0xFF6C63FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    bottom: 24,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Comparison Report',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Analyzing metrics across both projects',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Verdict Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: winnerColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: winnerColor.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.insights_rounded,
                          color: winnerColor,
                          size: 32,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Final Verdict',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: winnerColor.withOpacity(0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          winnerText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: winnerColor,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Score: ${projectA.title} ($scoreA) vs ${projectB.title} ($scoreB)',
                          style: TextStyle(
                            fontSize: 12,
                            color: winnerColor.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Comparison Table Container
                  Container(
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
                    child: Column(
                      children: [
                        // Headers
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Expanded(flex: 2, child: SizedBox()),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Project A',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _accentColor,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  'Project B',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange.shade700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: _borderColor, height: 1),

                        // Row: Title (just to be clear which is which)
                        _buildComparisonRow(
                          'Title',
                          projectA.title,
                          projectB.title,
                          highlightA: false,
                          highlightB: false,
                          truncate: true,
                        ),

                        // Row: Type
                        _buildComparisonRow(
                          'Type',
                          projectA.projectType.toUpperCase(),
                          projectB.projectType.toUpperCase(),
                          highlightA:
                              projectA.projectType == 'major' &&
                              projectB.projectType == 'mini',
                          highlightB:
                              projectB.projectType == 'major' &&
                              projectA.projectType == 'mini',
                        ),

                        // Row: Domain
                        _buildComparisonRow(
                          'Domain',
                          projectA.domain ?? 'N/A',
                          projectB.domain ?? 'N/A',
                        ),

                        // Row: Year
                        _buildComparisonRow(
                          'Year',
                          projectA.year?.toString() ?? 'N/A',
                          projectB.year?.toString() ?? 'N/A',
                        ),

                        // Row: Extension
                        _buildComparisonRow(
                          'Extension',
                          projectA.extensionPossible ? 'Yes' : 'No',
                          projectB.extensionPossible ? 'Yes' : 'No',
                          highlightA:
                              projectA.extensionPossible &&
                              !projectB.extensionPossible,
                          highlightB:
                              projectB.extensionPossible &&
                              !projectA.extensionPossible,
                        ),

                        // Row: Social Relevant
                        _buildComparisonRow(
                          'Social Impact',
                          projectA.socialRelevant ? 'Yes' : 'No',
                          projectB.socialRelevant ? 'Yes' : 'No',
                          highlightA:
                              projectA.socialRelevant &&
                              !projectB.socialRelevant,
                          highlightB:
                              projectB.socialRelevant &&
                              !projectA.socialRelevant,
                        ),

                        // Row: Team Size
                        _buildComparisonRow(
                          'Team Size',
                          '${projectA.teamMembers.length} members',
                          '${projectB.teamMembers.length} members',
                          highlightA:
                              projectA.teamMembers.length >
                              projectB.teamMembers.length,
                          highlightB:
                              projectB.teamMembers.length >
                              projectA.teamMembers.length,
                        ),

                        // Row: GitHub Linked
                        _buildComparisonRow(
                          'Code Link',
                          (projectA.githubLink?.isNotEmpty ?? false)
                              ? 'Linked'
                              : '-',
                          (projectB.githubLink?.isNotEmpty ?? false)
                              ? 'Linked'
                              : '-',
                          highlightA:
                              (projectA.githubLink?.isNotEmpty ?? false) &&
                              (projectB.githubLink?.isEmpty ?? true),
                          highlightB:
                              (projectB.githubLink?.isNotEmpty ?? false) &&
                              (projectA.githubLink?.isEmpty ?? true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonRow(
    String label,
    String valA,
    String valB, {
    bool highlightA = false,
    bool highlightB = false,
    bool truncate = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              // Label
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _labelColor,
                  ),
                ),
              ),
              // Value A
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: highlightA
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: highlightA
                          ? const Color(0xFF4CAF50).withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    valA,
                    textAlign: TextAlign.center,
                    maxLines: truncate ? 2 : null,
                    overflow: truncate ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: highlightA
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: highlightA ? const Color(0xFF2E7D32) : _textColor,
                    ),
                  ),
                ),
              ),
              // Value B
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: highlightB
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: highlightB
                          ? const Color(0xFF4CAF50).withOpacity(0.3)
                          : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    valB,
                    textAlign: TextAlign.center,
                    maxLines: truncate ? 2 : null,
                    overflow: truncate ? TextOverflow.ellipsis : null,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: highlightB
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: highlightB ? const Color(0xFF2E7D32) : _textColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: _borderColor, height: 1),
      ],
    );
  }
}
