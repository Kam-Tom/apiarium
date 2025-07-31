import 'package:apiarium/shared/domain/enums/custom_icons.dart';

extension HiveIconTypeExtension on HiveIconType {
  String get name => toString().split('.').last;

  static HiveIconType fromString(String value) {
    return HiveIconType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => HiveIconType.beehive1, // fallback
    );
  }
}