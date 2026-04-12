// Lists and manages extra files uploaded for a challenge.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/challenge/studio_challenge.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';

// Provide interface component for File Row.
class FileRow extends StatefulWidget {
  final StudioFile file;
  final VoidCallback onRemove;

  const FileRow({super.key, required this.file, required this.onRemove});

  @override
  State<FileRow> createState() => _FileRowState();
}

// Manage state and provide providers for File Row State.
class _FileRowState extends State<FileRow> {
  late TextEditingController _nameCtrl;
  late TextEditingController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.file.name);
    _contentCtrl = TextEditingController(text: widget.file.content);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
}