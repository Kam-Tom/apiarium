import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/shared/widgets/dropdown/rounded_dropdown.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:flutter/material.dart';

class DropdownInputField extends BaseInputField {
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final String? hintText;
  final Widget Function(BuildContext, String, bool)? itemBuilder;

  const DropdownInputField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText,
    this.itemBuilder,
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
    // Value indicator for header
    final valueIndicator = isActive && value != null
        ? Text(
            _getDisplayValue(value!),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: stateColor,
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
          // Header with label and reset button
          buildHeader(valueIndicator: valueIndicator),
          
          // Dropdown
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: RoundedDropdown<String>(
              value: value,
              items: options,
              hintText: hintText,
              onChanged: onChanged,
              itemBuilder: itemBuilder ?? (context, item, isSelected) {
                return Text(
                  item,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? (isOld ? Colors.indigo.shade300 : AppTheme.primaryColor) : Colors.black,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayValue(String value) {
    return value;
  }
}
