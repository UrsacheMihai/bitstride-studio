import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/studio_state.dart';
import '../models/studio_challenge.dart';
import '../services/studio_judge.dart';
import '../studio_theme.dart';
import '../widgets/create_screen/code_editor_field.dart';
import '../widgets/create_screen/test_case_card.dart';
import '../widgets/create_screen/file_row.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
class CreateScreen extends StatefulWidget {
  final StudioChallenge? existing;
  const CreateScreen({super.key, this.existing});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}
class _CreateScreenState extends State<CreateScreen> with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _codeCppCtrl = TextEditingController();
  final _codePythonCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  String _editorLanguage = 'cpp';
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
      _codeCppCtrl.text = e.initialCodeCpp ?? '';
      _codePythonCtrl.text = e.initialCodePython ?? '';
      _categoryCtrl.text = e.category;
      _methodCtrl.text = e.method;
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
    _codeCppCtrl.dispose();
    _codePythonCtrl.dispose();
    _categoryCtrl.dispose();
    _methodCtrl.dispose();
    super.dispose();
  }
  Future<void> _runTests() async {
    setState(() => _running = true);
    final judge = StudioJudge();
    final sourceCode = _editorLanguage == 'cpp' ? _codeCppCtrl.text : _codePythonCtrl.text;
    final res = await judge.runAll(sourceCode, _editorLanguage, _tests, _files);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.titleRequired),
            ],
          ),
          backgroundColor: StudioTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _publishing = true);
    final autoId = 'uc_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecondsSinceEpoch % 1000)}';
    _assignedId = widget.existing?.id ?? _assignedId ?? autoId;
    final challenge = StudioChallenge(
      id: _assignedId!,
      title: _titleCtrl.text.trim(),
      difficulty: _difficulty,
      category: _categoryCtrl.text.trim(),
      method: _methodCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      initialCodeCpp: _codeCppCtrl.text,
      initialCodePython: _codePythonCtrl.text,
      tests: _tests,
      files: _files,
      creatorUid: widget.existing?.creatorUid ?? state.user!.uid,
      creatorName: widget.existing?.creatorName ?? (state.isAdmin ? 'BitStride Team' : (state.user!.displayName ?? 'Anonymous')),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      approved: widget.existing?.approved ?? false,
    );
    await state.publishChallenge(challenge);
    setState(() => _publishing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.publishedAwaiting),
            ],
          ),
          backgroundColor: StudioTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
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
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: StudioTheme.creatorGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                widget.existing != null ? Icons.edit_note_rounded : Icons.add_box_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.existing != null ? l.editChallenge : l.newChallenge),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: OutlinedButton.icon(
              onPressed: _running ? null : _runTests,
              icon: _running
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(Icons.play_arrow_rounded,
                      size: 18, color: StudioTheme.primaryCyan),
              label: Text(l.testRun,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : null,
                  )),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: FilledButton.icon(
              onPressed: _publishing ? null : _publish,
              icon: _publishing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.upload_rounded, size: 16),
              label: Text(l.publish, style: const TextStyle(fontSize: 13)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: isDark ? StudioTheme.darkBorder : Colors.grey.withOpacity(0.12),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline_rounded, size: 18), text: 'Details'),
            Tab(icon: Icon(Icons.code_rounded, size: 18), text: 'Code & Files'),
            Tab(icon: Icon(Icons.science_rounded, size: 18), text: 'Test Cases'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(theme, l, isDark),
          _buildCodeTab(theme, l, isDark),
          _buildTestsTab(theme, l, isDark),
        ],
      ),
    );
  }
  Widget _buildDetailsTab(ThemeData theme, AppLocalizations l, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _SectionHeader(icon: Icons.title_rounded, label: 'Challenge Identity', isDark: isDark),
        const SizedBox(height: 14),
        TextField(
          controller: _titleCtrl,
          decoration: InputDecoration(
            labelText: l.title,
            hintText: 'e.g. Two Sum Challenge',
            prefixIcon: const Icon(Icons.edit_rounded, size: 18),
          ),
          onChanged: (_) => setState(() {}), 
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
              child: Icon(Icons.description_rounded, size: 18),
            ),
            alignLabelWithHint: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 28),
        _SectionHeader(icon: Icons.tune_rounded, label: 'Classification', isDark: isDark),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: InputDecoration(
                  labelText: l.difficulty,
                  prefixIcon: Icon(
                    Icons.speed_rounded,
                    size: 18,
                    color: _diffColor(_difficulty),
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Easy',
                    child: Row(children: [
                      _DiffDot(color: StudioTheme.successGreen),
                      const SizedBox(width: 8),
                      Text(l.easy),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'Medium',
                    child: Row(children: [
                      _DiffDot(color: StudioTheme.warningOrange),
                      const SizedBox(width: 8),
                      Text(l.medium),
                    ]),
                  ),
                  DropdownMenuItem(
                    value: 'Hard',
                    child: Row(children: [
                      _DiffDot(color: StudioTheme.errorRed),
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
                  prefixIcon: Icon(Icons.category_rounded, size: 18,
                      color: StudioTheme.accentPurple),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _methodCtrl,
                decoration: InputDecoration(
                  labelText: 'Method',
                  hintText: 'e.g. Binary Search, BFS',
                  prefixIcon: Icon(Icons.build_rounded, size: 18,
                      color: const Color(0xFF00897B)),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeader(icon: Icons.preview_rounded, label: 'Live Preview', isDark: isDark),
        const SizedBox(height: 14),
        Container(
          decoration: StudioTheme.glassCard(isDark: isDark, borderRadius: 18),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _titleCtrl.text.isEmpty ? 'Challenge Title' : _titleCtrl.text,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _PreviewTag(_difficulty, _diffColor(_difficulty)),
                  if (_codeCppCtrl.text.trim().isNotEmpty)
                    _PreviewTag('C++', const Color(0xFF00599C)),
                  if (_codePythonCtrl.text.trim().isNotEmpty)
                    _PreviewTag('Python', const Color(0xFF3776AB)),
                  if (_categoryCtrl.text.isNotEmpty)
                    _PreviewTag(_categoryCtrl.text, StudioTheme.accentPurple),
                  if (_methodCtrl.text.isNotEmpty)
                    _PreviewTag(_methodCtrl.text, const Color(0xFF00897B)),
                ],
              ),
              if (_descCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  _descCtrl.text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
  Widget _buildCodeTab(ThemeData theme, AppLocalizations l, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _SectionHeader(icon: Icons.code_rounded, label: l.starterCode, isDark: isDark),
        const SizedBox(height: 6),
        _HintText('This code is used internally for validation. Users in the Core app will NOT see it — they write from scratch.'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'cpp', label: Text('C++ Starter Flow')),
                  ButtonSegment(value: 'python', label: Text('Python Starter Flow')),
                ],
                selected: {_editorLanguage},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _editorLanguage = newSelection.first);
                },
                style: SegmentedButton.styleFrom(
                  visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        CodeEditorField(
          key: ValueKey(_editorLanguage),
          controller: _editorLanguage == 'cpp' ? _codeCppCtrl : _codePythonCtrl,
          language: _editorLanguage,
        ),
        const SizedBox(height: 28),
        _SectionHeader(icon: Icons.attach_file_rounded, label: l.providedFiles, isDark: isDark),
        const SizedBox(height: 6),
        _HintText("Files attached here are available to the user's code at runtime (e.g. data.in, input.txt)."),
        const SizedBox(height: 12),
        ..._files.asMap().entries.map((e) => FileRow(
              key: ObjectKey(e.value),
              file: e.value,
              onRemove: () => setState(() => _files.removeAt(e.key)),
            )),
        OutlinedButton.icon(
          onPressed: () => setState(() => _files.add(StudioFile())),
          icon: const Icon(Icons.add_rounded, size: 18),
          label: Text(l.addProvidedFile),
        ),
      ],
    );
  }
  Widget _buildTestsTab(ThemeData theme, AppLocalizations l, bool isDark) {
    final allPassed = _results.isNotEmpty &&
        _results.every((r) => r?.passed == true);
    final anyRan = _results.any((r) => r != null);
    final passCount = _results.whereType<TestRunResult>().where((r) => r.passed).length;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (anyRan)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: allPassed
                  ? StudioTheme.successGreen.withOpacity(0.08)
                  : StudioTheme.errorRed.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: allPassed
                    ? StudioTheme.successGreen.withOpacity(0.3)
                    : StudioTheme.errorRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  allPassed ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: allPassed ? StudioTheme.successGreen : StudioTheme.errorRed,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  allPassed
                      ? 'All ${_tests.length} tests passed!'
                      : '$passCount/${_tests.length} tests passed',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: allPassed ? StudioTheme.successGreen : StudioTheme.errorRed,
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            _SectionHeader(icon: Icons.science_rounded, label: l.testCases, isDark: isDark),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _tests.add(StudioTestCase());
                _results.add(null);
              }),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l.add, style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
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
      case 'Easy': return StudioTheme.successGreen;
      case 'Medium': return StudioTheme.warningOrange;
      case 'Hard': return StudioTheme.errorRed;
      default: return Colors.grey;
    }
  }
}
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _SectionHeader({required this.icon, required this.label, required this.isDark});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
class _HintText extends StatelessWidget {
  final String text;
  const _HintText(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[500],
        fontStyle: FontStyle.italic,
      ),
    );
  }
}
class _DiffDot extends StatelessWidget {
  final Color color;
  const _DiffDot({required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.4), blurRadius: 4),
        ],
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

