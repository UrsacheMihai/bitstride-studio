import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import '../models/studio_challenge.dart';
import '../widgets/review_screen/admin_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ReviewScreen extends StatelessWidget {
  const ReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final all = state.allChallenges;

    final pending = all.where((c) => !c.approved).toList();
    final approved = all.where((c) => c.approved).toList();

    return RefreshIndicator(
      onRefresh: () => state.refreshChallenges(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (pending.isNotEmpty) ...[
            _SectionHeader(
                AppLocalizations.of(context)!.pendingReview(pending.length), Colors.orange),
            ...pending.map((c) => AdminCard(challenge: c)),
            const SizedBox(height: 16),
          ],
          if (approved.isNotEmpty) ...[
            _SectionHeader(AppLocalizations.of(context)!.approvedReview(approved.length),
                const Color(0xFF4CAF50)),
            ...approved.map((c) => AdminCard(challenge: c)),
          ],
          if (all.isEmpty)
             Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Text(AppLocalizations.of(context)!.noChallengesSubmitted,
                    style: const TextStyle(color: Colors.grey)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader(this.title, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 15, color: color),
      ),
    );
  }
}

