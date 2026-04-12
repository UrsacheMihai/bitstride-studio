// Form card for editing test inputs and expected outputs.

import 'package:flutter/material.dart';
import '../../models/challenge/studio_challenge.dart';
import '../../services/judge/studio_judge.dart';

// Test Case definition
class TestCaseCard extends StatefulWidget {
  final int index;
  final StudioTestCase test;
  final TestRunResult? result;
  final VoidCallback? onRemove;

  const TestCaseCard({
    super.key,
    required this.index,
    required this.test,
    this.result,
    this.onRemove,
  });

  @override
  State<TestCaseCard> createState() => _TestCaseCardState();
}

// Test Case definition
class _TestCaseCardState extends State<TestCaseCard> {
  late String _inputMode;
  late String _outputMode;

  @override
  void initState() {
    super.initState();
    _inputMode =
        widget.test.inputFile != null && widget.test.inputFile!.isNotEmpty
            ? 'file'
            : 'stdin';
    _outputMode =
        widget.test.outputFile != null && widget.test.outputFile!.isNotEmpty
            ? 'file'
            : 'stdout';
  }

  @override
  void didUpdateWidget(covariant TestCaseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.test != oldWidget.test) {
      _inputMode =
          widget.test.inputFile != null && widget.test.inputFile!.isNotEmpty
              ? 'file'
              : 'stdin';
      _outputMode =
          widget.test.outputFile != null && widget.test.outputFile!.isNotEmpty
              ? 'file'
              : 'stdout';
    }
  }

  @override
}