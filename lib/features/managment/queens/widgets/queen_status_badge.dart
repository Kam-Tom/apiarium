import 'package:flutter/material.dart';
import 'package:apiarium/shared/shared.dart';

class QueenStatusBadge extends StatelessWidget {
  final QueenStatus status;
  final bool compact;

  const QueenStatusBadge({
    super.key,
    required this.status,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeColor, statusText, iconData) = _getStatusDisplay();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            iconData,
            size: compact ? 12 : 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            statusText,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.bold,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String, IconData) _getStatusDisplay() {
    return switch (status) {
      QueenStatus.active => (Colors.green.shade700, 'Active', Icons.check_circle),
      QueenStatus.dead => (Colors.red.shade700, 'Dead', Icons.cancel),
      QueenStatus.replaced => (Colors.orange.shade700, 'Replaced', Icons.swap_horiz),
      QueenStatus.lost => (Colors.grey.shade600, 'Lost', Icons.help),
      _ => (Colors.blue.shade700, status.name, Icons.info),
    };
  }
}
