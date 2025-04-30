import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class TextareaInputField extends BaseInputField {
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? hintText;
  final int minLines;
  final int maxLines;

  const TextareaInputField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.onChanged,
    this.hintText,
    this.minLines = 3,
    this.maxLines = 5,
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
    final controller = TextEditingController(text: value ?? '');
    // If value is null, treat as empty string for display and editing
    final hasValue = value != null && value!.isNotEmpty;
    final valueIndicator = isActive && hasValue
        ? Text(
            value!.length > 20 ? '${value!.substring(0, 20)}...' : value!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: stateColor,
            ),
            overflow: TextOverflow.ellipsis,
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
            child: TextFormField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              maxLines: maxLines,
              minLines: minLines,
              style: TextStyle(
                color: isOld ? Colors.grey.shade600 : Colors.black87,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isOld ? Colors.grey.shade400 : Colors.grey.shade300,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isOld ? Colors.grey.shade400 : Colors.grey.shade300,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: stateColor),
                ),
                hintText: hintText ?? 'Enter text...',
              ),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
