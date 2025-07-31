import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class NumericInputField extends StatefulWidget {
  final String labelText;
  final String? helperText;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final bool isError;
  final bool allowDecimal;
  final bool allowNegative;
  final int decimalPlaces;
  final double step;

  const NumericInputField({
    super.key,
    required this.labelText,
    this.helperText,
    required this.value,
    this.min = 0,
    this.max = 999,
    required this.onChanged,
    this.isError = false,
    this.allowDecimal = false,
    this.allowNegative = false,
    this.decimalPlaces = 2,
    this.step = 1.0,
  });

  @override
  State<NumericInputField> createState() => _NumericInputFieldState();
}

class _NumericInputFieldState extends State<NumericInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  Timer? _incrementTimer;
  Timer? _decrementTimer;
  bool _isUserTyping = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _controller = TextEditingController(text: _getInitialText());
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(NumericInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_isUserTyping) {
      _controller.text = _getDisplayText();
    }
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Format the text when losing focus
      _isUserTyping = false;
      _controller.text = _getDisplayText();
    }
  }

  String _getInitialText() {
    if (widget.value == 0 && !widget.allowNegative) return '';
    return _getDisplayText();
  }

  String _getDisplayText() {
    if (widget.allowDecimal) {
      return widget.value.toStringAsFixed(widget.decimalPlaces);
    } else {
      return widget.value.round().toString();
    }
  }

  void _increment() {
    final currentValue = widget.value;
    final newValue = (currentValue + widget.step).clamp(widget.min, widget.max);
    if (newValue != currentValue) {
      _isUserTyping = false;
      widget.onChanged(newValue);
    }
  }

  void _decrement() {
    final currentValue = widget.value;
    final newValue = (currentValue - widget.step).clamp(widget.min, widget.max);
    if (newValue != currentValue) {
      _isUserTyping = false;
      widget.onChanged(newValue);
    }
  }

  void _startIncrement() {
    _increment();
    _incrementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _increment();
    });
  }

  void _startDecrement() {
    _decrement();
    _decrementTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _decrement();
    });
  }

  void _stopIncrement() {
    _incrementTimer?.cancel();
    _incrementTimer = null;
  }

  void _stopDecrement() {
    _decrementTimer?.cancel();
    _decrementTimer = null;
  }

  String _getInputPattern() {
    if (widget.allowDecimal && widget.allowNegative) {
      return r'^-?\d*\.?\d*$';
    } else if (widget.allowDecimal) {
      return r'^\d*\.?\d*$';
    } else if (widget.allowNegative) {
      return r'^-?\d*$';
    } else {
      return r'^\d*$';
    }
  }

  List<TextInputFormatter> _getInputFormatters() {
    return [
      FilteringTextInputFormatter.allow(RegExp(_getInputPattern())),
      if (widget.allowDecimal)
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (newValue.text.isEmpty) return newValue;

          final parts = newValue.text.split('.');
          if (parts.length > 2) return oldValue;

          if (parts.length == 2 && parts[1].length > widget.decimalPlaces) {
            return oldValue;
          }

          return newValue;
        }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText.isNotEmpty) ...[
          Text(
            widget.labelText,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: widget.isError ? Colors.red : null,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isError ? Colors.red : Colors.grey.shade300,
              width: 1,
            ),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    hintText: widget.allowDecimal ? '0.00' : '0',
                    fillColor: Colors.transparent,
                    filled: true,
                  ),
                  keyboardType: widget.allowDecimal 
                      ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                      : TextInputType.number,
                  inputFormatters: _getInputFormatters(),
                  onChanged: (value) {
                    _isUserTyping = true;
                    
                    if (value.isEmpty) {
                      widget.onChanged(0.0);
                      return;
                    }

                    final doubleValue = double.tryParse(value) ?? 0.0;
                    final clampedValue = doubleValue.clamp(widget.min, widget.max);
                    widget.onChanged(clampedValue);
                  },
                  onEditingComplete: () {
                    // Format when done editing
                    _isUserTyping = false;
                    _controller.text = _getDisplayText();
                  },
                ),
              ),
              GestureDetector(
                onTap: widget.value < widget.max ? _increment : null,
                onLongPressStart: widget.value < widget.max 
                    ? (details) => _startIncrement() 
                    : null,
                onLongPressEnd: (details) => _stopIncrement(),
                onLongPressCancel: _stopIncrement,
                child: Container(
                  width: 40,
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 18,
                    color: widget.value < widget.max 
                        ? Colors.grey.shade700 
                        : Colors.grey.shade400,
                  ),
                ),
              ),
              Container(
                width: 1,
                height: 30,
                color: Colors.grey.shade300,
              ),
              GestureDetector(
                onTap: widget.value > widget.min ? _decrement : null,
                onLongPressStart: widget.value > widget.min 
                    ? (details) => _startDecrement() 
                    : null,
                onLongPressEnd: (details) => _stopDecrement(),
                onLongPressCancel: _stopDecrement,
                child: Container(
                  width: 40,
                  height: 48,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 18,
                    color: widget.value > widget.min 
                        ? Colors.grey.shade700 
                        : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.helperText != null && widget.helperText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: widget.isError ? Colors.red : Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _stopIncrement();
    _stopDecrement();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }
}
