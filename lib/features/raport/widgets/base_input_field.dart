import 'package:flutter/material.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';

/// Base class for all input fields in the inspection form
abstract class BaseInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String fieldName;
  final FieldState fieldState;
  final VoidCallback onReset;

  const BaseInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.fieldName,
    required this.fieldState,
    required this.onReset,
  });

  // Properties to check field state
  bool get isSet => fieldState == FieldState.set;
  bool get isOld => fieldState == FieldState.old;
  bool get isUnset => fieldState == FieldState.unset;
  bool get isSaved => fieldState == FieldState.saved;
  bool get isActive => isSet;

  // Get appropriate color based on field state
  Color get stateColor {
    switch (fieldState) {
      case FieldState.set: return Colors.amber.shade800;
      case FieldState.old: return Colors.indigo.shade300;
      case FieldState.unset: return Colors.grey.shade400;
      case FieldState.saved: return Colors.green.shade400;
    }
  }

  // Get color for frame status based on direct conditions
  static Color getFrameStatusColor({
    required int current,
    required int max,
    required int change,
  }) {
    if (current > max) {
      return Colors.red.shade700; // Danger (overflow)
    } else if (current == max) {
      return Colors.amber.shade800; // Warning (full)
    } else if (change > 0) {
      return Colors.green.shade600; // Positive change
    } else if (change < 0) {
      return Colors.orange.shade700; // Negative change
    } else {
      return Colors.black87; // Normal
    }
  }

  // Common header row with label and reset button
  Widget buildHeader({Widget? valueIndicator}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: stateColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
            if (valueIndicator != null) ...[
              const SizedBox(width: 8),
              valueIndicator,
            ],
          ],
        ),
        
        if (isActive)
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
    );
  }
}
