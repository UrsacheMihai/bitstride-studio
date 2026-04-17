import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/studio_state.dart';
import '../../models/studio_challenge.dart';
import '../../studio_theme.dart';
import '../../screens/create_screen.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
class AdminCard extends StatelessWidget {
  final StudioChallenge challenge;
  const AdminCard({super.key, required this.challenge});
  @override
  Widget build(BuildContext context) {
    final state = context.read<StudioState>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: challenge.approved
              ? StudioTheme.successGreen.withOpacity(0.3)
              : StudioTheme.warningOrange.withOpacity(0.3),
        ),
      ),
      child: ExpansionTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        leading: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (challenge.hasCpp)
              const Text('C++', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF00599C))),
            if (challenge.hasPython)
              const Text('PY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFF3776AB))),
          ],
        ),
        title: Text(challenge.title,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          AppLocalizations.of(context)!.byCreator(challenge.creatorName, challenge.difficulty),
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(challenge.description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                    )),
                const SizedBox(height: 10),
                if (challenge.hasCpp) ...[
                  Text('C++ Solution', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[300])),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                    child: Text(challenge.solutionCodeCpp!.trim(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70)),
                  ),
                  const SizedBox(height: 10),
                ],
                if (challenge.hasPython) ...[
                  Text('Python Solution', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.yellow[300])),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFF1E1E2E), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
                    child: Text(challenge.solutionCodePython!.trim(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12, color: Colors.white70)),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                    AppLocalizations.of(context)!.testCasesFiles(challenge.tests.length, challenge.files.length),
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[500] : Colors.grey[600],
                    )),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (!challenge.approved)
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: StudioTheme.successGreen,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () =>
                            state.setApproval(challenge.id, true),
                        icon: const Icon(Icons.check_rounded, size: 16),
                        label: Text(AppLocalizations.of(context)!.approveBtn),
                      ),
                    if (challenge.approved)
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: StudioTheme.warningOrange,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () =>
                            state.setApproval(challenge.id, false),
                        icon: const Icon(Icons.undo_rounded, size: 16),
                        label: Text(AppLocalizations.of(context)!.revokeBtn),
                      ),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  CreateScreen(existing: challenge))),
                      icon: const Icon(Icons.edit_rounded, size: 16),
                      label: Text(AppLocalizations.of(context)!.edit),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        final Map<String, dynamic> output = {
                          "id": challenge.id,
                          "title": challenge.title,
                          "description": challenge.description,
                          "difficulty": challenge.difficulty,
                          "tests": challenge.tests.map((t) => {
                            "input": t.input,
                            "expected_output": t.expectedOutput,
                            if (t.outputFile != null) "output_file": t.outputFile,
                            if (t.isHidden) "hidden": true,
                          }).toList(),

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
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: Colors.white, size: 16),
                                const SizedBox(width: 8),
                                Text(AppLocalizations.of(context)!.copiedJson),
                              ],
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: StudioTheme.accentPurple,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.data_object_rounded, size: 16),
                      label: Text(AppLocalizations.of(context)!.copyJsonBtn),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded,
                          color: StudioTheme.errorRed, size: 20),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
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
                                      style: TextStyle(
                                          color: StudioTheme.errorRed))),
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

