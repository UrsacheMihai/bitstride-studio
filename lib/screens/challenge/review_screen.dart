// Provide a screen for reviewing and testing submitted challenges.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';
import '../../theme/studio_theme.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/review_screen/admin_card.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Render layout and manage state for Review Screen.
class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context)!;
    final all = state.allChallenges;
    final pending = all.where((c) => !c.approved).toList();
    final approved = all.where((c) => c.approved).toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: _ReviewAppBarTitle(isDark: isDark, l: l),
      ),
      body: Container(
        decoration: StudioTheme.meshBackground(isDark: isDark),
        child: RefreshIndicator(
          onRefresh: () => state.refreshChallenges(),
          color: StudioTheme.primaryCyan,
          child: all.isEmpty
              ? _EmptyReview(isDark: isDark, l: l)
              : ListView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    MediaQuery.of(context).padding.top + kToolbarHeight + 16,
                    16,
                    48,
                  ),
                  children: [
                    if (pending.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.pending_actions_rounded,
                        label: l.pendingReview(pending.length),
                        color: StudioTheme.warningOrange,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      ...pending.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AdminCard(challenge: c),
                          )),
                      const SizedBox(height: 20),
                    ],
                    if (approved.isNotEmpty) ...[
                      _SectionHeader(
                        icon: Icons.verified_rounded,
                        label: l.approvedReview(approved.length),
                        color: StudioTheme.successGreen,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 10),
                      ...approved.map((c) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: AdminCard(challenge: c),
                          )),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

// Provide interface component for Review App Bar Title.
class _ReviewAppBarTitle extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const _ReviewAppBarTitle({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: StudioTheme.creatorGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: StudioTheme.accentPurple.withOpacity(0.30),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Icon(Icons.rate_review_rounded,
              size: 18, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(l.reviewTab),
      ],
    );
  }
}

// Render the empty state when there are no pending challenges to review.
class _EmptyReview extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;

  const _EmptyReview({required this.isDark, required this.l});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? StudioTheme.darkCard : StudioTheme.lightCard2,
                  border: Border.all(
                    color: isDark
                        ? StudioTheme.darkBorder
                        : StudioTheme.lightBorder,
                  ),
                ),
                child: Icon(
                  Icons.inbox_rounded,
                  size: 48,
                  color: isDark
                      ? const Color(0xFF4A5568)
                      : const Color(0xFFABB8CC),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l.noChallengesSubmitted,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : StudioTheme.darkBg,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Submitted challenges will appear here',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? const Color(0xFF6B7A99)
                      : const Color(0xFF8B9AB0),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Render a section title header inside the review list.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _SectionHeader({
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
        color: color.withOpacity(isDark ? 0.10 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: color,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
