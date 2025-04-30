import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class FramesNumericInputField extends StatefulWidget {
  final int? value;
  final int min;
  final int max;
  final FieldState fieldState;
  final String label;
  final IconData icon;
  final VoidCallback onReset;
  final ValueChanged<int?> onChanged;

  const FramesNumericInputField({
    super.key,
    required this.value,
    this.min = 1,
    this.max = 30,
    required this.fieldState,
    required this.label,
    required this.icon,
    required this.onReset,
    required this.onChanged,
  });

  @override
  State<FramesNumericInputField> createState() => _FramesNumericInputFieldState();
}

class _FramesNumericInputFieldState extends State<FramesNumericInputField> {
  bool isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final isActive = widget.fieldState != FieldState.unset;
    Color stateColor;
    switch (widget.fieldState) {
      case FieldState.set:
        stateColor = Colors.amber.shade800;
        break;
      case FieldState.old:
        stateColor = Colors.indigo.shade300;
        break;
      case FieldState.unset:
        stateColor = Colors.grey.shade400;
        break;
      default:
        stateColor = Colors.grey.shade400;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(widget.icon, size: 18, color: stateColor),
          const SizedBox(width: 8),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isActive ? stateColor : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPress: () {
              setState(() => isUpdating = true);
              _startContinuousUpdate(isDecrement: true);
            },
            onLongPressUp: () {
              setState(() => isUpdating = false);
            },
            child: TextButton(
              onPressed: (widget.value ?? widget.min) > widget.min
                  ? () => widget.onChanged((widget.value ?? widget.min) - 1)
                  : null,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '−',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? stateColor : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${widget.value ?? widget.min}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isActive ? stateColor : Colors.grey.shade900,
              ),
            ),
          ),
          GestureDetector(
            onLongPress: () {
              setState(() => isUpdating = true);
              _startContinuousUpdate(isDecrement: false);
            },
            onLongPressUp: () {
              setState(() => isUpdating = false);
            },
            child: TextButton(
              onPressed: (widget.value ?? widget.min) < widget.max
                  ? () => widget.onChanged((widget.value ?? widget.min) + 1)
                  : null,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '+',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isActive ? stateColor : Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const Spacer(),
          if (isActive)
            IconButton(
              onPressed: widget.onReset,
              icon: Icon(
                Icons.refresh,
                color: Colors.grey.shade600,
                size: 18,
              ),
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  void _startContinuousUpdate({required bool isDecrement}) async {
    int currentValue = widget.value ?? widget.min;
    while (isUpdating && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!isUpdating || !mounted) break;
      if (isDecrement) {
        if (currentValue > widget.min) {
          currentValue--;
          widget.onChanged(currentValue);
        } else {
          break;
        }
      } else {
        if (currentValue < widget.max) {
          currentValue++;
          widget.onChanged(currentValue);
        } else {
          break;
        }
      }
    }
  }
}
