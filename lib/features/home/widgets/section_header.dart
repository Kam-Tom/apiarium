import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String titleKey;
  final bool isSmall;
  
  const SectionHeader({
    super.key, 
    required this.titleKey,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
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
            fontSize: isSmall ? 16 : 17,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
