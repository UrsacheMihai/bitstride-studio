import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:archive/archive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'web_export_stub.dart' if (dart.library.html) 'web_export_html.dart';

import '../providers/studio_state.dart';
import '../models/studio_challenge.dart';
import '../models/studio_course.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({super.key});

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  bool _isExporting = false;
  bool _isImporting = false;

  void _exportContent() async {
    setState(() => _isExporting = true);
    try {
      final state = context.read<StudioState>();
      final archive = Archive();

      // 1. PRACTICE CHALLENGES
      final practiceData = {
        "title": "Practice Challenges",
        "challenges": state.allChallenges.map((c) {
          return {
            "id": c.id,
            "title": c.title,
            "language": c.language,
            "difficulty": c.difficulty,
            "description": c.description,
            "initial_code": c.initialCode,
            "tests": c.tests.map((t) => {
                  "input": t.input,
                  "expected_output": t.expectedOutput,
                  if (t.outputFile != null) "output_file": t.outputFile,
                  "is_hidden": t.isHidden ?? false
                }).toList(),
            if (c.files.isNotEmpty)
              "files": c.files.map((f) => {
                    "name": f.name,
                    "content": f.content,
                  }).toList(),
            "success_mascot": "brain-lifting-weighs.gif",
            "fail_mascot": "brain-sad-dissapointed.gif"
          };
        }).toList(),
      };
      
      final practiceJson = const JsonEncoder.withIndent('  ').convert(practiceData);
      archive.addFile(ArchiveFile('practice_challenges.json', practiceJson.length, utf8.encode(practiceJson)));

      // 2. COURSES
      for (final course in state.courses) {
        final cJson = const JsonEncoder.withIndent('  ').convert(course.toJson());
        final filename = '${course.id}_course.json';
        archive.addFile(ArchiveFile(filename, cJson.length, utf8.encode(cJson)));
      }

      // ENCODE AND DOWNLOAD ZIP
      final zipData = ZipEncoder().encode(archive)!;
      downloadWebZip(zipData, "bitstride_content.zip");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.exportSuccess)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.exportFailed(e.toString()))));
      }
    }
    setState(() => _isExporting = false);
  }

  void _importContent() async {
    setState(() => _isImporting = true);
    try {
      final state = context.read<StudioState>();
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'zip'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.bytes == null) {
          throw Exception("Could not read file bytes.");
        }

        List<ArchiveFile> filesToProcess = [];

        if (file.extension == 'zip') {
          final archive = ZipDecoder().decodeBytes(file.bytes!);
          filesToProcess = archive.where((f) => f.isFile && f.name.endsWith('.json')).toList();
        } else if (file.extension == 'json') {
          filesToProcess.add(ArchiveFile(file.name, file.bytes!.length, file.bytes!));
        }

        int count = 0;
        for (final f in filesToProcess) {
          final content = utf8.decode(f.content as List<int>);
          final data = json.decode(content);

          if (data is Map<String, dynamic>) {
            // Check if it's practice challenges
            if (data.containsKey('challenges')) {
              final challs = data['challenges'] as List<dynamic>;
              for (var c in challs) {
                final challenge = StudioChallenge.fromFirestore(c);
                await state.publishChallenge(challenge);
                count++;
              }
            } 
            // Check if it's a course
            else if (data.containsKey('modules')) {
              final cId = data['id'] ?? f.name.replaceAll('.json', '');
              final course = StudioCourse.fromJson(cId, data);
              await state.saveCourse(course);
              count++;
            }
          }
        }

        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.importSuccess(count))));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.importFailed(e.toString()), style: const TextStyle(color: Colors.red))));
      }
    }
    setState(() => _isImporting = false);
  }

  Future<void> _directDeploy() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('github_pat');
    
    // Prompt for token
    token = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final ctrl = TextEditingController(text: token ?? '');
        return AlertDialog(
          title: Text('GitHub Live Deploy'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your GitHub Personal Access Token (PAT) with repo scope. This overrides bitstride-content main branch instantly.'),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'GitHub Token (ghp_...)', border: OutlineInputBorder()),
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Deploy'),
            )
          ],
        );
      }
    );

    if (token == null || token.isEmpty) return;
    await prefs.setString('github_pat', token);

    setState(() => _isExporting = true);
    try {
      final state = context.read<StudioState>();
      final repo = 'UrsacheMihai/bitstride-content';
      
      // Prepare payloads
      final Map<String, String> uploads = {};
      
      // Practice
      final practiceData = {
        "title": "Practice Challenges",
        "challenges": state.allChallenges.map((c) => {
          "id": c.id, "title": c.title, "language": c.language, "difficulty": c.difficulty,
          "description": c.description, "initial_code": c.initialCode,
          "tests": c.tests.map((t) => {"input": t.input, "expected_output": t.expectedOutput, if (t.outputFile != null) "output_file": t.outputFile, "is_hidden": t.isHidden ?? false}).toList(),
          if (c.files.isNotEmpty) "files": c.files.map((f) => {"name": f.name, "content": f.content}).toList(),
          "success_mascot": "brain-lifting-weighs.gif", "fail_mascot": "brain-sad-dissapointed.gif"
        }).toList(),
      };
      uploads['assets/content/practice_challenges.json'] = const JsonEncoder.withIndent('  ').convert(practiceData);

      // Courses
      for (final course in state.courses) {
        uploads['assets/content/${course.id}_course.json'] = const JsonEncoder.withIndent('  ').convert(course.toJson());
      }

      // Upload one by one via GitHub contents API
      for (final entry in uploads.entries) {
        final path = entry.key;
        final contentStr = entry.value;
        final url = Uri.parse('https://api.github.com/repos/$repo/contents/$path');
        
        // 1. Get SHA to overwrite
        String? sha;
        final getRes = await http.get(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/vnd.github.v3+json'});
        if (getRes.statusCode == 200) {
          sha = json.decode(getRes.body)['sha'];
        }

        // 2. Put
        final body = json.encode({
          'message': 'Auto-deploy from Studio: Update $path',
          'content': base64.encode(utf8.encode(contentStr)),
          if (sha != null) 'sha': sha,
          'branch': 'main'
        });
        final putRes = await http.put(url, headers: {'Authorization': 'Bearer $token', 'Accept': 'application/vnd.github.v3+json'}, body: body);
        
        if (putRes.statusCode < 200 || putRes.statusCode > 299) {
          throw Exception('Failed on $path: \${putRes.body}');
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Succesfully deployed to GitHub!'), backgroundColor: Colors.green));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Deploy Failed: $e'), backgroundColor: Colors.red));
    }
    setState(() => _isExporting = false);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.dataSync,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.syncDescription,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SyncCard(
                  title: AppLocalizations.of(context)!.exportToRepo,
                  description: AppLocalizations.of(context)!.exportDescription,
                  icon: Icons.download,
                  buttonText: AppLocalizations.of(context)!.downloadZip,
                  isLoading: _isExporting,
                  onTap: _exportContent,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _SyncCard(
                  title: AppLocalizations.of(context)!.importFromRepo,
                  description: AppLocalizations.of(context)!.importDescription,
                  icon: Icons.upload,
                  buttonText: AppLocalizations.of(context)!.uploadJsonZip,
                  isLoading: _isImporting,
                  onTap: _importContent,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SyncCard(
             title: 'Live GitHub Deploy',
             description: 'Push changes directly to your bitstride-content Github CDN branch via an API Token.',
             icon: Icons.cloud_upload,
             buttonText: 'Auto-Deploy to GitHub',
             isLoading: _isExporting,
             onTap: _directDeploy,
             color: Colors.green,
          )
        ],
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String buttonText;
  final bool isLoading;
  final VoidCallback onTap;
  final Color color;

  const _SyncCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonText,
    required this.isLoading,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, size: 30, color: color),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLoading ? null : onTap,
                icon: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Icon(icon),
                label: Text(buttonText),
              ),
            )
          ],
        ),
      ),
    );
  }
}
