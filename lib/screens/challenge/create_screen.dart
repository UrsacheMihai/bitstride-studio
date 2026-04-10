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
}