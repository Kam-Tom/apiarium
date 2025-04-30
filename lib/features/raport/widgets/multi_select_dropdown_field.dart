import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/shared/widgets/dropdown/rounded_dropdown.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class MultiSelectDropdownField extends BaseInputField {
  final List<String> values;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;
  final String? hintText;

  const MultiSelectDropdownField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.values,
    required this.options,
    required this.onChanged,
    this.hintText,
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
    final effectiveValues = values.isEmpty ? ["none"] : values;
    final displayValue = effectiveValues.join(", ");

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
          buildHeader(
            valueIndicator: isActive
                ? Text(
                    displayValue,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: stateColor,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 8),
          _buildMultiSelectUI(context),
        ],
      ),
    );
  }

  Widget _buildMultiSelectUI(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        final bool isSelected = values.contains(option) || 
            (option == "none" && values.isEmpty);
        
        return CheckboxListTile(
          title: Text(
            option,
            style: TextStyle(
              color: isOld ? Colors.grey.shade600 : Colors.black87,
            ),
          ),
          value: isSelected,
          activeColor: isOld ? Colors.indigo.shade300 : Colors.amber.shade600,
          dense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          controlAffinity: ListTileControlAffinity.leading,
          onChanged: (selected) {
            List<String> newValues = List.from(values);
            
            // Handle the "none" option specially
            if (option == "none") {
              if (selected == true) {
                newValues = ["none"];
              } else {
                newValues.remove("none");
              }
            } else {
              if (selected == true) {
                newValues.add(option);
                // Remove "none" if other options are selected
                newValues.remove("none");
              } else {
                newValues.remove(option);
                // Add "none" if no options are selected
                if (newValues.isEmpty) {
                  newValues = ["none"];
                }
              }
            }
            
            onChanged(newValues);
          },
        );
      }).toList(),
    );
  }
}
