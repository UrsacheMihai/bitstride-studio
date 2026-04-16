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
}