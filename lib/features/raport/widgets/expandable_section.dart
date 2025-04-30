import 'package:flutter/material.dart';

class ExpandableSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isExpanded;
  final bool isActive;
  final int filledFieldsCount;
  final int totalFieldsCount;
  final VoidCallback onToggle;
  final List<Widget> children;
  final Widget? headerExtra;

  const ExpandableSection({
    Key? key,
    required this.title,
    required this.icon,
    required this.isExpanded,
    required this.isActive,
    required this.filledFieldsCount,
    required this.totalFieldsCount,
    required this.onToggle,
    required this.children,
    this.headerExtra,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with strong white background and bold black text
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                border: Border(
                  bottom: BorderSide(
                    color: isActive 
                        ? Colors.amber.shade200
                        : Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        icon,
                        color: isActive
                            ? Colors.amber.shade700
                            : Colors.grey.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // Pill-shaped completion indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.green.shade50
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isActive
                                ? Colors.green.shade200
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          '$filledFieldsCount/$totalFieldsCount',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isActive
                                ? Colors.green.shade700
                                : Colors.grey.shade600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 8),
                      
                      // Expand/collapse indicator
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isExpanded 
                              ? (isActive ? Colors.amber.shade100 : Colors.grey.shade200)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: isActive ? Colors.amber.shade700 : Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  
                  // Display header extra content below the title if provided
                  if (headerExtra != null && isExpanded)
                    Padding(
                      padding: const EdgeInsets.only(top: 8, left: 38),
                      child: headerExtra,
                    ),
                ],
              ),
            ),
          ),
          
          // Content with light gray background
          if (isExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
        ],
      ),
    );
  }
}
