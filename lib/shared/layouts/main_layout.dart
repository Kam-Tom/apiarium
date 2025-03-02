import 'package:apiarium/core/core.dart';
import 'package:apiarium/shared/widgets/bottom_navigation/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainLayout extends StatelessWidget {
  final Widget child;
  final int currentIndex;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppImages.backgroundHoneycomb),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Main content
            child,
            
            // Floating navigation bar
            AppBottomNav(
              currentIndex: currentIndex,
              onItemTapped: (index) {
                // Navigate using GoRouter based on the index
                switch (index) {
                  case 0:
                    context.go('/');
                    break;
                  case 1:
                    context.go('/social');
                    break;
                  case 2:
                    context.go('/shop');
                    break;
                  case 3:
                    context.go('/more');
                    break;
                  case 4: // Report button
                    context.go('/report');
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
