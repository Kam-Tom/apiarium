import 'package:apiarium/shared/domain/enums/custom_icons.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HiveIcons extends StatelessWidget {
  final HiveIconType icon;
  final double size;
  final Color? color;

  const HiveIcons({
    super.key,
    required this.icon,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final iconName = icon.name;
    return SvgPicture.asset(
      'assets/icons/hive/$iconName.svg',
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}