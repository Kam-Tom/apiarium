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

class RadioListField<T> extends BaseInputField {
  final T? value;
  final List<ToggleOption<T>> options;
  final ValueChanged<T?> onChanged;

  const RadioListField({
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
          
          // Radio list toggle options
          Container(
            margin: const EdgeInsets.only(top: 8),
            child: Column(
              children: options.map((option) {
                final isSelected = isActive && value != null && value == option.value;
                
                return InkWell(
                  onTap: () => onChanged(option.value),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Row(
                      children: [
                        Radio<T>(
                          value: option.value,
                          groupValue: value,
                          onChanged: (val) => onChanged(val),
                          activeColor: isOld ? Colors.indigo.shade300 : Colors.amber.shade700,
                        ),
                        if (option.icon != null) ...[
                          Icon(
                            option.icon,
                            size: 20,
                            color: isSelected 
                                ? (isOld ? Colors.indigo.shade300 : Colors.amber.shade700)
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          option.label,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected 
                                ? FontWeight.bold 
                                : FontWeight.normal,
                            color: isSelected 
                                ? (isOld ? Colors.indigo.shade300 : Colors.amber.shade800)
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
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
