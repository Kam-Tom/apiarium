import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/shared/widgets/dropdown/multiselect_rounded_dropdown.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:flutter/material.dart';

class MultiSelectInputField extends BaseInputField {
  final List<String>? values;
  final List<String> options;
  final ValueChanged<List<String>> onChanged;
  final String? hintText;

  const MultiSelectInputField({
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
    // Use an empty list if values is null
    final valuesList = values ?? [];
    
    // Value indicator for header
    final valueIndicator = isActive && valuesList.isNotEmpty
        ? Text(
            valuesList.length == 1 ? valuesList.first : '${valuesList.length} selected',
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
          
          // Multiselect dropdown
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: MultiselectRoundedDropdown<String>(
              items: options.where((option) => option != 'none' || valuesList.contains('none')).toList(),
              selectedValues: valuesList,
              onChanged: (newValues) {
                // Deduplicate the values to ensure no duplicates
                final uniqueValues = <String>{...newValues}.toList();
                
                // Handle "none" option logic: if "none" is selected, deselect all others
                if (uniqueValues.contains('none') && uniqueValues.length > 1) {
                  if (!valuesList.contains('none')) {
                    // User just selected "none", clear other selections
                    onChanged(['none']);
                  } else {
                    // User had "none" selected and chose something else, remove "none"
                    onChanged(uniqueValues.where((item) => item != 'none').toList());
                  }
                } else {
                  onChanged(uniqueValues);
                }
              },
              hintText: hintText,
              hasError: false,
              minHeight: 44.0,
              maxHeight: 300,
              itemBuilder: (context, item, isSelected) {
                return Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      color: isSelected ? stateColor : null,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isSelected ? stateColor : null,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                );
              },
              buttonItemBuilder: (context, selectedItems) {
                if (selectedItems.isEmpty) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      hintText ?? 'Select options',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                }
                
                if (selectedItems.contains('none')) {
                  return Container(
                    alignment: Alignment.centerLeft,
                    child: const Text('None'),
                  );
                }
                
                return Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedItems.length <= 2
                        ? selectedItems.join(', ')
                        : '${selectedItems.length} selected',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
