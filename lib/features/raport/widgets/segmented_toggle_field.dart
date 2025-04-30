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

class SegmentedToggleField<T> extends BaseInputField {
  final T? value;
  final List<ToggleOption<T>> options;
  final ValueChanged<T?> onChanged;

  const SegmentedToggleField({
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
    // Get current value index
    final selectedIndex = value != null 
        ? options.indexWhere((option) => option.value == value)
        : -1;
    
    // Get current label if value is set
    final currentOption = selectedIndex >= 0 
        ? options[selectedIndex]
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
          
          // Segmented control style toggle
          Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Row(
                  children: List.generate(options.length, (index) {
                    final option = options[index];
                    final isSelected = selectedIndex == index;
                    
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(option.value),
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(
                            vertical: 2, 
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (isOld ? Colors.indigo.shade200 : Colors.amber.shade500)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (option.icon != null)
                                Icon(
                                  option.icon,
                                  size: 16,
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.grey.shade700,
                                ),
                              Text(
                                option.label,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSelected 
                                      ? FontWeight.bold 
                                      : FontWeight.normal,
                                  color: isSelected 
                                      ? Colors.white 
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
