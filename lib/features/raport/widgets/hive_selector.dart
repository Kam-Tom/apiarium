import 'package:flutter/material.dart';
import 'package:apiarium/shared/domain/models/hive.dart';
import 'package:apiarium/shared/domain/enums/hive_status.dart';

class HiveSelector extends StatelessWidget {
  final Hive hive;
  final bool isSelected;
  final VoidCallback onTap;

  const HiveSelector({
    super.key,
    required this.hive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    Color cardColor;
    
    switch (hive.status) {
      case HiveStatus.active:
        statusColor = Colors.green.shade600;
        cardColor = Colors.green.shade50;
        break;
      case HiveStatus.archived:
        statusColor = Colors.orange.shade600;
        cardColor = Colors.orange.shade50;
        break;
      case HiveStatus.inactive:
        statusColor = Colors.red.shade600;
        cardColor = Colors.red.shade50;
        break;
      default:
        statusColor = Colors.grey.shade600;
        cardColor = Colors.grey.shade50;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 55,
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber.shade50 : cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? Colors.amber : statusColor).withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Status indicator at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber.shade600 : statusColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
              ),
            ),
            // Centered hive number
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 2),
                  Text(
                    hive.name.split(' ').last,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.amber.shade800 : statusColor,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.amber.shade600,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
