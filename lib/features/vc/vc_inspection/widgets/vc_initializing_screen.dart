import 'package:flutter/material.dart';

class VcInitializingScreen extends StatelessWidget {
  final String statusMessage;

  const VcInitializingScreen({
    super.key,
    required this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.blue),
            const SizedBox(height: 24),
            Text(
              statusMessage,
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}
