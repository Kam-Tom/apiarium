import 'package:apiarium/features/home/home_view.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/honeycomb_background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: const HomeView(),
        ),
      ),
    );
  }
}