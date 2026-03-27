import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/challenge/studio_challenge.dart';
import '../db/studio_firestore.dart';
import './studio_judge_config.dart';

// Execute code against test cases using the Piston code execution API.
class StudioJudge {
  StudioFirestore? _firestoreInstance;
  StudioFirestore get _firestore => _firestoreInstance ??= StudioFirestore();

  // Load the Piston base URL from Firestore if not already resolved.
  Future<void> _ensureFirestoreUrlLoaded() async {
    if (StudioJudgeConfig.firestoreBaseUrl == null) {
      try {
        final url =
            await _firestore.getPistonUrl().timeout(const Duration(seconds: 4));
        if (url != null && url.isNotEmpty) {
          StudioJudgeConfig.setFirestoreBaseUrl(url);
        }
      } catch (_) {}
    }
  }

  // Run all test cases sequentially and collects their results.
  Future<List<TestRunResult>> runAll(
    String code,
    String language,
    List<StudioTestCase> tests,
    List<StudioFile> files, {
    int? timeLimitMs,
    int? memoryLimitMb,
  }) async {
    final results = <TestRunResult>[];
    for (final test in tests) {
      results.add(await _run(code, language, test, files,
          timeLimitMs: timeLimitMs, memoryLimitMb: memoryLimitMb));
    }
    return results;
  }

  // Normalizes the language string to a canonical Piston key.
  static String _normalize(String lang) {
    switch (lang.toLowerCase().trim()) {
      case 'c++':
      case 'cpp':
      case 'c':
        return 'cpp';
      case 'python':
      case 'py':
      case 'python3':
        return 'python';
      default:
        return lang.toLowerCase();
    }
  }

  // Execute a single test case and return the pass/fail result with output.
  Future<TestRunResult> _run(
    String code,
    String language,
    StudioTestCase test,
    List<StudioFile> files, {
    int? timeLimitMs,
    int? memoryLimitMb,
  }) async {
    await _ensureFirestoreUrlLoaded();

    final normalized = _normalize(language);
    String finalCode = code;

    if (test.outputFile != null) {
      finalCode = _injectFileCapture(normalized, test.outputFile!, code);
    }

    final extraFiles =
        files.map((f) => {'name': f.name, 'content': f.content}).toList();

    String stdinData = test.input.replaceAll('\r', '');
    if (test.inputFile != null && test.inputFile!.isNotEmpty) {
      finalCode =
          _injectInputFile(normalized, test.inputFile!, test.input, finalCode);
      stdinData = '';
    }

    if (memoryLimitMb != null) {
      finalCode = _injectMemoryLimit(normalized, memoryLimitMb, finalCode);
    }

    try {
      final data = await _executePiston(
          normalized, finalCode, stdinData, extraFiles,
          timeLimitMs: timeLimitMs, memoryLimitMb: memoryLimitMb);

      final stdout = _extractStdout(data);
      final stderr = _extractStderr(data);
      final compileErr = _extractCompileError(data);
      final runtimeError =
          _detectRuntimeError(data, timeLimitMs, memoryLimitMb);
      bool passed = runtimeError == null && _exitedClean(data);

      if (passed) {
        passed = _matchOutput(stdout, test.expectedOutput, test.outputFile);
      }

      return TestRunResult(
        passed: passed,
        actualOutput: stdout,
        compileError: compileErr.isNotEmpty ? compileErr : null,
        error: runtimeError != null
            ? (stderr.isNotEmpty ? '$runtimeError\n$stderr' : runtimeError)
            : (stderr.isNotEmpty ? stderr : null),
      );
    } catch (e) {
      return TestRunResult(
          passed: false, actualOutput: '', error: e.toString());
    }
  }

  // Sends the execution payload to Piston and return the raw JSON response.
  Future<Map<String, dynamic>> _executePiston(
    String normalized,
    String sourceCode,
    String stdin,
}