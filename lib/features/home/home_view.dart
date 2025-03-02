import 'package:flutter/material.dart';
import 'package:apiarium/features/home/widgets/task_carousel.dart';
import 'package:apiarium/features/home/widgets/featured_carousel.dart';
import 'package:apiarium/features/home/widgets/quick_access_menu.dart';
import 'package:apiarium/features/home/widgets/section_header.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false, // Important: don't apply safe area at the bottom
      child: Column(
        children: [
          // Top space for the task card
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 25.0),
              child: TaskCarousel(),
            ),
          ),
          // Bottom part with white background
          Expanded(
            flex: 8,
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
              // Added padding at the bottom to make room for navigation bar
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 25, 15, 110), // Increased bottom padding
                child: Column(
                  children: [
                    // Featured section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'Featured'),
                        SizedBox(
                          height: 100,
                          child: FeaturedCarousel(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Quick Access section
                    const SectionHeader(title: 'Quick Access'),
                    
                    // Menu buttons - take remaining space
                    const Expanded(
                      child: QuickAccessMenu(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}