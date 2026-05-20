// Provide an editor screen for creating and configuring coding challenges.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/studio/studio_state.dart';
import '../../models/challenge/studio_challenge.dart';
import '../../services/judge/studio_judge.dart';
import '../../theme/studio_theme.dart';
import '../../widgets/create_screen/code_editor_field.dart';
import '../../widgets/create_screen/test_case_card.dart';
import '../../widgets/create_screen/file_row.dart';
import '../../widgets/glass/glass_app_bar.dart';
import '../../widgets/common/studio_user_actions.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Render layout and manage state for Create Screen.
class CreateScreen extends StatefulWidget {
  final StudioChallenge? existing;

  const CreateScreen({super.key, this.existing});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

// Manage state and provide providers for Create Screen State.
class _CreateScreenState extends State<CreateScreen>
    with SingleTickerProviderStateMixin {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _solCppCtrl = TextEditingController();
  final _solPythonCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  String _editorLanguage = 'cpp';
  String _difficulty = 'Easy';
  List<StudioTestCase> _tests = [StudioTestCase()];
  List<StudioFile> _files = [];
  List<TestRunResult?> _resultsCpp = [null];
  List<TestRunResult?> _resultsPython = [null];
  String _resultsLanguage = 'cpp';
  bool _running = false;
  bool _publishing = false;
  late TabController _tabController;
  final _memoryLimitCtrl = TextEditingController();
  final _timeLimitCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    final e = widget.existing;
    if (e != null) {
      _titleCtrl.text = e.title;
      _descCtrl.text = e.description;
      _solCppCtrl.text = e.solutionCodeCpp ?? '';
      _solPythonCtrl.text = e.solutionCodePython ?? '';
      _categoryCtrl.text = e.category;
      _methodCtrl.text = e.method;
      _difficulty = e.difficulty;
      _tests = List.from(e.tests);
      _files = List.from(e.files);
      _resultsCpp = List.filled(_tests.length, null, growable: true);
      _resultsPython = List.filled(_tests.length, null, growable: true);
      if (e.memoryLimitMb != null)
        _memoryLimitCtrl.text = e.memoryLimitMb.toString();
      if (e.timeLimitMs != null) _timeLimitCtrl.text = e.timeLimitMs.toString();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _solCppCtrl.dispose();
    _solPythonCtrl.dispose();
    _categoryCtrl.dispose();
    _methodCtrl.dispose();
    _memoryLimitCtrl.dispose();
    _timeLimitCtrl.dispose();
    super.dispose();
  }

  Future<void> _runTests() async {
    setState(() => _running = true);
    final judge = StudioJudge();
    
    final cppCode = _solCppCtrl.text.trim();
    final pythonCode = _solPythonCtrl.text.trim();
    
    final futures = <Future<void>>[];
    
    if (cppCode.isNotEmpty) {
      futures.add(
        judge.runAll(
          cppCode,
          'cpp',
          _tests,
          _files,
          timeLimitMs: int.tryParse(_timeLimitCtrl.text),
          memoryLimitMb: int.tryParse(_memoryLimitCtrl.text),
        ).then((res) {
          setState(() {
            _resultsCpp = List<TestRunResult?>.from(res, growable: true);
          });
        }),
      );
    } else {
      setState(() {
        _resultsCpp = List.filled(_tests.length, null, growable: true);
      });
    }
    
    if (pythonCode.isNotEmpty) {
      futures.add(
        judge.runAll(
          pythonCode,
          'python',
          _tests,
          _files,
          timeLimitMs: int.tryParse(_timeLimitCtrl.text),
          memoryLimitMb: int.tryParse(_memoryLimitCtrl.text),
        ).then((res) {
          setState(() {
            _resultsPython = List<TestRunResult?>.from(res, growable: true);
          });
        }),
      );
    } else {
      setState(() {
        _resultsPython = List.filled(_tests.length, null, growable: true);
      });
    }
    
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
    
    setState(() {
      _running = false;
      if (cppCode.isNotEmpty && _editorLanguage == 'cpp') {
        _resultsLanguage = 'cpp';
      } else if (pythonCode.isNotEmpty && _editorLanguage == 'python') {
        _resultsLanguage = 'python';
      } else if (cppCode.isNotEmpty) {
        _resultsLanguage = 'cpp';
      } else if (pythonCode.isNotEmpty) {
        _resultsLanguage = 'python';
      }
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
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.titleRequired),
            ],
          ),
          backgroundColor: StudioTheme.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    setState(() => _publishing = true);
    final autoId =
        'uc_${DateTime.now().millisecondsSinceEpoch}_${(DateTime.now().microsecondsSinceEpoch % 1000)}';
    _assignedId = widget.existing?.id ?? _assignedId ?? autoId;
    final challenge = StudioChallenge(
      id: _assignedId!,
      title: _titleCtrl.text.trim(),
      difficulty: _difficulty,
      category: _categoryCtrl.text.trim(),
      method: _methodCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      solutionCodeCpp: _solCppCtrl.text,
      solutionCodePython: _solPythonCtrl.text,
      tests: _tests,
      files: _files,
      creatorUid: widget.existing?.creatorUid ?? state.user!.uid,
      creatorName: widget.existing?.creatorName ??
          (state.isAdmin
              ? 'BitStride Team'
              : (state.user!.displayName ?? 'Anonymous')),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      approved: widget.existing?.approved ?? false,
      memoryLimitMb: int.tryParse(_memoryLimitCtrl.text),
      timeLimitMs: int.tryParse(_timeLimitCtrl.text),
    );
    await state.publishChallenge(challenge);
    setState(() => _publishing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(AppLocalizations.of(context)!.publishedAwaiting),
            ],
          ),
          backgroundColor: StudioTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final double topPad =
        MediaQuery.of(context).padding.top + kToolbarHeight + 72.0;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                gradient: StudioTheme.creatorGradient,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: StudioTheme.accentPurple.withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                widget.existing != null
                    ? Icons.edit_note_rounded
                    : Icons.add_box_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(widget.existing != null ? l.editChallenge : l.newChallenge),
          ],
        ),
        actions: [
          _AppBarActionButton(
            onPressed: _running ? null : _runTests,
            loading: _running,
            icon: Icons.play_arrow_rounded,
            label: l.testRun,
            color: StudioTheme.primaryCyan,
            isDark: isDark,
          ),
          const SizedBox(width: 6),
          _AppBarActionButton(
            onPressed: _publishing ? null : _publish,
            loading: _publishing,
            icon: Icons.upload_rounded,
            label: l.publish,
            filled: true,
            color: StudioTheme.primaryCyan,
            isDark: isDark,
          ),
          const SizedBox(width: 8),
          const StudioUserActions(),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: primary,
          indicatorSize: TabBarIndicatorSize.label,
          indicatorWeight: 3,
          dividerColor:
              isDark ? StudioTheme.darkBorder : StudioTheme.lightBorder,
          labelColor: primary,
          unselectedLabelColor:
              isDark ? const Color(0xFF4A5568) : const Color(0xFF8B9AB0),
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          unselectedLabelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          tabs: const [
            Tab(
                icon: Icon(Icons.info_outline_rounded, size: 17),
                text: 'Details'),
            Tab(icon: Icon(Icons.code_rounded, size: 17), text: 'Code'),
            Tab(icon: Icon(Icons.science_rounded, size: 17), text: 'Tests'),
          ],
        ),
      ),
      body: Container(
        decoration: StudioTheme.meshBackground(isDark: isDark),
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildDetailsTab(theme, l, isDark, topPad),
            _buildCodeTab(theme, l, isDark, topPad),
            _buildTestsTab(theme, l, isDark, topPad),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab(
      ThemeData theme, AppLocalizations l, bool isDark, double topPad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 40),
      children: [
        _SectionHeader(
            icon: Icons.title_rounded,
            label: 'Challenge Identity',
            isDark: isDark),
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
          maxLines: null,
          minLines: 3,
          decoration: InputDecoration(
            labelText: l.description,
            hintText:
                'Describe what the user needs to solve... (supports **markdown**)',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(bottom: 80),
              child: Icon(Icons.description_rounded, size: 18),
            ),
            alignLabelWithHint: true,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 28),
        _SectionHeader(
            icon: Icons.tune_rounded, label: 'Classification', isDark: isDark),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
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
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _categoryCtrl,
                decoration: InputDecoration(
                  labelText: 'Category',
                  hintText: 'e.g. Arrays, Trees, DP',
                  prefixIcon: Icon(Icons.category_rounded,
                      size: 18, color: StudioTheme.accentPurple),
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
                  hintText: 'e.g. Binary Search',
                  prefixIcon: Icon(Icons.build_rounded,
                      size: 18, color: StudioTheme.primaryTeal),
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeader(
            icon: Icons.timer_rounded,
            label: 'Constraints (Optional)',
            isDark: isDark),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _timeLimitCtrl,
                decoration: InputDecoration(
                  labelText: 'Time Limit (ms)',
                  hintText: 'e.g. 1000',
                  prefixIcon: Icon(Icons.timer_outlined,
                      size: 18, color: StudioTheme.primaryCyan),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _memoryLimitCtrl,
                decoration: InputDecoration(
                  labelText: 'Memory Limit (MB)',
                  hintText: 'e.g. 256',
                  prefixIcon: Icon(Icons.memory_rounded,
                      size: 18, color: StudioTheme.accentPurple),
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        _SectionHeader(
            icon: Icons.preview_rounded, label: 'Live Preview', isDark: isDark),
        const SizedBox(height: 14),
        _LivePreview(
          title: _titleCtrl.text,
          description: _descCtrl.text,
          difficulty: _difficulty,
          hasCpp: _solCppCtrl.text.trim().isNotEmpty,
          hasPython: _solPythonCtrl.text.trim().isNotEmpty,
          category: _categoryCtrl.text,
          method: _methodCtrl.text,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildCodeTab(
      ThemeData theme, AppLocalizations l, bool isDark, double topPad) {
    return ListView(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 40),
      children: [
        _SectionHeader(
            icon: Icons.lock_rounded, label: 'Solution Code', isDark: isDark),
        const SizedBox(height: 8),
        _HintBanner(
          icon: Icons.lock_outlined,
          text:
              'This code is private — used ONLY for validation. Users in the Core app will NOT see it.',
          color: StudioTheme.accentPurple,
          isDark: isDark,
        ),
        const SizedBox(height: 16),
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
                value: 'cpp',
                label: Text(l.cppSolution),
                icon: const Icon(Icons.code_rounded, size: 16)),
            ButtonSegment(
                value: 'python',
                label: Text(l.pythonSolution),
                icon: const Icon(Icons.terminal_rounded, size: 16)),
          ],
          selected: {_editorLanguage},
          onSelectionChanged: (Set<String> s) =>
              setState(() => _editorLanguage = s.first),
          style: SegmentedButton.styleFrom(
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
        CodeEditorField(
          key: ValueKey(_editorLanguage),
          controller: _editorLanguage == 'cpp' ? _solCppCtrl : _solPythonCtrl,
          language: _editorLanguage,
        ),
        const SizedBox(height: 28),
        _SectionHeader(
            icon: Icons.attach_file_rounded,
            label: l.providedFiles,
            isDark: isDark),
        const SizedBox(height: 8),
        _HintBanner(
          icon: Icons.folder_open_outlined,
          text:
              "Files attached here are available to the user's code at runtime (e.g. data.in, input.txt).",
          color: StudioTheme.primaryTeal,
          isDark: isDark,
        ),
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

  Widget _buildTestsTab(
      ThemeData theme, AppLocalizations l, bool isDark, double topPad) {
    final activeResults = _resultsLanguage == 'cpp' ? _resultsCpp : _resultsPython;
    final allPassed =
        activeResults.isNotEmpty && activeResults.every((r) => r?.passed == true);
    final anyRan = activeResults.any((r) => r != null);
    final passCount =
        activeResults.whereType<TestRunResult>().where((r) => r.passed).length;

    return ListView(
      padding: EdgeInsets.fromLTRB(20, topPad + 16, 20, 40),
      children: [
        if (anyRan) ...[
          _TestSummaryBanner(
            allPassed: allPassed,
            passCount: passCount,
            total: _tests.length,
          ),
          const SizedBox(height: 16),
        ],
        SegmentedButton<String>(
          segments: [
            ButtonSegment(
                value: 'cpp',
                label: const Text('C++ Results'),
                icon: const Icon(Icons.code_rounded, size: 16)),
            ButtonSegment(
                value: 'python',
                label: const Text('Python Results'),
                icon: const Icon(Icons.terminal_rounded, size: 16)),
          ],
          selected: {_resultsLanguage},
          onSelectionChanged: (Set<String> s) =>
              setState(() => _resultsLanguage = s.first),
          style: SegmentedButton.styleFrom(
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _SectionHeader(
                icon: Icons.science_rounded,
                label: l.testCases,
                isDark: isDark),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: () => setState(() {
                _tests.add(StudioTestCase());
                _resultsCpp.add(null);
                _resultsPython.add(null);
              }),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: Text(l.add, style: const TextStyle(fontSize: 13)),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._tests.asMap().entries.map((e) => TestCaseCard(
              key: ObjectKey(e.value),
              index: e.key,
              test: e.value,
              result: e.key < activeResults.length ? activeResults[e.key] : null,
              onRemove: _tests.length > 1
                  ? () => setState(() {
                        _tests.removeAt(e.key);
                        if (e.key < _resultsCpp.length) _resultsCpp.removeAt(e.key);
                        if (e.key < _resultsPython.length) _resultsPython.removeAt(e.key);
                      })
                  : null,
            )),
      ],
    );
  }

  Color _diffColor(String d) {
    switch (d) {
      case 'Easy':
        return StudioTheme.successGreen;
      case 'Medium':
        return StudioTheme.warningOrange;
      case 'Hard':
        return StudioTheme.errorRed;
      default:
        return Colors.grey;
    }
  }
}

// Provide interface component for App Bar Action Button.
class _AppBarActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final IconData icon;
  final String label;
  final bool filled;
  final Color color;
  final bool isDark;

  const _AppBarActionButton({
    required this.onPressed,
    required this.loading,
    required this.icon,
    required this.label,
    this.filled = false,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? Colors.white.withOpacity(0.85) : StudioTheme.darkBg;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: filled
          ? FilledButton.icon(
              onPressed: onPressed,
              icon: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Icon(icon, size: 16),
              label: Text(label, style: const TextStyle(fontSize: 12)),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: loading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(icon, size: 16, color: color),
              label:
                  Text(label, style: TextStyle(fontSize: 12, color: textColor)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
    );
  }
}

// Render a live preview of the challenge description.
class _LivePreview extends StatelessWidget {
  final String title;
  final String description;
  final String difficulty;
  final bool hasCpp;
  final bool hasPython;
  final String category;
  final String method;
  final bool isDark;

  const _LivePreview({
    required this.title,
    required this.description,
    required this.difficulty,
    required this.hasCpp,
    required this.hasPython,
    required this.category,
    required this.method,
    required this.isDark,
  });

  Color get _diffColor {
    switch (difficulty) {
      case 'Easy':
        return StudioTheme.successGreen;
      case 'Medium':
        return StudioTheme.warningOrange;
      case 'Hard':
        return StudioTheme.errorRed;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: StudioTheme.solidCard(isDark: isDark, borderRadius: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _diffColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _diffColor.withOpacity(0.5), blurRadius: 6),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title.isEmpty ? 'Challenge Title' : title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: isDark ? Colors.white : StudioTheme.darkBg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _PreviewTag(difficulty, _diffColor),
              if (hasCpp) const _PreviewTag('C++', Color(0xFF00599C)),
              if (hasPython) const _PreviewTag('Python', Color(0xFF3776AB)),
              if (category.isNotEmpty)
                _PreviewTag(category, StudioTheme.accentPurple),
              if (method.isNotEmpty)
                _PreviewTag(method, StudioTheme.primaryTeal),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color:
                    isDark ? const Color(0xFF6B7A99) : const Color(0xFF8B9AB0),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Render a summary banner of test run results.
class _TestSummaryBanner extends StatelessWidget {
  final bool allPassed;
  final int passCount;
  final int total;

  const _TestSummaryBanner({
    required this.allPassed,
    required this.passCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final color = allPassed ? StudioTheme.successGreen : StudioTheme.errorRed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.30)),
      ),
      child: Row(
        children: [
          Icon(
            allPassed ? Icons.check_circle_rounded : Icons.error_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Text(
            allPassed
                ? 'All $total tests passed!'
                : '$passCount/$total tests passed',
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

// Render a collapsible hint banner for challenge creation guidance.
class _HintBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final bool isDark;

  const _HintBanner({
    required this.icon,
    required this.text,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color.withOpacity(0.8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color:
                    isDark ? const Color(0xFF6B7A99) : const Color(0xFF8B9AB0),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Render a section title header inside the create form.
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _SectionHeader(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: primary),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : StudioTheme.darkBg,
          ),
        ),
      ],
    );
  }
}

// Render a colored dot indicating difficulty level.
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

// Render a small tag label used in the challenge preview card.
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
        border: Border.all(color: color.withOpacity(0.30)),
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
