import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Custom bottom navigation bar with floating design and center action button
class AppBottomNav extends StatelessWidget {
  /// Currently selected navigation index
  final int currentIndex;
  
  /// Callback function when navigation item is tapped
  final ValueChanged<int> onItemTapped;
  
  const AppBottomNav({
    super.key, 
    required this.currentIndex, 
    required this.onItemTapped,
  });

  static const List<_NavItem> _navigationItems = [
    _NavItem(Icons.home, 'navigation.home'),
    _NavItem(Icons.people, 'navigation.social'),
    _NavItem(Icons.shopping_bag, 'navigation.shop'),
    _NavItem(Icons.more_horiz, 'navigation.more'),
  ];

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    return Positioned(
      bottom: isSmallScreen ? 10 : 16,
      left: isSmallScreen ? 10 : 16,
      right: isSmallScreen ? 10 : 16,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _NavigationBar(
            currentIndex: currentIndex,
            onItemTapped: onItemTapped,
            isSmallScreen: isSmallScreen,
          ),
          Positioned(
            top: isSmallScreen ? -18 : -22,
            child: _CenterActionButton(
              onTap: () => onItemTapped(4),
              isSmallScreen: isSmallScreen,
            ),
          ),
        ],
      ),
    );
  }
}

/// Main navigation bar container with navigation items
class _NavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;
  final bool isSmallScreen;

  const _NavigationBar({
    required this.currentIndex,
    required this.onItemTapped,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isSmallScreen ? 56 : 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 7,
            offset: const Offset(0, 2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavigationItem(
                  item: AppBottomNav._navigationItems[0],
                  index: 0,
                  isSelected: currentIndex == 0,
                  onTap: onItemTapped,
                  isSmallScreen: isSmallScreen,
                ),
                _NavigationItem(
                  item: AppBottomNav._navigationItems[1],
                  index: 1,
                  isSelected: currentIndex == 1,
                  onTap: onItemTapped,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
          SizedBox(width: isSmallScreen ? 46 : 52),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavigationItem(
                  item: AppBottomNav._navigationItems[2],
                  index: 2,
                  isSelected: currentIndex == 2,
                  onTap: onItemTapped,
                  isSmallScreen: isSmallScreen,
                ),
                _NavigationItem(
                  item: AppBottomNav._navigationItems[3],
                  index: 3,
                  isSelected: currentIndex == 3,
                  onTap: onItemTapped,
                  isSmallScreen: isSmallScreen,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual navigation item widget
class _NavigationItem extends StatelessWidget {
  final _NavItem item;
  final int index;
  final bool isSelected;
  final ValueChanged<int> onTap;
  final bool isSmallScreen;

  const _NavigationItem({
    required this.item,
    required this.index,
    required this.isSelected,
    required this.onTap,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Colors.amber;
    const unselectedColor = Colors.grey;
    
    return InkWell(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isSelected ? selectedColor : unselectedColor,
            size: isSmallScreen ? 22 : 26,
          ),
          SizedBox(height: isSmallScreen ? 2 : 3),
          Text(
            item.label.tr(),
            style: TextStyle(
              color: isSelected ? selectedColor : unselectedColor,
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

/// Center floating action button for primary actions
class _CenterActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isSmallScreen;

  const _CenterActionButton({
    required this.onTap,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = isSmallScreen ? 46.0 : 52.0;
    
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.25),
                  blurRadius: 7,
                  offset: const Offset(0, 2),
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isSmallScreen ? 24 : 28,
                  ),
                ),
                Positioned(
                  right: isSmallScreen ? 2 : 3,
                  bottom: isSmallScreen ? 2 : 3,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.amber,
                      size: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 5 : 7),
          Text(
            'navigation.inspection'.tr(),
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// Data class for navigation item configuration
class _NavItem {
  final IconData icon;
  final String label;
  
  const _NavItem(this.icon, this.label);
}
