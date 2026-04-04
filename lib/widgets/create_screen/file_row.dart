import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/studio_challenge.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FileRow extends StatefulWidget {
  final StudioFile file;
  final VoidCallback onRemove;

  const FileRow({super.key, required this.file, required this.onRemove});

  @override
  State<FileRow> createState() => _FileRowState();
}

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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    onChanged: (v) => widget.file.name = v,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.fileName,
                      hintText: "e.g. data.txt",
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    ),
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                    onPressed: widget.onRemove,
                    color: Colors.red,
                    icon: const Icon(Icons.delete_outline, size: 20)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: const Color(0xFF23241f),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event.logicalKey == LogicalKeyboardKey.tab && event is KeyDownEvent) {
                    final text = _contentCtrl.text;
                    final selection = _contentCtrl.selection;
                    if (selection.start >= 0 && selection.end >= 0) {
                      final newText = text.replaceRange(selection.start, selection.end, '    ');
                      _contentCtrl.value = TextEditingValue(
                        text: newText,
                        selection: TextSelection.collapsed(offset: selection.start + 4),
                      );
                      widget.file.content = newText;
                    }
                    return KeyEventResult.handled;
                  }
                  return KeyEventResult.ignored;
                },
                child: TextField(
                  controller: _contentCtrl,
                  onChanged: (v) => widget.file.content = v,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  decoration: const InputDecoration(
                    hintText: "File content goes here...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
