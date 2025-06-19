import 'package:flutter/material.dart';
import 'package:apiarium/features/home/widgets/task_carousel.dart';
import 'package:apiarium/features/home/widgets/featured_carousel.dart';
import 'package:apiarium/features/home/widgets/quick_access_menu.dart';
import 'package:apiarium/features/home/widgets/section_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final safeArea = mediaQuery.padding;
    final isSmall = screenHeight < 700;
    
    // Better responsive calculations
    final hasNotch = safeArea.top > 30;
    final availableHeight = screenHeight - safeArea.top - safeArea.bottom;
    
    // Dynamic flex ratios based on available space
    final topFlex = hasNotch 
        ? (isSmall ? 30 : 29) 
        : (isSmall ? 28 : 27);
    final bottomFlex = 100 - topFlex;
    
    final horizontalPadding = screenWidth < 350 ? 12.0 : 16.0;
    
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            flex: topFlex,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                safeArea.top + (hasNotch ? 8 : (isSmall ? 16 : 24)) + 10, // Added 10 pixels
                horizontalPadding,
                isSmall ? 8 : 16,
              ),
              child: const TaskCarousel(),
            ),
          ),
          Expanded(
            flex: bottomFlex,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: _buildBottomSection(isSmall, horizontalPadding, hasNotch, availableHeight),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(bool isSmall, double horizontalPadding, bool hasNotch, double availableHeight) {
    // Adjust padding based on available space
    double topPadding = hasNotch ? (isSmall ? 16 : 20) : (isSmall ? 12 : 25);
    
    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding - 1,
        topPadding,
        horizontalPadding - 1,
        20,
      ),
      child: Column(
        children: [
          _buildFeaturedSection(isSmall, hasNotch, availableHeight),
          SizedBox(height: isSmall ? 10 : 18),
          SectionHeader(
            titleKey: 'home.quick_access',
            isSmall: isSmall,
          ),
          Expanded(
            child: QuickAccessMenu(isSmall: isSmall),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(bool isSmall, bool hasNotch, double availableHeight) {
    // Dynamic featured section height based on available space
    double featuredHeight;
    if (hasNotch) {
      featuredHeight = isSmall ? 75 : 90;
    } else {
      featuredHeight = availableHeight < 600 ? 78 : (isSmall ? 82 : 103);
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
          titleKey: 'home.featured',
          isSmall: isSmall,
        ),
        SizedBox(
          height: featuredHeight,
          child: const FeaturedCarousel(),
        ),
      ],
    );
  }
}