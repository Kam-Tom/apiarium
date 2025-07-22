
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericInputField extends StatefulWidget {
  final String labelText;
  final String? helperText;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final bool isError;

  const NumericInputField({
    super.key,
    required this.labelText,
    this.helperText,
    required this.value,
    this.min = 0,
    this.max = 999,
    required this.onChanged,
    this.isError = false,
  });

  @override
  State<NumericInputField> createState() => _NumericInputFieldState();
}

class _NumericInputFieldState extends State<NumericInputField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
  }

  @override
  void didUpdateWidget(NumericInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      decoration: InputDecoration(
        labelText: widget.labelText,
        helperText: widget.helperText,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isError ? Colors.red : Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isError ? Colors.red : Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: widget.isError ? Colors.red : Theme.of(context).primaryColor,
          ),
        ),
        helperStyle: TextStyle(
          color: widget.isError ? Colors.red : null,
        ),
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      onChanged: (value) {
        final intValue = int.tryParse(value) ?? widget.min;
        final clampedValue = intValue.clamp(widget.min, widget.max);
        widget.onChanged(clampedValue);
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
