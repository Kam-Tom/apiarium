import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  
  const SectionHeader({
    super.key, 
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.black.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}
