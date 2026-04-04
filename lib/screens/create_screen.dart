import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import '../models/studio_challenge.dart';
import '../services/studio_judge.dart';
import '../widgets/create_screen/code_editor_field.dart';
import '../widgets/create_screen/test_case_card.dart';
import '../widgets/create_screen/file_row.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateScreen extends StatefulWidget {
  final StudioChallenge? existing;
  const CreateScreen({super.key, this.existing});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  String _language = 'cpp';
  String _difficulty = 'Easy';
  List<StudioTestCase> _tests = [StudioTestCase()];
  List<StudioFile> _files = [];
  List<TestRunResult?> _results = [null];
  bool _running = false;
  bool _publishing = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _codeCtrl.text = e.initialCode;
      _categoryCtrl.text = e.category;
      _methodCtrl.text = e.method;
      _language = e.language;
      _difficulty = e.difficulty;
      _tests = List.from(e.tests);
      _files = List.from(e.files);
      _results = List.filled(_tests.length, null, growable: true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _codeCtrl.dispose();
    _categoryCtrl.dispose();
    _methodCtrl.dispose();
    super.dispose();
  }

  Future<void> _runTests() async {
    setState(() => _running = true);
    final judge = StudioJudge();
    final res = await judge.runAll(_codeCtrl.text, _language, _tests, _files);
    setState(() {
      _results = List<TestRunResult?>.from(res, growable: true);
      _running = false;
    });
  }

  String? _assignedId;

  Future<void> _publish() async {
    final state = context.read<StudioState>();
    if (state.user == null) return;
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.titleRequired)));
      return;
    }
    setState(() => _publishing = true);

    final autoId = 'uc_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecondsSinceEpoch % 1000)}';
    _assignedId = widget.existing?.id ?? _assignedId ?? autoId;

    final challenge = StudioChallenge(
      id: _assignedId!,
      title: _titleCtrl.text.trim(),
      language: _language,
      difficulty: _difficulty,
      category: _categoryCtrl.text.trim(),
      method: _methodCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      initialCode: _codeCtrl.text,
      tests: _tests,
      files: _files,
      creatorUid: state.user!.uid,
      creatorName: state.isAdmin ? 'BitStride Team' : (state.user!.displayName ?? 'Anonymous'),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      approved: widget.existing?.approved ?? false,
    );
    await state.publishChallenge(challenge);
    setState(() => _publishing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.publishedAwaiting)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? l.editChallenge : l.newChallenge),
        actions: [
          TextButton.icon(
            onPressed: _running ? null : _runTests,
            icon: _running
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.play_arrow),
            label: Text(l.testRun),
          ),
          const SizedBox(width: 8),
          FilledButton.icon(
            onPressed: _publishing ? null : _publish,
            icon: const Icon(Icons.upload, size: 18),
            label: Text(l.publish),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(icon: Icon(Icons.info_outline, size: 18), text: 'Details'),
            Tab(icon: Icon(Icons.code, size: 18), text: 'Code & Files'),
            Tab(icon: Icon(Icons.science, size: 18), text: 'Test Cases'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(theme, l, isDark),
          _buildCodeTab(theme, l),
          _buildTestsTab(theme, l),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 1: Details — title, language, difficulty, category, method, description
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildDetailsTab(ThemeData theme, AppLocalizations l, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // ── Section: Identity ──
        _SectionLabel(icon: Icons.title, label: 'Challenge Identity'),
        const SizedBox(height: 12),
        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            labelText: l.title,
            hintText: 'e.g. Two Sum Challenge',
            prefixIcon: const Icon(Icons.edit, size: 18),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          maxLines: 5,
          decoration: InputDecoration(
            labelText: l.description,
            hintText: 'Describe what the user needs to solve...',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Icon(Icons.description, size: 18),
            ),
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
        ),

        const SizedBox(height: 28),

        // ── Section: Classification ──
        _SectionLabel(icon: Icons.tune, label: 'Classification'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _language,
                decoration: InputDecoration(
                  labelText: l.language,
                  prefixIcon: Icon(
                    _language == 'cpp' ? Icons.memory : Icons.data_object,
                    size: 18,
                    color: _language == 'cpp'
                        ? const Color(0xFF00599C)
                        : const Color(0xFF3776AB),
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'cpp', child: Text('C++')),
                  DropdownMenuItem(value: 'python', child: Text('Python')),
                ],
                onChanged: (v) => setState(() => _language = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: InputDecoration(
                  labelText: l.difficulty,
                  prefixIcon: Icon(
                    Icons.speed,
                    size: 18,
                    color: _diffColor(_difficulty),
                  ),
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Easy',
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFF4CAF50), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(l.easy),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(l.medium),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'Hard',
                    child: Row(children: [
                      Container(width: 8, height: 8, decoration: BoxDecoration(color: const Color(0xFFE53935), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text(l.hard),
                    ]),
                  ),
                ],
                onChanged: (v) => setState(() => _difficulty = v!),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _categoryCtrl,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Arrays, Trees, DP',
                  prefixIcon: const Icon(Icons.category, size: 18),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _methodCtrl,
                decoration: InputDecoration(
                  labelText: 'Method',
                  hintText: 'e.g. Binary Search, BFS',
                  prefixIcon: const Icon(Icons.build, size: 18),
                  border: const OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Preview card ──
        _SectionLabel(icon: Icons.preview, label: 'Preview'),
        const SizedBox(height: 12),
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _titleCtrl.text.isEmpty ? 'Challenge Title' : _titleCtrl.text,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PreviewTag(_difficulty, _diffColor(_difficulty)),
                    _PreviewTag(_language == 'cpp' ? 'C++' : 'Python', Colors.blueGrey),
                    if (_categoryCtrl.text.isNotEmpty)
                      _PreviewTag(_categoryCtrl.text, Colors.purple),
                    if (_methodCtrl.text.isNotEmpty)
                      _PreviewTag(_methodCtrl.text, Colors.teal),
                  ],
                ),
                if (_descCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _descCtrl.text,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 2: Code & Files — starter code + provided files
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildCodeTab(ThemeData theme, AppLocalizations l) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionLabel(icon: Icons.code, label: l.starterCode),
        const SizedBox(height: 8),
        Text(
          'This code is used internally for validation. Users in the Core app will NOT see it — they write from scratch.',
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        CodeEditorField(controller: _codeCtrl, language: _language),

        const SizedBox(height: 28),

        _SectionLabel(icon: Icons.attach_file, label: l.providedFiles),
        const SizedBox(height: 8),
        Text(
          'Files attached here are available to the user\'s code at runtime (e.g. data.in, input.txt).',
          style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 12),
        ..._files.asMap().entries.map((e) => FileRow(
              key: ObjectKey(e.value),
              file: e.value,
              onRemove: () => setState(() => _files.removeAt(e.key)),
            )),
        OutlinedButton.icon(
          onPressed: () => setState(() => _files.add(StudioFile())),
          icon: const Icon(Icons.add, size: 18),
          label: Text(l.addProvidedFile),
          style: OutlinedButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // TAB 3: Test Cases
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildTestsTab(ThemeData theme, AppLocalizations l) {
    final allPassed = _results.isNotEmpty &&
        _results.every((r) => r?.passed == true);
    final anyRan = _results.any((r) => r != null);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // ── Summary bar ──
        if (anyRan)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: allPassed
                  ? const Color(0xFF4CAF50).withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: allPassed
                    ? const Color(0xFF4CAF50).withOpacity(0.4)
                    : Colors.red.withOpacity(0.4),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  allPassed ? Icons.check_circle : Icons.error,
                  color: allPassed ? const Color(0xFF4CAF50) : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  allPassed
                      ? 'All ${_tests.length} tests passed!'
                      : '${_results.whereType<TestRunResult>().where((r) => r.passed).length}/${_tests.length} tests passed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: allPassed ? const Color(0xFF4CAF50) : Colors.red,
                  ),
                ),
              ],
            ),
          ),

        Row(
          children: [
            _SectionLabel(icon: Icons.science, label: l.testCases),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _tests.add(StudioTestCase());
                _results.add(null);
              }),
              icon: const Icon(Icons.add, size: 16),
              label: Text(l.add, style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._tests.asMap().entries.map((e) => TestCaseCard(
              key: ObjectKey(e.value),
              index: e.key,
              test: e.value,
              result: e.key < _results.length ? _results[e.key] : null,
              onRemove: _tests.length > 1
                  ? () => setState(() {
                        _tests.removeAt(e.key);
                        if (e.key < _results.length) _results.removeAt(e.key);
                      })
                  : null,
            )),
      ],
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy': return const Color(0xFF4CAF50);
      case 'Medium': return Colors.orange;
      case 'Hard': return const Color(0xFFE53935);
      default: return Colors.grey;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// ─── Reusable widgets ────────────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════════════════

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const _SectionLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _PreviewTag extends StatelessWidget {
  final String label;
  final Color color;
  const _PreviewTag(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
