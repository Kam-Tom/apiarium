import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String titleKey;
  final bool isSmall;
  final bool isLarge;
  
  const SectionHeader({
    super.key, 
    required this.titleKey,
    this.isSmall = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final shouldUseLargerText = screenHeight > 800 || screenWidth > 400 || isLarge;
    
    return Padding(
      padding: EdgeInsets.only(
        left: 5, 
        bottom: isSmall ? 6 : 8,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          titleKey.tr(),
          style: TextStyle(
            fontSize: shouldUseLargerText ? 22 : (isSmall ? 16 : 17),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
