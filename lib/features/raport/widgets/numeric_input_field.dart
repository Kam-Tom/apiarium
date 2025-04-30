import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class NumericInputField extends BaseInputField {
  final int? value;
  final int min;
  final int max;
  final String? suffix;
  final ValueChanged<int?> onChanged;

  const NumericInputField({
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
    final controller = TextEditingController(text: value?.toString() ?? '');
    
    // Prepare value indicator for the header
    final valueIndicator = isActive && value != null
        ? Text(
            suffix != null ? '$value $suffix' : value.toString(),
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
          
          // Numeric input with +/- buttons
          Container(
            margin: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                // Minus button
                _buildIconButton(
                  icon: Icons.remove,
                  onPressed: value != null && value! > min
                      ? () => onChanged(value! - 1)
                      : null,
                ),
                
                // Input field
                Expanded(
                  child: Container(
                    height: 40,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isOld ? Colors.indigo.shade100 : Colors.grey.shade300
                      ),
                    ),
                    child: Center(
                      child: TextField(
                        controller: controller,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                          suffix: suffix != null ? Text(suffix!) : null,
                        ),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isOld ? Colors.indigo.shade300 : Colors.grey.shade800,
                        ),
                        onChanged: (text) {
                          if (text.isEmpty) {
                            onChanged(null);
                            return;
                          }
                          
                          final newValue = int.tryParse(text);
                          if (newValue != null && newValue >= min && newValue <= max) {
                            onChanged(newValue);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                
                // Plus button
                _buildIconButton(
                  icon: Icons.add,
                  onPressed: value != null && value! < max
                      ? () => onChanged(value! + 1)
                      : null,
                ),
              ],
            ),
          ),
          
          // Min/max label
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
  
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: onPressed != null 
            ? (isOld ? Colors.indigo.shade100 : Colors.amber.shade100) 
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          size: 18,
          color: onPressed != null 
              ? (isOld ? Colors.indigo.shade300 : Colors.amber.shade800) 
              : Colors.grey.shade400,
        ),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
      ),
    );
  }
}
