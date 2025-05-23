import 'package:apiarium/features/home/home_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          // Your background image should go here and cover full screen
          image: DecorationImage(
            image: AssetImage('assets/images/honeycomb_background.jpg'), // Replace with your image
            fit: BoxFit.cover,
          ),
        ),
        child: const HomeView(),
      ),
    );
  }
}