import 'package:easy_localization/easy_localization.dart';

enum HiveAccessory {
  // 🐝 Physical Accessories
  feeder,
  queenExcluder,
  pollenTrap,
  entranceReducer,
  mouseGuard,
  hiveStand,
  insulationWrap,
  screenedBottomBoard,
  escapeBoard,
  propolisTrap,
  ventilationBox,
  robbingScreen,
  topCover,
  innerCover,
  
  // 📡 IoT Devices
  hiveScale,
  temperatureSensor,
  humiditySensor,
  soundSensor,
  co2Sensor,
  gpsTracker,
  cameraMonitor,
  beeCounter,
  vibrationSensor,
}

extension HiveAccessoryExtension on HiveAccessory {
  String get displayName {
    switch (this) {
      case HiveAccessory.feeder:
        return 'accessories.feeder'.tr();
      case HiveAccessory.queenExcluder:
        return 'accessories.queen_excluder'.tr();
      case HiveAccessory.pollenTrap:
        return 'accessories.pollen_trap'.tr();
      case HiveAccessory.entranceReducer:
        return 'accessories.entrance_reducer'.tr();
      case HiveAccessory.mouseGuard:
        return 'accessories.mouse_guard'.tr();
      case HiveAccessory.hiveStand:
        return 'accessories.hive_stand'.tr();
      case HiveAccessory.insulationWrap:
        return 'accessories.insulation_wrap'.tr();
      case HiveAccessory.screenedBottomBoard:
        return 'accessories.screened_bottom_board'.tr();
      case HiveAccessory.escapeBoard:
        return 'accessories.escape_board'.tr();
      case HiveAccessory.propolisTrap:
        return 'accessories.propolis_trap'.tr();
      case HiveAccessory.ventilationBox:
        return 'accessories.ventilation_box'.tr();
      case HiveAccessory.robbingScreen:
        return 'accessories.robbing_screen'.tr();
      case HiveAccessory.topCover:
        return 'accessories.top_cover'.tr();
      case HiveAccessory.innerCover:
        return 'accessories.inner_cover'.tr();
      case HiveAccessory.hiveScale:
        return 'accessories.hive_scale'.tr();
      case HiveAccessory.temperatureSensor:
        return 'accessories.temperature_sensor'.tr();
      case HiveAccessory.humiditySensor:
        return 'accessories.humidity_sensor'.tr();
      case HiveAccessory.soundSensor:
        return 'accessories.sound_sensor'.tr();
      case HiveAccessory.co2Sensor:
        return 'accessories.co2_sensor'.tr();
      case HiveAccessory.gpsTracker:
        return 'accessories.gps_tracker'.tr();
      case HiveAccessory.cameraMonitor:
        return 'accessories.camera_monitor'.tr();
      case HiveAccessory.beeCounter:
        return 'accessories.bee_counter'.tr();
      case HiveAccessory.vibrationSensor:
        return 'accessories.vibration_sensor'.tr();
    }
  }

  String get category {
    switch (this) {
      case HiveAccessory.feeder:
      case HiveAccessory.queenExcluder:
      case HiveAccessory.pollenTrap:
      case HiveAccessory.entranceReducer:
      case HiveAccessory.mouseGuard:
      case HiveAccessory.hiveStand:
      case HiveAccessory.insulationWrap:
      case HiveAccessory.screenedBottomBoard:
      case HiveAccessory.escapeBoard:
      case HiveAccessory.propolisTrap:
      case HiveAccessory.ventilationBox:
      case HiveAccessory.robbingScreen:
      case HiveAccessory.topCover:
      case HiveAccessory.innerCover:
        return 'accessories.physical'.tr();
      case HiveAccessory.hiveScale:
      case HiveAccessory.temperatureSensor:
      case HiveAccessory.humiditySensor:
      case HiveAccessory.soundSensor:
      case HiveAccessory.co2Sensor:
      case HiveAccessory.gpsTracker:
      case HiveAccessory.cameraMonitor:
      case HiveAccessory.beeCounter:
      case HiveAccessory.vibrationSensor:
        return 'accessories.iot_devices'.tr();
    }
  }
}

// Helper methods for conversion
class HiveAccessoryHelper {
  static List<String> accessoriesToStringList(List<HiveAccessory>? accessories) {
    return accessories?.map((a) => a.name).toList() ?? [];
  }

  static List<HiveAccessory> stringListToAccessories(List<String>? stringList) {
    if (stringList == null) return [];
    return stringList
        .map((str) => HiveAccessory.values.where((a) => a.name == str).firstOrNull)
        .whereType<HiveAccessory>()
        .toList();
  }
}
