class StudioChallenge {
  final String id;
  final String title;
  final String difficulty;
  final String category;
  final String method;
  final String description;
  final String? solutionCodeCpp;
  final String? solutionCodePython;
  final List<StudioTestCase> tests;
  final List<StudioFile> files;
  final String creatorUid;
  final String creatorName;
  final DateTime createdAt;
  final bool approved;
  StudioChallenge({
    required this.id,
    required this.title,
    required this.difficulty,
    this.category = '',
    this.method = '',
    required this.description,
    this.solutionCodeCpp,
    this.solutionCodePython,
    required this.tests,
    required this.files,
    required this.creatorUid,
    required this.creatorName,
    required this.createdAt,
    this.approved = false,
  });


  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'title': title,
      'difficulty': difficulty,
      'category': category,
      'method': method,
      'description': description,
      'solution_code_cpp': solutionCodeCpp,
      'solution_code_python': solutionCodePython,
      'tests': tests.map((t) => t.toMap()).toList(),
      'files': files.map((f) => f.toMap()).toList(),
      'creator_uid': creatorUid,
      'creator_name': creatorName,
      'created_at': createdAt.toIso8601String(),
      'approved': approved,
    };
  }

  factory StudioChallenge.fromFirestore(Map<String, dynamic> data) {
    String? cppCode = data['solution_code_cpp'] ?? data['initial_code_cpp'];
    String? pythonCode = data['solution_code_python'] ?? data['initial_code_python'];

    if (data.containsKey('language') && data.containsKey('initial_code')) {
      if (data['language'] == 'cpp') {
        cppCode ??= data['initial_code'];
      } else {
        pythonCode ??= data['initial_code'];
      }
    }

    return StudioChallenge(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      difficulty: data['difficulty'] ?? 'Easy',
      category: data['category'] ?? '',
      method: data['method'] ?? '',
      description: data['description'] ?? '',
      solutionCodeCpp: cppCode,
      solutionCodePython: pythonCode,
      tests: (data['tests'] as List? ?? [])
          .map((t) => StudioTestCase.fromMap(t))
          .toList(),
      files: (data['files'] as List? ?? [])
          .map((f) => StudioFile.fromMap(f))
          .toList(),
      creatorUid: data['creator_uid'] ?? '',
      creatorName: data['creator_name'] ?? 'Anonymous',
      createdAt: DateTime.tryParse(data['created_at'] ?? '') ?? DateTime.now(),
      approved: data['approved'] ?? false,
    );
  }

  bool get hasCpp => solutionCodeCpp != null && solutionCodeCpp!.isNotEmpty;
  bool get hasPython => solutionCodePython != null && solutionCodePython!.isNotEmpty;
}
class StudioTestCase {
  String input;
  String expectedOutput;
  bool isHidden;
  String? inputFile;
  String? outputFile;
  StudioTestCase({
    this.input = '',
    this.expectedOutput = '',
    this.isHidden = false,
    this.inputFile,
    this.outputFile,
  });
  Map<String, dynamic> toMap() => {
    'input': input,
    'expected_output': expectedOutput,
    'is_hidden': isHidden,
    if (inputFile != null) 'input_file': inputFile,
    if (outputFile != null) 'output_file': outputFile,
  };
  factory StudioTestCase.fromMap(Map<String, dynamic> m) => StudioTestCase(
    input: m['input'] ?? '',
    expectedOutput: m['expected_output'] ?? '',
    isHidden: m['is_hidden'] ?? false,
    inputFile: m['input_file'],
    outputFile: m['output_file'],
  );
}
class StudioFile {
  String name;
  String content;
  StudioFile({this.name = '', this.content = ''});
  Map<String, dynamic> toMap() => {'name': name, 'content': content};
  factory StudioFile.fromMap(Map<String, dynamic> m) =>
      StudioFile(name: m['name'] ?? '', content: m['content'] ?? '');
}
