import 'package:flutter/material.dart';
import '../../models/studio_challenge.dart';
import '../../services/studio_judge.dart';
import 'package:bitstride_studio/l10n/app_localizations.dart';
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
class _TestCaseCardState extends State<TestCaseCard> {
  late String _inputMode;  
  late String _outputMode; 
  @override
  void initState() {
    super.initState();
    _inputMode = widget.test.inputFile != null && widget.test.inputFile!.isNotEmpty ? 'file' : 'stdin';
    _outputMode = widget.test.outputFile != null && widget.test.outputFile!.isNotEmpty ? 'file' : 'stdout';
  }
  @override
  Widget build(BuildContext context) {
    Color? borderColor;
    if (widget.result != null) {
      borderColor = widget.result!.passed ? const Color(0xFF4CAF50) : Colors.red;
    }
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: borderColor ?? (isDark ? Colors.grey[800]! : Colors.grey[300]!),
          width: borderColor != null ? 2 : 1,
        ),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Test #${widget.index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.result != null)
                  Icon(
                    widget.result!.passed ? Icons.check_circle : Icons.cancel,
                    color: widget.result!.passed ? const Color(0xFF4CAF50) : Colors.red,
                    size: 20,
                  ),
                if (widget.onRemove != null)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: widget.onRemove,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Remove test case',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _SectionHeader(
              icon: Icons.input,
              title: 'Input',
              trailing: _ModeToggle(
                value: _inputMode,
                options: const ['stdin', 'file'],
                labels: const ['stdin', 'File'],
                onChanged: (v) {
                  setState(() {
                    _inputMode = v;
                    if (v == 'stdin') {
                      widget.test.inputFile = null;
                    } else {
                      widget.test.inputFile ??= 'input.txt';
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 6),
            if (_inputMode == 'stdin')
              _MonoField(
                label: 'stdin data',
                value: widget.test.input,
                onChanged: (v) => widget.test.input = v,
                hintText: 'e.g.  3\\n1 2 3',
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _MonoField(
                      label: 'File name',
                      value: widget.test.inputFile ?? 'input.txt',
                      onChanged: (v) => widget.test.inputFile = v.isEmpty ? null : v,
                      hintText: 'e.g. data.in',
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: _MonoField(
                      label: 'File content (becomes input)',
                      value: widget.test.input,
                      onChanged: (v) => widget.test.input = v,
                      hintText: 'Content written to the file before execution',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            _SectionHeader(
              icon: Icons.output,
              title: 'Expected Output',
              trailing: _ModeToggle(
                value: _outputMode,
                options: const ['stdout', 'file'],
                labels: const ['stdout', 'File'],
                onChanged: (v) {
                  setState(() {
                    _outputMode = v;
                    if (v == 'stdout') {
                      widget.test.outputFile = null;
                    } else {
                      widget.test.outputFile ??= 'output.txt';
                    }
                  });
                },
              ),
            ),
            const SizedBox(height: 6),
            if (_outputMode == 'stdout')
              _MonoField(
                label: 'Expected stdout',
                value: widget.test.expectedOutput,
                onChanged: (v) => widget.test.expectedOutput = v,
                hintText: 'e.g.  2 4 6',
              )
            else ...[
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _MonoField(
                      label: 'Output file name',
                      value: widget.test.outputFile ?? 'output.txt',
                      onChanged: (v) => widget.test.outputFile = v.isEmpty ? null : v,
                      hintText: 'e.g. result.out',
                      maxLines: 1,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 5,
                    child: _MonoField(
                      label: 'Expected file content',
                      value: widget.test.expectedOutput,
                      onChanged: (v) => widget.test.expectedOutput = v,
                      hintText: 'Content expected inside the output file',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: widget.test.isHidden,
                  onChanged: (v) => setState(() => widget.test.isHidden = v ?? false),
                ),
                GestureDetector(
                  onTap: () => setState(() => widget.test.isHidden = !widget.test.isHidden),
                  child: Row(
                    children: [
                      Icon(Icons.visibility_off, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text('Hidden test', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    ],
                  ),
                ),
                const Spacer(),
                if (_inputMode == 'file')
                  _IoTag('IN → ${widget.test.inputFile ?? "file"}', Colors.blue),
                if (_outputMode == 'file') ...[
                  const SizedBox(width: 6),
                  _IoTag('OUT → ${widget.test.outputFile ?? "file"}', Colors.teal),
                ],
              ],
            ),
            if (widget.result != null && !widget.result!.passed && widget.result!.actualOutput.isNotEmpty) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Got: ${widget.result!.actualOutput.trim()}',
                  style: const TextStyle(fontSize: 11, color: Colors.red, fontFamily: 'monospace'),
                ),
              ),
            ],
            if (widget.result?.compileError != null && widget.result!.compileError!.isNotEmpty) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.result!.compileError!,
                  style: const TextStyle(fontSize: 11, color: Colors.orange, fontFamily: 'monospace'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  const _SectionHeader({required this.icon, required this.title, required this.trailing});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Colors.grey[600],
            letterSpacing: 0.5,
          ),
        ),
        const Spacer(),
        trailing,
      ],
    );
  }
}
class _ModeToggle extends StatelessWidget {
  final String value;
  final List<String> options;
  final List<String> labels;
  final ValueChanged<String> onChanged;
  const _ModeToggle({
    required this.value,
    required this.options,
    required this.labels,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          final isSelected = value == options[i];
          return GestureDetector(
            onTap: () => onChanged(options[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.4))
                    : null,
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[600],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
class _MonoField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final int maxLines;
  const _MonoField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.maxLines = 2,
  });
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: 1,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 12, height: 1.4),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 11),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      ),
    );
  }
}
class _IoTag extends StatelessWidget {
  final String label;
  final Color color;
  const _IoTag(this.label, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}

