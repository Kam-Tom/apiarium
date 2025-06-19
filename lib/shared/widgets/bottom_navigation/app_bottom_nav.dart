import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onItemTapped;
  
  const AppBottomNav({
    super.key, 
    required this.currentIndex, 
    required this.onItemTapped,
  });

  static const List<_NavItem> _navItems = [
    _NavItem(Icons.home, 'Home'),
    _NavItem(Icons.people, 'Social'),
    _NavItem(Icons.shopping_bag, 'Shop'),
    _NavItem(Icons.more_horiz, 'More'),
  ];

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenHeight < 700;
    
    return Positioned(
      bottom: isSmall ? 15 : 20,
      left: isSmall ? 15 : 20,
      right: isSmall ? 15 : 20,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          _buildNavigationBar(isSmall),
          Positioned(
            top: isSmall ? -20 : -25,
            child: _buildAddButton(isSmall),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavigationBar(bool isSmall) {
    return Container(
      height: isSmall ? 60 : 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isSmall ? 20 : 25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(0, _navItems[0], isSmall),
                _buildNavItem(1, _navItems[1], isSmall),
              ],
            ),
          ),
          SizedBox(width: isSmall ? 50 : 60),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(2, _navItems[2], isSmall),
                _buildNavItem(3, _navItems[3], isSmall),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, _NavItem item, bool isSmall) {
    final isSelected = currentIndex == index;
    
    return InkWell(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            color: isSelected ? Colors.amber : Colors.grey,
            size: isSmall ? 22 : 26,
          ),
          SizedBox(height: isSmall ? 2 : 4),
          Text(
            item.label,
            style: TextStyle(
              color: isSelected ? Colors.amber : Colors.grey,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(bool isSmall) {
    return InkWell(
      onTap: () => onItemTapped(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isSmall ? 50 : 60,
            height: isSmall ? 50 : 60,
            decoration: BoxDecoration(
              color: Colors.amber,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: isSmall ? 28 : 32,
                  ),
                ),
                Positioned(
                  right: isSmall ? 2 : 4,
                  bottom: isSmall ? 2 : 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.edit,
                      color: Colors.amber,
                      size: isSmall ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isSmall ? 6 : 10),
          Text(
            'Report',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: isSmall ? 11 : 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  
  const _NavItem(this.icon, this.label);
}
