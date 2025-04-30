import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class ToggleOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const ToggleOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class ChipToggleField<T> extends BaseInputField {
  final T? value;
  final List<ToggleOption<T>> options;
  final ValueChanged<T?> onChanged;

  const ChipToggleField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.options,
    required this.onChanged,
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
    // Get current label if value is set
    final currentOption = value != null 
        ? options.firstWhere(
            (option) => option.value == value,
            orElse: () => ToggleOption<T>(
              value: value as T, 
              label: 'Unknown'
            ),
          )
        : null;
    
    // Prepare value indicator for the header
    final valueIndicator = isActive && currentOption != null
        ? Text(
            currentOption.label,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with label and reset button
          buildHeader(valueIndicator: valueIndicator),
          
          // Chip-style toggle buttons
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = isActive && value != null && value == option.value;
                
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (option.icon != null) ...[
                        Icon(
                          option.icon,
                          size: 16,
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(option.label),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (_) => onChanged(option.value),
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: isOld ? Colors.indigo.shade200 : Colors.amber.shade400,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey.shade800,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected 
                          ? (isOld ? Colors.indigo.shade300 : Colors.amber.shade500) 
                          : Colors.grey.shade300,
                      width: 1,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
