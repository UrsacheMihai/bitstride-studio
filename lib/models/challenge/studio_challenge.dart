// Store the full definition of a challenge, including tests, helper files, and metadata.
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
  final int? memoryLimitMb;
  final int? timeLimitMs;

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
    this.memoryLimitMb,
    this.timeLimitMs,
  });

  // Serialize the challenge to a Firestore-compatible map.
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
      if (memoryLimitMb != null) 'memory_limit_mb': memoryLimitMb,
      if (timeLimitMs != null) 'time_limit_ms': timeLimitMs,
    };
  }
}