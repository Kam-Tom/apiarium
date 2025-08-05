import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/features/home/models/menu_item.dart';
import 'package:go_router/go_router.dart';

/// A responsive grid widget that displays quick access menu items
/// for the home screen with different layouts for various screen sizes.
class QuickAccessMenu extends StatelessWidget {
  /// Whether to use compact sizing for small screens
  final bool isSmall;
  
  /// Whether to use expanded sizing for large screens
  final bool isLarge;

  const QuickAccessMenu({
    super.key,
    this.isSmall = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isLargeDevice = screenHeight > 800;
    
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: isLargeDevice ? 480 : 400,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: _buildGridDelegate(isLargeDevice),
        itemCount: homeMenuItems.length,
        itemBuilder: (context, index) => _MenuItemCard(
          item: homeMenuItems[index],
          isSmall: isSmall,
          isLargeDevice: isLargeDevice,
        ),
      ),
    );
  }

  /// Creates the grid delegate with responsive spacing and aspect ratios
  SliverGridDelegateWithFixedCrossAxisCount _buildGridDelegate(bool isLargeDevice) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      childAspectRatio: _getChildAspectRatio(isLargeDevice),
      mainAxisSpacing: _getSpacing(isLargeDevice),
      crossAxisSpacing: _getSpacing(isLargeDevice),
    );
  }

  /// Calculates the appropriate aspect ratio based on screen size
  double _getChildAspectRatio(bool isLargeDevice) {
    if (isLargeDevice) return 2.4;
    return isSmall ? 3.0 : 2.8;
  }

  /// Calculates the appropriate spacing based on screen size
  double _getSpacing(bool isLargeDevice) {
    if (isSmall) return 8.0;
    return isLargeDevice ? 16.0 : 12.0;
  }
}

/// Individual menu item card widget with responsive design
class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final bool isSmall;
  final bool isLargeDevice;

  const _MenuItemCard({
    required this.item,
    required this.isSmall,
    required this.isLargeDevice,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: _getCardHeight(),
      decoration: _buildCardDecoration(),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: theme.primaryColor.withOpacity(0.1),
          onTap: () => context.push(item.route),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(),
              vertical: 8,
            ),
            child: _buildCardContent(theme),
          ),
        ),
      ),
    );
  }

  /// Builds the main content of the card
  Widget _buildCardContent(ThemeData theme) {
    return Row(
      children: [
        _buildIcon(theme),
        SizedBox(width: _getIconTextSpacing()),
        Expanded(child: _buildText(theme)),
        const SizedBox(width: 4),
        _buildArrowIcon(),
      ],
    );
  }

  /// Builds the circular icon container
  Widget _buildIcon(ThemeData theme) {
    final iconSize = _getIconSize();
    final iconInnerSize = _getIconInnerSize();
    
    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: Icon(
        item.icon,
        color: theme.primaryColor,
        size: iconInnerSize,
      ),
    );
  }

  /// Builds the menu item text
  Widget _buildText(ThemeData theme) {
    return Text(
      item.labelKey.tr(),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontSize: _getFontSize(),
        height: 1.2,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.start,
    );
  }

  /// Builds the trailing arrow icon
  Widget _buildArrowIcon() {
    return Icon(
      Icons.arrow_forward_ios,
      color: Colors.grey[400],
      size: isLargeDevice ? 12 : 10,
    );
  }

  /// Creates the card decoration with shadow
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.07),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }

  // Responsive sizing methods
  double _getCardHeight() => isLargeDevice ? 75.0 : (isSmall ? 50.0 : 60.0);
  double _getHorizontalPadding() => isLargeDevice ? 16.0 : (isSmall ? 8.0 : 12.0);
  double _getIconTextSpacing() => isLargeDevice ? 12 : (isSmall ? 8 : 10);
  double _getIconSize() => isLargeDevice ? 36.0 : (isSmall ? 26.0 : 30.0);
  double _getIconInnerSize() => isLargeDevice ? 18.0 : (isSmall ? 13.0 : 15.0);
  double _getFontSize() => isLargeDevice ? 17.0 : (isSmall ? 14.0 : 16.0);
}