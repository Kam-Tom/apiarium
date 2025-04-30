import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberInputField extends BaseInputField {
  final int? value;
  final int min;
  final int max;
  final String? suffix;
  final ValueChanged<int?> onChanged;

  const NumberInputField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.suffix,
  }) : super(
          key: key,
          label: label,
          icon: icon,
          fieldName: fieldName,
          fieldState: fieldState,
          onReset: onReset,
        );

  @override
  Widget build(BuildContext context) {
    // Color logic for value indicator
    Color indicatorColor;
    switch (fieldState) {
      case FieldState.set:
        indicatorColor = Colors.amber.shade800;
        break;
      case FieldState.old:
        indicatorColor = Colors.indigo.shade300.withOpacity(0.65);
        break;
      case FieldState.saved:
        indicatorColor = Colors.green.shade400.withOpacity(0.7);
        break;
      case FieldState.unset:
      default:
        indicatorColor = Colors.grey.shade400;
    }

    final valueIndicator = isActive && value != null
        ? Text(
            suffix != null ? '$value $suffix' : value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: indicatorColor,
            ),
          )
        : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildHeader(valueIndicator: valueIndicator),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: _NumberInputRow(
              value: value,
              min: min,
              max: max,
              suffix: suffix,
              isOld: isOld,
              isSaved: isSaved,
              fieldState: fieldState,
              stateColor: stateColor,
              onChanged: onChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Min: $min',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Max: $max',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NumberInputRow extends StatefulWidget {
  final int? value;
  final int min;
  final int max;
  final String? suffix;
  final bool isOld;
  final bool isSaved;
  final FieldState fieldState;
  final Color stateColor;
  final ValueChanged<int?> onChanged;

  const _NumberInputRow({
    required this.value,
    required this.min,
    required this.max,
    required this.suffix,
    required this.isOld,
    required this.isSaved,
    required this.fieldState,
    required this.stateColor,
    required this.onChanged,
  });

  @override
  State<_NumberInputRow> createState() => _NumberInputRowState();
}

class _NumberInputRowState extends State<_NumberInputRow> {
  late TextEditingController _controller;
  bool _isIncrementing = false;
  bool _isDecrementing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(covariant _NumberInputRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startContinuousUpdate({required bool increment}) async {
    if (increment) {
      _isIncrementing = true;
    } else {
      _isDecrementing = true;
    }
    await Future.delayed(const Duration(milliseconds: 300));
    while ((increment ? _isIncrementing : _isDecrementing) && mounted) {
      final currentValue = widget.value ?? widget.min;
      if (increment) {
        if (currentValue < widget.max) {
          widget.onChanged(currentValue + 1);
        } else {
          break;
        }
      } else {
        if (currentValue > widget.min) {
          widget.onChanged(currentValue - 1);
        } else {
          break;
        }
      }
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _stopContinuousUpdate() {
    _isIncrementing = false;
    _isDecrementing = false;
  }

  Color get _inputTextColor {
    switch (widget.fieldState) {
      case FieldState.set:
        return Colors.grey.shade900;
      case FieldState.old:
        return Colors.indigo.shade300.withOpacity(0.65);
      case FieldState.saved:
        return Colors.green.shade400.withOpacity(0.7);
      case FieldState.unset:
      default:
        return Colors.grey.shade500;
    }
  }

  Color get _iconColor {
    switch (widget.fieldState) {
      case FieldState.set:
        return Colors.amber.shade800;
      case FieldState.old:
        return Colors.indigo.shade300.withOpacity(0.65);
      case FieldState.saved:
        return Colors.green.shade400.withOpacity(0.7);
      case FieldState.unset:
      default:
        return Colors.grey.shade400;
    }
  }

  Color get _iconBgColor {
    switch (widget.fieldState) {
      case FieldState.set:
        return Colors.amber.shade100;
      case FieldState.old:
        return Colors.indigo.shade50.withOpacity(0.35);
      case FieldState.saved:
        return Colors.green.shade50.withOpacity(0.45);
      case FieldState.unset:
      default:
        return Colors.grey.shade100;
    }
  }

  Color get _borderColor {
    switch (widget.fieldState) {
      case FieldState.set:
        return Colors.amber.shade800;
      case FieldState.old:
        return Colors.indigo.shade100.withOpacity(0.5);
      case FieldState.saved:
        return Colors.green.shade400.withOpacity(0.7);
      case FieldState.unset:
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Focus(
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _inputTextColor,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: _borderColor,
                    width: 1.5,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: widget.stateColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                suffix: widget.suffix != null ? Text(widget.suffix!) : null,
                suffixIcon: _buildCounterButtons(),
              ),
              onChanged: (text) {
                if (text.isEmpty) {
                  widget.onChanged(null);
                  return;
                }
                final newValue = int.tryParse(text);
                if (newValue != null && newValue >= widget.min && newValue <= widget.max) {
                  widget.onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildCounterButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: (widget.value ?? widget.min) > widget.min
              ? () => widget.onChanged((widget.value ?? widget.min) - 1)
              : null,
          onLongPress: (widget.value ?? widget.min) > widget.min
              ? () => _startContinuousUpdate(increment: false)
              : null,
          onLongPressEnd: (_) => _stopContinuousUpdate(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
            child: Icon(
              Icons.remove,
              color: (widget.value ?? widget.min) > widget.min
                  ? Colors.grey
                  : Colors.grey.withOpacity(0.3),
              size: 24,
            ),
          ),
        ),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey.shade300,
        ),
        GestureDetector(
          onTap: (widget.value ?? widget.min) < widget.max
              ? () => widget.onChanged((widget.value ?? widget.min) + 1)
              : null,
          onLongPress: (widget.value ?? widget.min) < widget.max
              ? () => _startContinuousUpdate(increment: true)
              : null,
          onLongPressEnd: (_) => _stopContinuousUpdate(),
          child: Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.transparent,
            ),
            child: Icon(
              Icons.add,
              color: (widget.value ?? widget.min) < widget.max
                  ? Colors.grey
                  : Colors.grey.withOpacity(0.3),
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
