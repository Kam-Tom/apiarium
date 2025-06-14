import 'package:flutter/material.dart';

/// Label for form input fields
class InputLabel extends StatelessWidget {
  final String label;
  
  const InputLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.height < 700;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 4.0 : 6.0),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isSmallScreen ? 13 : 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }
}