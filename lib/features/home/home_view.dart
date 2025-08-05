import 'package:flutter/material.dart';
import 'package:apiarium/features/home/widgets/task_carousel.dart';
import 'package:apiarium/features/home/widgets/featured_carousel.dart';
import 'package:apiarium/features/home/widgets/quick_access_menu.dart';
import 'package:apiarium/features/home/widgets/section_header.dart';

/// Main home view that displays the task carousel,
/// featured items, and quick access menu in a responsive layout.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenMetrics = _ScreenMetrics.fromContext(context);

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: screenMetrics.topFlex,
            child: _buildTopSection(screenMetrics),
          ),
          Expanded(
            flex: screenMetrics.bottomFlex,
            child: _buildBottomSection(screenMetrics),
          ),
        ],
      ),
    );
  }

  /// Builds the top section containing the task carousel
  Widget _buildTopSection(_ScreenMetrics metrics) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        metrics.horizontalPadding,
        metrics.isSmall ? 8 : 16,
        metrics.horizontalPadding,
        metrics.isSmall ? 8 : 16,
      ),
      child: const TaskCarousel(),
    );
  }

  /// Builds the bottom section with featured content and quick access menu
  Widget _buildBottomSection(_ScreenMetrics metrics) {
    return Container(
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
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: _buildBottomContent(metrics),
        ),
      ),
    );
  }

  /// Builds the content inside the bottom section
  Widget _buildBottomContent(_ScreenMetrics metrics) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        metrics.horizontalPadding - 1,
        metrics.topPadding,
        metrics.horizontalPadding - 1,
        20,
      ),
      child: Column(
        children: [
          _buildFeaturedSection(metrics),
          SizedBox(height: metrics.isSmall ? 10 : 18),
          SectionHeader(
            titleKey: 'home.quick_access',
            isSmall: metrics.isSmall,
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: metrics.bottomNavMargin),
              child: Center(
                child: QuickAccessMenu(
                  isSmall: metrics.isSmall,
                  isLarge: metrics.isLarge,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the featured section with header and carousel
  Widget _buildFeaturedSection(_ScreenMetrics metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SectionHeader(
          titleKey: 'home.featured',
          isSmall: metrics.isSmall,
        ),
        SizedBox(
          height: metrics.featuredHeight,
          child: const FeaturedCarousel(),
        ),
      ],
    );
  }
}

/// Helper class to encapsulate screen metrics and responsive calculations
class _ScreenMetrics {
  final double screenHeight;
  final double screenWidth;
  final EdgeInsets safeArea;
  final bool isSmall;
  final bool isLarge;
  final double availableHeight;
  final int topFlex;
  final int bottomFlex;
  final double horizontalPadding;
  final double topPadding;
  final double featuredHeight;
  final double bottomNavMargin;

  _ScreenMetrics._({
    required this.screenHeight,
    required this.screenWidth,
    required this.safeArea,
    required this.isSmall,
    required this.isLarge,
    required this.availableHeight,
    required this.topFlex,
    required this.bottomFlex,
    required this.horizontalPadding,
    required this.topPadding,
    required this.featuredHeight,
    required this.bottomNavMargin,
  });

  factory _ScreenMetrics.fromContext(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    final safeArea = mediaQuery.padding;
    final isSmall = screenHeight < 700;
    final isLarge = screenHeight > 800;
    final availableHeight = screenHeight - safeArea.top - safeArea.bottom;

    final topFlex = isSmall ? 26 : 25;
    final bottomFlex = 100 - topFlex;

    double horizontalPadding = screenWidth < 350 ? 12.0 : 16.0;
    double topPadding = isSmall ? 16 : 20;
    double bottomNavMargin = isSmall ? 70.0 : 80.0;

    double featuredHeight;
    if (availableHeight < 600) {
      featuredHeight = 80;
    } else {
      featuredHeight = isSmall ? 86 : 105;
    }

    return _ScreenMetrics._(
      screenHeight: screenHeight,
      screenWidth: screenWidth,
      safeArea: safeArea,
      isSmall: isSmall,
      isLarge: isLarge,
      availableHeight: availableHeight,
      topFlex: topFlex,
      bottomFlex: bottomFlex,
      horizontalPadding: horizontalPadding,
      topPadding: topPadding,
      featuredHeight: featuredHeight,
      bottomNavMargin: bottomNavMargin,
    );
  }
}