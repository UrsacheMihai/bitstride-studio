import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import '../models/studio_challenge.dart';
import '../studio_theme.dart';
import 'create_screen.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
class MyChallengesScreen extends StatelessWidget {
  const MyChallengesScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final challenges = state.myChallenges;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.04)
                    : Colors.grey.withOpacity(0.06),
              ),
              child: Icon(Icons.inbox_rounded,
                  size: 48,
                  color: isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(height: 20),
            Text(
              AppLocalizations.of(context)!.noChallenges,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateScreen())),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: Text(AppLocalizations.of(context)!.createFirst),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: () => state.refreshChallenges(),
      color: StudioTheme.primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (ctx, i) => _ChallengeCard(challenge: challenges[i]),
      ),
    );
  }
}
class _ChallengeCard extends StatelessWidget {
  final StudioChallenge challenge;
  const _ChallengeCard({required this.challenge});
  Color get _diffColor {
    switch (challenge.difficulty) {
      case 'Easy': return StudioTheme.successGreen;
      case 'Medium': return StudioTheme.warningOrange;
      default: return StudioTheme.errorRed;
    }
  }
  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final approved = challenge.approved;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
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
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: approved
                        ? StudioTheme.primaryGradient
                        : null,
                    color: approved
                        ? null
                        : StudioTheme.warningOrange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: approved
                        ? [
                            BoxShadow(
                              color: StudioTheme.successGreen.withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    approved
                        ? Icons.check_circle_rounded
                        : Icons.hourglass_top_rounded,
                    color: approved
                        ? Colors.white
                        : StudioTheme.warningOrange,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
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
                                challenge.method, const Color(0xFF00897B)),
                          _TagChip(
                            approved
                                ? AppLocalizations.of(context)!.approvedTitle
                                : AppLocalizations.of(context)!.pendingTitle,
                            approved
                                ? StudioTheme.successGreen
                                : StudioTheme.warningOrange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded,
                      color: isDark ? Colors.grey[500] : Colors.grey[400]),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  onSelected: (v) async {
                    if (v == 'edit') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                CreateScreen(existing: challenge)),
                      );
                    } else if (v == 'delete') {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          title: Text(AppLocalizations.of(context)!
                              .deleteChallengeTitle),
                          content: Text(
                              AppLocalizations.of(context)!.cannotBeUndone),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                  AppLocalizations.of(context)!.cancel),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(
                                AppLocalizations.of(context)!.delete,
                                style: const TextStyle(
                                    color: StudioTheme.errorRed),
                              ),
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
                      child: Row(
                        children: [
                          const Icon(Icons.edit_rounded, size: 18),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          const Icon(Icons.delete_rounded,
                              size: 18, color: StudioTheme.errorRed),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.delete,
                            style: const TextStyle(color: StudioTheme.errorRed),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
class _TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const _TagChip(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
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

