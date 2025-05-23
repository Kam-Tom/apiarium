import 'package:flutter/material.dart';

enum VcBooleanStyle {
  truefalse, // Use "True" and "False" as labels
  yesno, // Use "Yes" and "No" as labels
}

class VcBooleanInput extends StatelessWidget {
  final String label;
  final bool value;
  final IconData icon;
  final String commandTrue;
  final String commandFalse;
  final String commandSkip;
  final VcBooleanStyle style;

  const VcBooleanInput({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
    required this.commandTrue,
    required this.commandFalse,
    required this.commandSkip,
    this.style = VcBooleanStyle.truefalse,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine status colors based on value
    final Color statusColor = value ? Colors.green : Colors.red.shade400;
    final String trueText = style == VcBooleanStyle.truefalse ? "True" : "Yes";
    final String falseText = style == VcBooleanStyle.truefalse ? "False" : "No";

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade800,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white70,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withOpacity(0.4),
                    width: 1,
                  ),
                ),
                child: Text(
                  value ? trueText : falseText,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 14),
          
          // Command buttons - more compact layout
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCompactCommandButton(
                commandTrue,
                trueText,
                value ? statusColor : Colors.grey.shade700,
                value,
              ),
              
              const SizedBox(width: 16),
              
              _buildCompactCommandButton(
                commandFalse,
                falseText,
                !value ? statusColor : Colors.grey.shade700,
                !value,
              ),
              
              const SizedBox(width: 16),
              
              _buildCompactCommandButton(
                commandSkip,
                "Skip",
                Colors.grey.shade600,
                false,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // More compact command button layout
  Widget _buildCompactCommandButton(String command, String label, Color color, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label text
        Text(
          label,
          style: TextStyle(
            color: isActive ? color : Colors.white54,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        // Command with mic icon
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.mic,
              size: 10,
              color: Colors.amber,
            ),
            const SizedBox(width: 3),
            Text(
              command,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
