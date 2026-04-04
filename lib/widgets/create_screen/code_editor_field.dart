import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CodeEditorField extends StatelessWidget {
  final TextEditingController controller;
  final String language;

  const CodeEditorField({super.key, required this.controller, required this.language});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFF23241f),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Focus(
        onKeyEvent: (node, event) {
          if (event.logicalKey == LogicalKeyboardKey.tab && event is KeyDownEvent) {
            final text = controller.text;
            final selection = controller.selection;
            if (selection.start >= 0 && selection.end >= 0) {
              final newText = text.replaceRange(selection.start, selection.end, '    ');
              controller.value = TextEditingValue(
                text: newText,
                selection: TextSelection.collapsed(offset: selection.start + 4),
              );
            }
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: controller,
          maxLines: null,
          expands: true,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: Colors.white,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12),
          ),
        ),
      ),
    );
  }
}
