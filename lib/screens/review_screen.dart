import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';

import '../studio_theme.dart';
import '../widgets/review_screen/admin_card.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final all = state.allChallenges;
    final pending = all.where((c) => !c.approved).toList();
    final approved = all.where((c) => c.approved).toList();
    return RefreshIndicator(
      onRefresh: () => state.refreshChallenges(),
      color: StudioTheme.primaryGreen,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            _SectionBanner(
              icon: Icons.pending_actions_rounded,
              label: AppLocalizations.of(context)!.pendingReview(pending.length),
              color: StudioTheme.warningOrange,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            ...pending.map((c) => AdminCard(challenge: c)),
            const SizedBox(height: 20),
          ],
          if (approved.isNotEmpty) ...[
            _SectionBanner(
              icon: Icons.verified_rounded,
              label: AppLocalizations.of(context)!.approvedReview(approved.length),
              color: StudioTheme.successGreen,
              isDark: isDark,
            ),
            const SizedBox(height: 8),
            ...approved.map((c) => AdminCard(challenge: c)),
          ],
          if (all.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_rounded,
                        size: 56,
                        color: isDark ? Colors.grey[600] : Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noChallengesSubmitted,
                      style: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
class _SectionBanner extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;
  const _SectionBanner({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

