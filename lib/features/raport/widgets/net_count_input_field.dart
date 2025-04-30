import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class NetCountInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String fieldName;
  final FieldState fieldState;
  final int value;
  final int? oldValue;
  final int min;
  final int max;
  final int divisions;
  final Function(int) onChanged;
  final VoidCallback onReset;

  const NetCountInputField({
    Key? key,
    required this.label,
    required this.icon,
    required this.fieldName,
    required this.fieldState,
    required this.value,
    this.oldValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
    required this.onReset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine colors based on field state
    Color stateColor;
    
    switch (fieldState) {
      case FieldState.set:
        stateColor = Colors.amber.shade800; // Use amber for SET state to match base_input_field
        break;
      case FieldState.old:
        stateColor = Colors.indigo.shade400;
        break;
      case FieldState.saved:
        stateColor = Colors.green;
        break;
      case FieldState.unset:
      default:
        stateColor = Colors.grey.shade400;
        break;
    }

    // Set the thumb and track color based on value
    Color valueColor = value > 0 
        ? Colors.green.shade600
        : value < 0 
            ? Colors.red.shade600 // Red for negative values
            : Colors.grey.shade600;

    // Background color for the value indicator
    Color valueBackgroundColor = value > 0 
        ? Colors.green.withOpacity(0.1)
        : value < 0 
            ? Colors.red.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1);

    return Container(
      decoration: BoxDecoration(
        // Remove border completely
        borderRadius: BorderRadius.circular(8),
        color: Colors.white, // Always use white background
      ),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with label, old value indicator, and reset button
          Row(
            children: [
              Icon(icon, size: 16, color: stateColor),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              
              // Show old value as a small tag if applicable
              if (oldValue != null && fieldState == FieldState.old) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: oldValue! > 0 
                        ? Colors.indigo.shade50
                        : oldValue! < 0 
                            ? Colors.red.shade50 // Light red background for negative old values
                            : Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    oldValue! > 0 ? '+$oldValue' : '$oldValue',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: oldValue! > 0 
                          ? Colors.indigo.shade600
                          : oldValue! < 0 
                              ? Colors.red.shade400 // Red text for negative old values
                              : Colors.indigo.shade600,
                    ),
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Value display for current value
              if (value != 0 || fieldState != FieldState.old) 
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: valueBackgroundColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value > 0 ? '+$value' : '$value',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: valueColor,
                    ),
                  ),
                ),
              
              // Only show reset button for set or saved fields, not for old values
              if (fieldState == FieldState.set || fieldState == FieldState.saved) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: onReset,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          
          // Slider with min/max labels
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Text(
                  '$min',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                      thumbColor: valueColor, // Use value color for thumb
                      activeTrackColor: valueColor, // Use value color for track
                      inactiveTrackColor: Colors.grey.shade200,
                    ),
                    child: Slider(
                      value: value.toDouble(),
                      min: min.toDouble(),
                      max: max.toDouble(),
                      divisions: divisions,
                      onChanged: (v) => onChanged(v.round()),
                    ),
                  ),
                ),
                Text(
                  '$max',
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
}
