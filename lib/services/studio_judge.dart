import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/studio_challenge.dart';
class StudioJudge {
  static const String _wandbox = 'https://wandbox.org/api/compile.json';
  Future<List<TestRunResult>> runAll(
    String code,
    String language,
    List<StudioTestCase> tests,
    List<StudioFile> files,
  ) async {
    final results = <TestRunResult>[];
    for (final test in tests) {
      results.add(await _run(code, language, test, files));
    }
    return results;
  }
  Future<TestRunResult> _run(
    String code,
    String language,
    StudioTestCase test,
    List<StudioFile> files,
  ) async {
    final compiler = language == 'cpp' ? 'gcc-head' : 'cpython-3.14.0';
    String finalCode = code;
    if (test.outputFile != null) {
      if (language == 'cpp') {
        finalCode = '#include <fstream>\n#include <iostream>\nstruct _FilePrinter {\n    ~_FilePrinter() {\n        std::ifstream ifs("${test.outputFile}");\n        if(ifs.good()) {\n            std::cout << std::endl << "---FILE_OUTPUT_BEGIN---" << std::endl;\n            std::cout << ifs.rdbuf();\n            std::cout << std::endl << "---FILE_OUTPUT_END---" << std::endl;\n        }\n    }\n} _fp;\n'
            + code;
      } else {
        finalCode = 'import atexit, os, sys\ndef _pf():\n    if os.path.exists(\'${test.outputFile}\'):\n        sys.stdout.flush()\n        print()\n        print("---FILE_OUTPUT_BEGIN---")\n        with open(\'${test.outputFile}\') as f:\n            print(f.read(), end="")\n        print()\n        print("---FILE_OUTPUT_END---")\natexit.register(_pf)\n'
            + code;
      }
    }
    final extraFiles = files.map((f) => {'file': f.name, 'code': f.content}).toList();
    String stdinData = test.input;
    if (test.inputFile != null && test.inputFile!.isNotEmpty) {
      extraFiles.add({'file': test.inputFile!, 'code': test.input});
      stdinData = ''; 
    }
    final body = <String, dynamic>{
      'compiler': compiler,
      'code': finalCode,
      'stdin': stdinData,
      if (extraFiles.isNotEmpty) 'codes': extraFiles,
    };
    try {
      final res = await http.post(
        Uri.parse(_wandbox),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final data = jsonDecode(res.body);
      final stdout = data['program_output'] ?? '';
      final compileErr = data['compiler_error'] ?? '';
      final status = data['status']?.toString() ?? '-1';
      bool passed = status == '0';
      if (passed) {
        if (test.outputFile != null) {
          final match = RegExp(
                  '---FILE_OUTPUT_BEGIN---\\s+([\\s\\S]*?)\\s*---FILE_OUTPUT_END---')
              .firstMatch(stdout);
          passed = match != null &&
              (match.group(1) ?? '').trim() == test.expectedOutput.trim();
        } else {
          passed = stdout.trim() == test.expectedOutput.trim();
        }
      }
      return TestRunResult(
        passed: passed,
        actualOutput: stdout,
        compileError: compileErr,
      );
    } catch (e) {
      return TestRunResult(passed: false, actualOutput: '', error: e.toString());
    }
  }
}
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

