import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/features/home/models/menu_item.dart';
import 'package:go_router/go_router.dart';

class QuickAccessMenu extends StatelessWidget {
  final bool isSmall;
  
  const QuickAccessMenu({super.key, this.isSmall = false});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrow = screenWidth < 350;
    
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isNarrow ? 1 : 2,
        childAspectRatio: isNarrow ? 4.0 : (isSmall ? 2.6 : 2.15),
        mainAxisSpacing: isSmall ? 8.0 : 10.0, // Reduced spacing
        crossAxisSpacing: isSmall ? 8.0 : 10.0, // Reduced spacing
      ),
      itemCount: homeMenuItems.length,
      itemBuilder: (context, index) => _buildMenuItem(context, homeMenuItems[index], isNarrow),
    );
  }

  Widget _buildMenuItem(BuildContext context, MenuItem item, bool isNarrow) {
    final theme = Theme.of(context);
    final itemPadding = isSmall ? (isNarrow ? 10.0 : 12.0) : (isNarrow ? 12.0 : 16.0);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.primaryColor.withOpacity(0.1),
          onTap: () => context.push(item.route),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: itemPadding,
              vertical: isSmall ? 8 : 12,
            ),
            child: Row(
              children: [
                _buildIcon(item.icon, isNarrow, theme),
                SizedBox(width: isSmall ? 8 : (isNarrow ? 10 : 14)),
                Expanded(
                  child: Text(
                    item.labelKey.tr(),
                    style: (isSmall ? theme.textTheme.bodyMedium?.copyWith(fontSize: 15) : theme.textTheme.bodyMedium?.copyWith(fontSize: 14))?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.grey[400],
                  size: isSmall ? 8 : (isNarrow ? 10 : 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon, bool isNarrow, ThemeData theme) {
    final iconSize = isSmall ? 30 : (isNarrow ? 32 : 38);
    final iconInnerSize = isSmall ? 16.0 : (isNarrow ? 18.0 : 20.0);
    
    return Container(
      width: iconSize.toDouble(),
      height: iconSize.toDouble(),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: theme.primaryColor, size: iconInnerSize),
    );
  }
}