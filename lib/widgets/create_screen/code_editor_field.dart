// Custom text editor with line numbers for writing code.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Provide interface component for Code Editor Field.
class CodeEditorField extends StatelessWidget {
  final TextEditingController controller;
  final String language;

  const CodeEditorField(
      {super.key, required this.controller, required this.language});

  @override
}