import 'package:flutter/material.dart';
import 'package:wattwais/core/theme/app_theme.dart';

class ValuePill extends StatelessWidget {
  const ValuePill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: AppColors.mutedBorder, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditableValuePill extends StatefulWidget {
  const EditableValuePill({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.keyboardType = TextInputType.number,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final int? min;
  final int? max;
  final TextInputType keyboardType;

  @override
  State<EditableValuePill> createState() => _EditableValuePillState();
}

class _EditableValuePillState extends State<EditableValuePill> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) _commit();
    });
  }

  @override
  void didUpdateWidget(covariant EditableValuePill oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _commit() {
    final raw = _controller.text.trim();
    final parsed = int.tryParse(raw);
    if (parsed == null) {
      _controller.text = widget.value.toString();
      return;
    }

    var next = parsed;
    if (widget.min != null) next = next < widget.min! ? widget.min! : next;
    if (widget.max != null) next = next > widget.max! ? widget.max! : next;

    if (next != widget.value) {
      widget.onChanged(next);
    } else {
      _controller.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(AppSpacing.pillRadius),
        border: Border.all(color: AppColors.mutedBorder, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 11,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: 20,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: widget.keyboardType,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
              onSubmitted: (_) => _commit(),
            ),
          ),
        ],
      ),
    );
  }
}
