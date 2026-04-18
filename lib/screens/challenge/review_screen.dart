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