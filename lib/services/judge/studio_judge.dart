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
    List<Map<String, String>> extraFiles, {
    int? timeLimitMs,
    int? memoryLimitMb,
  }) async {
    final runtime = StudioJudgeConfig.runtimes[normalized];
    if (runtime == null) {
      throw Exception('Unsupported language for Piston: $normalized');
    }

    final pistonFiles = <Map<String, String>>[
      {'content': sourceCode},
      ...extraFiles,
    ];

    final body = <String, dynamic>{
      'language': runtime.language,
      'version': runtime.version,
      'files': pistonFiles,
      if (stdin.isNotEmpty) 'stdin': stdin,
      'run_timeout': timeLimitMs ?? 10000,
      'compile_timeout': 30000,
      if (memoryLimitMb != null)
        'run_memory_limit': normalized == 'python'
            ? (memoryLimitMb + 128) * 1024 * 1024
            : (memoryLimitMb + 64) * 1024 * 1024,
    };

    final response = await http.post(
      Uri.parse(StudioJudgeConfig.pistonExecuteUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw Exception('Piston error ${response.statusCode}: ${response.body}');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Extracts the stdout string from the Piston response data.
  String _extractStdout(Map<String, dynamic> data) {
    return (data['run'] as Map<String, dynamic>?)?['stdout'] ?? '';
  }

  // Extracts the compile error string from the Piston response data.
  String _extractCompileError(Map<String, dynamic> data) {
    return (data['compile'] as Map<String, dynamic>?)?['stderr'] ?? '';
  }

  // Extracts the stderr string from the Piston response data.
  String _extractStderr(Map<String, dynamic> data) {
    return (data['run'] as Map<String, dynamic>?)?['stderr'] ?? '';
  }

  // Return true if the process exited with code 0 and no signal.
  bool _exitedClean(Map<String, dynamic> data) {
    final run = data['run'] as Map<String, dynamic>?;
    return run != null && run['code'] == 0 && run['signal'] == null;
  }

  // Detects runtime errors such as TLE, MLE, segfault, and non-zero exit codes.
  String? _detectRuntimeError(
      Map<String, dynamic> data, int? timeLimitMs, int? memoryLimitMb) {
    final run = data['run'] as Map<String, dynamic>?;
    if (run == null) return null;

    final signal = run['signal'] as String?;
    final stderr = ((run['stderr'] as String?) ?? '').toLowerCase();
    final code = run['code'] as int?;

    if (stderr.contains('bad_alloc') ||
        stderr.contains('cannot allocate') ||
        stderr.contains('out of memory') ||
        stderr.contains('memoryerror') ||
        stderr.contains('memory allocation failed')) {
      return '\u{1F4BE} Memory Limit Exceeded${memoryLimitMb != null ? ' ($memoryLimitMb MB)' : ''}';
    }

    if (signal != null) {
      if (signal == 'SIGKILL' || signal == 'SIGXCPU') {
        return '\u23F1 Time Limit Exceeded${timeLimitMs != null ? ' ($timeLimitMs ms)' : ''}';
      }
      if (signal == 'SIGSEGV') {
        return '\u{1F6D1} Runtime Error: Segmentation Fault';
      }
      if (signal == 'SIGFPE') {
        return '\u26A0\uFE0F Runtime Error: Division by Zero';
      }
      if (signal == 'SIGABRT') {
        return '\u{1F6D1} Runtime Error: Aborted';
      }
      return '\u{1F6D1} Runtime Error ($signal)';
    }

    if (code != null && code > 128) {
      final sig = code - 128;
      if (sig == 9) {
        return '\u23F1 Time Limit Exceeded${timeLimitMs != null ? ' ($timeLimitMs ms)' : ''}';
      }
      if (sig == 11) {
        return '\u{1F6D1} Runtime Error: Segmentation Fault';
      }
      if (sig == 8) {
        return '\u26A0\uFE0F Runtime Error: Division by Zero';
      }
      if (sig == 6) {
        return '\u{1F6D1} Runtime Error: Aborted';
      }
      return '\u{1F6D1} Runtime Error (signal $sig)';
    }

    if (stderr.contains('segmentation fault') || stderr.contains('sigsegv')) {
      return '\u{1F6D1} Runtime Error: Segmentation Fault';
    }
    if (stderr.contains('floating point exception')) {
      return '\u26A0\uFE0F Runtime Error: Division by Zero';
    }

    if (code != null && code != 0) {
      return '\u{1F6D1} Runtime Error (exit code $code)';
    }

    return null;
  }

  // Injects file-output capture code into the source for reading named output files.
  String _injectFileCapture(
      String normalized, String outputFile, String sourceCode) {
    if (normalized == 'cpp') {
      return '#include <fstream>\n#include <iostream>\nstruct _FilePrinter {\n    ~_FilePrinter() {\n        std::ifstream ifs("$outputFile");\n        if(ifs.good()) {\n            std::cout << std::endl << "---FILE_OUTPUT_BEGIN---" << std::endl;\n            std::cout << ifs.rdbuf();\n            std::cout << std::endl << "---FILE_OUTPUT_END---" << std::endl;\n        }\n    }\n} _fp;\n$sourceCode';
    } else if (normalized == 'python') {
      return 'import atexit, os, sys\ndef _pf():\n    if os.path.exists(\'$outputFile\'):\n        sys.stdout.flush()\n        print()\n        print("---FILE_OUTPUT_BEGIN---")\n        with open(\'$outputFile\') as f:\n            print(f.read(), end="")\n        print()\n        print("---FILE_OUTPUT_END---")\natexit.register(_pf)\n$sourceCode';
    }
    return sourceCode;
  }

  // Injects input file creation code into the source before the main program.
  String _injectInputFile(
      String normalized, String fileName, String content, String sourceCode) {
    final escaped = content
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '');

    if (normalized == 'cpp') {
      return '#include <fstream>\n'
          '#include <string>\n'
          'namespace _bs_ifw {\n'
          '  struct W {\n'
          '    W() {\n'
          '      std::ofstream f("$fileName");\n'
          '      f << "$escaped";\n'
          '      f.close();\n'
          '    }\n'
          '  } _instance;\n'
          '}\n'
          '$sourceCode';
    } else if (normalized == 'python') {
      return 'open("$fileName", "w").write("$escaped")\n$sourceCode';
    }
    return sourceCode;
  }

  // Injects memory limit enforcement code at the start of the source.
  String _injectMemoryLimit(
      String normalized, int memoryLimitMb, String sourceCode) {
    if (normalized == 'cpp') {
      return '#include <sys/resource.h>\n'
          '#include <unistd.h>\n'
          '#include <fstream>\n'
          '__attribute__((constructor)) void _bs_init_mem_limit() {\n'
          '  unsigned long vsz_pages = 0;\n'
          '  unsigned long startup_bytes = 0;\n'
          '  std::ifstream ifs("/proc/self/statm");\n'
          '  if (ifs >> vsz_pages) {\n'
          '    startup_bytes = vsz_pages * sysconf(_SC_PAGESIZE);\n'
          '  }\n'
          '  if (startup_bytes == 0) {\n'
          '    startup_bytes = 16ULL * 1024 * 1024;\n'
          '  }\n'
          '  unsigned long limit_bytes = startup_bytes + (${memoryLimitMb}ULL * 1024 * 1024);\n'
          '  struct rlimit rl;\n'
          '  rl.rlim_cur = limit_bytes;\n'
          '  rl.rlim_max = limit_bytes;\n'
          '  setrlimit(RLIMIT_AS, &rl);\n'
          '}\n'
          '$sourceCode';
    } else if (normalized == 'python') {
      return 'import resource, os\n'
          'def _bs_init_mem_limit():\n'
          '    try:\n'
          '        with open("/proc/self/statm", "r") as f:\n'
          '            vsz_pages = int(f.read().split()[0])\n'
          '        startup_bytes = vsz_pages * os.sysconf("SC_PAGE_SIZE")\n'
          '        limit_bytes = startup_bytes + ($memoryLimitMb * 1024 * 1024)\n'
          '        soft, hard = resource.getrlimit(resource.RLIMIT_AS)\n'
          '        resource.setrlimit(resource.RLIMIT_AS, (limit_bytes, hard))\n'
          '    except Exception:\n'
          '        fallback = ($memoryLimitMb + 64) * 1024 * 1024\n'
          '        soft, hard = resource.getrlimit(resource.RLIMIT_AS)\n'
          '        resource.setrlimit(resource.RLIMIT_AS, (fallback, hard))\n'
          '_bs_init_mem_limit()\n'
          '$sourceCode';
    }
    return sourceCode;
  }

  // Compare trimmed actual stdout against expected output or file output block.
  bool _matchOutput(String stdout, String expected, String? outputFile) {
    if (outputFile != null) {
      final match = RegExp(
              '---FILE_OUTPUT_BEGIN---\\s+([\\s\\S]*?)\\s*---FILE_OUTPUT_END---')
          .firstMatch(stdout);
      return match != null && (match.group(1) ?? '').trim() == expected.trim();
    }
    return stdout.trim() == expected.trim();
  }
}

// Store the result of a single test case execution.
class TestRunResult {
  final bool passed;
  final String actualOutput;
  final String? compileError;
  final String? error;

  TestRunResult({
    required this.passed,
    required this.actualOutput,
    this.compileError,
    this.error,
  });
}
