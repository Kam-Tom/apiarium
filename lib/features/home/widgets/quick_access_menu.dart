import 'package:flutter/material.dart';
import 'package:apiarium/features/home/models/menu_item.dart';
import 'package:go_router/go_router.dart';

class QuickAccessMenu extends StatelessWidget {
  const QuickAccessMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MenuItem> menuItems = HomeMenuItems.items;
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) => _buildMenuItem(context, menuItems[index]),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    // Define accent color (amber/yellow)
    final accentColor = Colors.amber.shade600;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: accentColor.withValues(alpha: 0.1),
          highlightColor: accentColor.withValues(alpha: 0.05),
          onTap: () {
            // Navigate to the route defined in the MenuItem
            context.push(item.route);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Icon with yellow background but no border
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    // Removed the borderRadius here
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    color: accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                
                // Text with bold styling - allowing two lines
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildTextLines(item.label),
                  ),
                ),
                
                // Subtle arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey.shade400,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // Helper method to split text into two lines when needed
  List<Widget> _buildTextLines(String label) {
    // If the text contains a space, split it at the first space
    if (label.contains(' ')) {
      final parts = label.split(' ');
      final firstPart = parts.first;
      final secondPart = parts.sublist(1).join(' ');
      
      return [
        Text(
          firstPart,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          secondPart,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ];
    } else {
      // If there's no space, just return the text in a single line
      return [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
            letterSpacing: 0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ];
    }
  }
}
