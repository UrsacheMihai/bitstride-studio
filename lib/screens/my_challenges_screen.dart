import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import '../models/studio_challenge.dart';
import 'create_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyChallengesScreen extends StatelessWidget {
  const MyChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<StudioState>();
    final challenges = state.myChallenges;

    if (challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.noChallenges),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CreateScreen())),
              child: Text(AppLocalizations.of(context)!.createFirst),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => state.refreshChallenges(),
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

  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    final approved = challenge.approved;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: approved
              ? Colors.green.withOpacity(0.15)
              : Colors.orange.withOpacity(0.15),
          child: Icon(
            approved ? Icons.check_circle : Icons.hourglass_top,
            color: approved ? Colors.green : Colors.orange,
            size: 22,
          ),
        ),
        title: Text(challenge.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _Tag(challenge.difficulty, _diffColor(challenge.difficulty)),
            _Tag(challenge.language == 'cpp' ? 'C++' : 'Python', Colors.blue),
            if (challenge.category.isNotEmpty)
              _Tag(challenge.category, Colors.indigo),
            if (challenge.method.isNotEmpty)
              _Tag(challenge.method, Colors.purple),
            _Tag(
                approved
                    ? AppLocalizations.of(context)!.approvedTitle
                    : AppLocalizations.of(context)!.pendingTitle,
                approved ? Colors.green : Colors.orange),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) async {
            if (v == 'edit') {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          CreateScreen(existing: challenge)));
            } else if (v == 'delete') {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text(AppLocalizations.of(context)!.deleteChallengeTitle),
                  content:
                      Text(AppLocalizations.of(context)!.cannotBeUndone),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(AppLocalizations.of(context)!.cancel)),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(AppLocalizations.of(context)!.delete,
                            style: const TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await state.deleteChallenge(challenge.id);
              }
            }
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context)!.edit)),
            PopupMenuItem(
                value: 'delete',
                child:
                    Text(AppLocalizations.of(context)!.delete, style: const TextStyle(color: Colors.red))),
          ],
        ),
      ),
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.red;
    }
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, color: color, fontWeight: FontWeight.bold)),
    );
  }
}
