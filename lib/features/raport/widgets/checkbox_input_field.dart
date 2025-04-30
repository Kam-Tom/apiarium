import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

class CheckboxInputField extends BaseInputField {
  final bool? value;
  final ValueChanged<bool?> onChanged;
  final String? positiveText;
  final String? negativeText;
  final IconData? overrideIcon;
  final bool compact;

  const CheckboxInputField({
    Key? key,
    required String label,
    required IconData icon,
    required String fieldName,
    required FieldState fieldState,
    required VoidCallback onReset,
    required this.value,
    required this.onChanged,
    this.positiveText,
    this.negativeText,
    this.overrideIcon,
    this.compact = false,
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
    final displayValue = value ?? false;

    // Custom color palette for checkbox states (less transparent)
    Color mainColor;
    Color bgColor;
    Color borderColor;
    Color iconColor;
    Color statusColor;

    if (isSaved) {
      if(displayValue) {
        // Saved: teal, slightly transparent
        mainColor = Colors.teal.shade400.withOpacity(0.92);
        bgColor = Colors.teal.shade50.withOpacity(0.45);
        borderColor = Colors.teal.shade400.withOpacity(0.92);
        iconColor = Colors.teal.shade400.withOpacity(0.92);
        statusColor = Colors.teal.shade400.withOpacity(0.92);
      } else {
        // Saved: teal, slightly transparent
        mainColor = Colors.deepOrange.shade400.withOpacity(0.92);
        bgColor = Colors.deepOrange.shade50.withOpacity(0.45);
        borderColor = Colors.deepOrange.shade400.withOpacity(0.92);
        iconColor = Colors.deepOrange.shade400.withOpacity(0.92);
        statusColor = Colors.deepOrange.shade400.withOpacity(0.92);
      }
    } else if (isOld) {
      if (!displayValue) {
        // Old false: purple, slightly transparent
        mainColor = Colors.purple.shade400.withOpacity(0.85);
        bgColor = Colors.purple.shade50.withOpacity(0.35);
        borderColor = Colors.purple.shade400.withOpacity(0.85);
        iconColor = Colors.purple.shade400.withOpacity(0.85);
        statusColor = Colors.purple.shade400.withOpacity(0.85);
      } else {
        // Old true: indigo, slightly transparent
        mainColor = Colors.indigo.shade300.withOpacity(0.85);
        bgColor = Colors.indigo.shade50.withOpacity(0.35);
        borderColor = Colors.indigo.shade300.withOpacity(0.85);
        iconColor = Colors.indigo.shade300.withOpacity(0.85);
        statusColor = Colors.indigo.shade300.withOpacity(0.85);
      }
    } else if (isSet) {
      if (displayValue) {
        // Checked: green, solid
        mainColor = Colors.green.shade700;
        bgColor = Colors.green.shade50;
        borderColor = Colors.green.shade700;
        iconColor = Colors.green.shade700;
        statusColor = Colors.green.shade700;
      } else {
        // Set but false: grayish
        mainColor = Colors.red.shade600;
        bgColor = Colors.red.shade100;
        borderColor = Colors.red.shade600;
        iconColor = Colors.red.shade600;
        statusColor = Colors.red.shade600;
      }
    } else {
      // Unset: gray
      mainColor = Colors.grey.shade400;
      bgColor = Colors.grey.shade50;
      borderColor = Colors.grey.shade400;
      iconColor = Colors.grey.shade400;
      statusColor = Colors.grey.shade400;
    }

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
      margin: EdgeInsets.zero, // Remove margin to let parent handle spacing
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!displayValue),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: compact 
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                : const EdgeInsets.all(12),
            child: Row(
              children: [
                // Icon section (smaller in compact mode)
                Container(
                  padding: compact ? const EdgeInsets.all(6) : const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    overrideIcon ?? icon,
                    color: iconColor,
                    size: compact ? 16 : 20,
                  ),
                ),
                
                SizedBox(width: compact ? 10 : 16),
                
                // Label and status (more compact text)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: compact ? 13 : 15,
                          color: mainColor,
                        ),
                      ),
                      if (isActive && (positiveText != null || negativeText != null) && !compact)
                        Text(
                          displayValue 
                              ? (positiveText ?? 'Yes')
                              : (negativeText ?? 'No'),
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Status indicator (smaller in compact mode)
                Container(
                  width: compact ? 20 : 24,
                  height: compact ? 20 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                    border: Border.all(
                      color: borderColor,
                      width: compact ? 1.5 : 2,
                    ),
                  ),
                  child: isActive || isSaved || isOld
                      ? Center(
                          child: displayValue 
                              ? Icon(Icons.check, size: compact ? 14 : 16, color: statusColor)
                              : Icon(Icons.close, size: compact ? 14 : 16, color: statusColor),
                        )
                      : Center(
                          child: Text(
                            '?',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: compact ? 12 : 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
                
                SizedBox(width: compact ? 6 : 8),
                
                // Reset button (smaller in compact mode)
                if (isActive)
                  GestureDetector(
                    onTap: onReset,
                    child: Container(
                      padding: compact ? const EdgeInsets.all(3) : const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: compact ? 12 : 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
