import 'package:apiarium/features/raport/widgets/base_input_field.dart';
import 'package:apiarium/features/raport/inspection/bloc/inspection_bloc.dart';
import 'package:flutter/material.dart';

class FrameCountLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final int currentCount;
  final int maxCount;
  final int netChange;
  final FieldState? netChangeState; // Add this to track state of net change
  final int? boxCount;
  final FieldState? boxChangeState; // Add this to track state of box change
  final Color? boxChangeColor;
  final int? framesPerBox;
  final bool showNetChange;

  const FrameCountLabel({
    super.key,
    required this.icon,
    required this.label,
    required this.currentCount,
    required this.maxCount,
    this.netChange = 0,
    this.netChangeState,
    this.boxCount,
    this.boxChangeState,
    this.boxChangeColor,
    this.framesPerBox,
    this.showNetChange = true,
  });

  @override
  Widget build(BuildContext context) {
    // Use base input field utility for consistent color determination
    final Color valueColor = BaseInputField.getFrameStatusColor(
      current: currentCount,
      max: maxCount,
      change: netChange,
    );

    // Get appropriate color for the net change indicator based on state
    Color netChangeColor;
    if (netChangeState == FieldState.old) {
      netChangeColor = netChange > 0 
          ? Colors.indigo.shade600 
          : netChange < 0 
              ? Colors.red.shade400  // Red for negative old values
              : Colors.indigo.shade400;
    } else if (netChangeState == FieldState.saved) {
      netChangeColor = Colors.green.shade600;
    } else if (netChangeState == FieldState.set) {
      netChangeColor = netChange > 0
          ? Colors.green.shade600  // Green for positive set values
          : netChange < 0
              ? Colors.red.shade600  // Red for negative set values
              : Colors.amber.shade800;
    } else {
      netChangeColor = netChange > 0
          ? Colors.green.shade600
          : netChange < 0
              ? Colors.red.shade600
              : Colors.grey.shade700;
    }

    // Get box change color based on state or use the provided color
    Color actualBoxChangeColor = boxChangeColor ?? Colors.grey.shade600;
    if (boxChangeState == FieldState.old) {
      actualBoxChangeColor = Colors.indigo.shade400;
    } else if (boxChangeState == FieldState.saved) {
      actualBoxChangeColor = Colors.green.shade600;
    } else if (boxChangeState == FieldState.set) {
      actualBoxChangeColor = boxCount! > 0
          ? Colors.green.shade600  // Green for positive box changes
          : boxCount! < 0
              ? Colors.red.shade600  // Red for negative box changes
              : Colors.amber.shade800;
    }

    // Determine color for current count value
    Color currentCountColor = Colors.black87;
    if (netChangeState == FieldState.set) {
      currentCountColor = Colors.amber.shade800; // Amber when values are actively set
    }

    // Determine background color for indicators based on state
    Color getIndicatorBgColor(FieldState? state, bool isPositive) {
      if (state == FieldState.old) {
        return isPositive 
            ? Colors.indigo.shade50 
            : Colors.red.shade50;
      } else if (state == FieldState.saved) {
        return Colors.green.shade50;
      } else if (state == FieldState.set) {
        return isPositive
            ? Colors.green.shade50
            : Colors.red.shade50;
      }
      return Colors.grey.shade100;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    // Show box change indicator if provided
                    if (boxCount != null && boxCount != 0 && framesPerBox != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: getIndicatorBgColor(boxChangeState, boxCount! > 0),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.transparent), // Transparent border
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              boxCount! > 0 ? Icons.add_box : Icons.remove,
                              size: 12,
                              color: actualBoxChangeColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${boxCount!.abs()} box${boxCount!.abs() > 1 ? 'es' : ''}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: actualBoxChangeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$currentCount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: currentCountColor, // Use amber for SET state
                      ),
                    ),
                    Text(
                      '/$maxCount',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    if (showNetChange && netChange != 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: getIndicatorBgColor(netChangeState, netChange > 0),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.transparent), // Transparent border
                        ),
                        child: Text(
                          '${netChange > 0 ? '+' : ''}$netChange',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: netChangeColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
