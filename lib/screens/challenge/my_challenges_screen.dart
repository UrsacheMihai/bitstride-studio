import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';
import '../../models/challenge/studio_challenge.dart';
import '../../theme/studio_theme.dart';
import '../../widgets/glass/glass_app_bar.dart';
import './create_screen.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Challenge definition and initialization
class MyChallengesScreen extends StatelessWidget {
  const MyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final challenges = state.myChallenges;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final topPad = MediaQuery.of(context).padding.top + kToolbarHeight;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: _AppBarTitle(
          icon: Icons.folder_rounded,
          label: l.myChallenges,
          gradient: StudioTheme.primaryGradient,
          glowColor: StudioTheme.primaryTeal,
        ),
      ),
      body: Container(
        decoration: StudioTheme.meshBackground(isDark: isDark),
        child: challenges.isEmpty
            ? _EmptyState(l: l, isDark: isDark, topPad: topPad)
            : RefreshIndicator(
                onRefresh: () => state.refreshChallenges(),
                color: StudioTheme.primaryCyan,
                child: ListView.builder(
                  padding: EdgeInsets.fromLTRB(16, topPad + 16, 16, 100),
                  itemCount: challenges.length,
                  itemBuilder: (ctx, i) =>
                      _ChallengeCard(challenge: challenges[i]),
                ),
              ),
      ),
    );
  }
}

// Manage state and provide providers for Empty State.
class _EmptyState extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  final double topPad;

  const _EmptyState({
    required this.l,
    required this.isDark,
    required this.topPad,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(top: topPad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? StudioTheme.darkCard : StudioTheme.lightCard2,
                border: Border.all(
                  color:
                      isDark ? StudioTheme.darkBorder : StudioTheme.lightBorder,
                ),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 48,
                color:
                    isDark ? const Color(0xFF4A5568) : const Color(0xFFABB8CC),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.noChallenges,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : StudioTheme.darkBg,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Create your first challenge to get started',
              style: TextStyle(
                fontSize: 13,
                color:
                    isDark ? const Color(0xFF6B7A99) : const Color(0xFF8B9AB0),
              ),
            ),
            const SizedBox(height: 28),
            _GradientFab(
              label: l.createFirst,
              icon: Icons.add_rounded,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Challenge definition and initialization
class _ChallengeCard extends StatelessWidget {
  final StudioChallenge challenge;

  const _ChallengeCard({required this.challenge});

  Color get _diffColor {
    switch (challenge.difficulty) {
      case 'Easy':
        return StudioTheme.successGreen;
      case 'Medium':
        return StudioTheme.warningOrange;
      default:
        return StudioTheme.errorRed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final approved = challenge.approved;
    final accentColor =
        approved ? StudioTheme.successGreen : StudioTheme.warningOrange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: StudioTheme.solidCard(
          isDark: isDark,
          borderRadius: 20,
          accentColor: accentColor,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => CreateScreen(existing: challenge)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _StatusIcon(approved: approved),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: isDark ? Colors.white : StudioTheme.darkBg,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _TagChip(challenge.difficulty, _diffColor),
                            if (challenge.hasCpp)
                              const _TagChip('C++', Color(0xFF00599C)),
                            if (challenge.hasPython)
                              const _TagChip('Python', Color(0xFF3776AB)),
                            if (challenge.category.isNotEmpty)
                              _TagChip(
                                  challenge.category, StudioTheme.accentPurple),
                            if (challenge.method.isNotEmpty)
                              _TagChip(
                                  challenge.method, const Color(0xFF00BFA5)),
                            _TagChip(
                              approved
                                  ? AppLocalizations.of(context)!.approvedTitle
                                  : AppLocalizations.of(context)!.pendingTitle,
                              accentColor,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _ChallengeMenu(challenge: challenge, state: state),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Render the approval status icon for a challenge card.
class _StatusIcon extends StatelessWidget {
  final bool approved;

  const _StatusIcon({required this.approved});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: approved ? StudioTheme.primaryGradient : null,
        color: approved ? null : StudioTheme.warningOrange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: approved
            ? null
            : Border.all(color: StudioTheme.warningOrange.withOpacity(0.3)),
        boxShadow: approved
            ? [
                BoxShadow(
                  color: StudioTheme.successGreen.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Icon(
        approved ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
        color: approved ? Colors.white : StudioTheme.warningOrange,
        size: 22,
      ),
    );
  }
}

// Challenge definition and initialization
class _ChallengeMenu extends StatelessWidget {
  final StudioChallenge challenge;
  final StudioState state;

  const _ChallengeMenu({required this.challenge, required this.state});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded,
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF4A5568)
              : const Color(0xFF8B9AB0)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      onSelected: (v) async {
        if (v == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => CreateScreen(existing: challenge)),
          );
        } else if (v == 'delete') {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text(l.deleteChallengeTitle),
              content: Text(l.cannotBeUndone),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(l.cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(l.delete,
                      style: const TextStyle(color: StudioTheme.errorRed)),
                ),
              ],
            ),
          );
          if (confirm == true) {
            await state.deleteChallenge(challenge.id);
          }
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            const Icon(Icons.edit_rounded, size: 18),
            const SizedBox(width: 10),
            Text(l.edit),
          ]),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            const Icon(Icons.delete_rounded,
                size: 18, color: StudioTheme.errorRed),
            const SizedBox(width: 10),
            Text(l.delete, style: const TextStyle(color: StudioTheme.errorRed)),
          ]),
        ),
      ],
    );
  }
}

// Provide interface component for Tag Chip.
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;

  const _TagChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// Provide interface component for App Bar Title.
class _AppBarTitle extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final Color glowColor;

  const _AppBarTitle({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.glowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}

// Render a gradient floating action button.
class _GradientFab extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _GradientFab({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: StudioTheme.creatorGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: StudioTheme.accentPurple.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
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
