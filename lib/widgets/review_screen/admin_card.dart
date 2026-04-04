import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/studio_state.dart';
import '../../models/studio_challenge.dart';
import '../../screens/create_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AdminCard extends StatelessWidget {
  final StudioChallenge challenge;
  const AdminCard({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: challenge.approved
              ? const Color(0xFF4CAF50).withOpacity(0.4)
              : Colors.orange.withOpacity(0.4),
        ),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: challenge.approved
              ? Colors.green.withOpacity(0.15)
              : Colors.orange.withOpacity(0.15),
          child: Text(
            challenge.language == 'cpp' ? 'C++' : 'PY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color:
                  challenge.language == 'cpp' ? Colors.blue : Colors.green,
            ),
          ),
        ),
        title: Text(challenge.title,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          AppLocalizations.of(context)!.byCreator(challenge.creatorName, challenge.difficulty),
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.description,
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF23241f),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge.initialCode,
                    style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                    AppLocalizations.of(context)!.testCasesFiles(challenge.tests.length, challenge.files.length),
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (!challenge.approved)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50)),
                        onPressed: () =>
                            state.setApproval(challenge.id, true),
                        icon: const Icon(Icons.check, size: 16),
                        label: Text(AppLocalizations.of(context)!.approveBtn),
                      ),
                    if (challenge.approved)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.orange),
                        onPressed: () =>
                            state.setApproval(challenge.id, false),
                        icon: const Icon(Icons.undo, size: 16),
                        label: Text(AppLocalizations.of(context)!.revokeBtn),
                      ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CreateScreen(existing: challenge))),
                      icon: const Icon(Icons.edit, size: 16),
                      label: Text(AppLocalizations.of(context)!.edit),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      onPressed: () {
                        final Map<String, dynamic> output = {
                          "id": challenge.id,
                          "title": challenge.title,
                          "description": challenge.description,
                          "difficulty": challenge.difficulty,
                          "language": challenge.language,
                          "tests": challenge.tests.map((t) => {
                            "input": t.input,
                            "expected_output": t.expectedOutput,
                            if (t.outputFile != null) "output_file": t.outputFile,
                            if (t.isHidden) "hidden": true,
                          }).toList(),
                          "initial_code": challenge.initialCode,
                          "files": challenge.files.map((f) => {
                            "name": f.name,
                            "content": f.content,
                          }).toList(),
                          "success_mascot": "nailed_it",
                          "fail_mascot": "keep_trying",
                          "creator_name": challenge.creatorName,
                        };
                        Clipboard.setData(ClipboardData(text: const JsonEncoder.withIndent('  ').convert(output)));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(AppLocalizations.of(context)!.copiedJson)),
                        );
                      },
                      icon: const Icon(Icons.data_object, size: 16),
                      label: Text(AppLocalizations.of(context)!.copyJsonBtn),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.red, size: 20),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Delete?'),
                            content: Text(
                                'Delete "${challenge.title}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style:
                                          TextStyle(color: Colors.red))),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await state.deleteChallenge(challenge.id);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
