import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class HiveType extends BaseModel {
  static const List<IconData> availableIcons = [
    Icons.home,
    Icons.house,
    Icons.cottage,
    Icons.cabin,
    Icons.villa,
    Icons.apartment,
    Icons.domain,
    Icons.foundation,
    Icons.roofing,
    Icons.warehouse,
    Icons.store,
    Icons.storefront,
    Icons.business,
    Icons.corporate_fare,
    Icons.holiday_village,
  ];

  final String name;
  final String? manufacturer;
  final HiveMaterial material;
  final bool hasFrames;
  final int? broodFrameCount;
  final int? honeyFrameCount;
  final String? frameStandard;
  final int? boxCount;
  final int? superBoxCount;
  final int? framesPerBox;
  final int? maxBroodFrameCount;
  final int? maxHoneyFrameCount;
  final int? maxBoxCount;
  final int? maxSuperBoxCount;  
  final List<String>? accessories;
  final String? country;
  final bool isLocal;
  final bool isStarred;
  final double? cost;
  final String? imageName;
  final IconData icon;

  const HiveType({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    super.serverVersion = 0,
    required this.name,
    this.manufacturer,
    required this.material,
    required this.hasFrames,
    this.broodFrameCount,
    this.honeyFrameCount,
    this.frameStandard,
    this.boxCount,
    this.superBoxCount,
    this.framesPerBox,
    this.maxBroodFrameCount,
    this.maxHoneyFrameCount,
    this.maxBoxCount,
    this.maxSuperBoxCount,    
    this.accessories,
    this.country,
    this.isLocal = false,
    this.isStarred = false,
    this.cost,
    this.imageName,
    this.icon = Icons.home,
  });

  factory HiveType.fromMap(Map<String, dynamic> data) {
    return HiveType(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == data['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: data['lastSyncedAt'] != null 
          ? DateTime.parse(data['lastSyncedAt']) 
          : null,
      deleted: data['deleted'] ?? false,
      serverVersion: data['serverVersion'] ?? 0,
      name: data['name'],
      manufacturer: data['manufacturer'],
      material: HiveMaterial.values.firstWhere(
        (m) => m.name == data['material'],
        orElse: () => HiveMaterial.wood,
      ),
      hasFrames: data['hasFrames'] ?? false,
      broodFrameCount: data['broodFrameCount'],
      honeyFrameCount: data['honeyFrameCount'],
      frameStandard: data['frameStandard'],
      boxCount: data['boxCount'],
      superBoxCount: data['superBoxCount'],
      framesPerBox: data['framesPerBox'],
      maxBroodFrameCount: data['maxBroodFrameCount'],
      maxHoneyFrameCount: data['maxHoneyFrameCount'],
      maxBoxCount: data['maxBoxCount'],
      maxSuperBoxCount: data['maxSuperBoxCount'],
      accessories: data['accessories']?.cast<String>(),
      country: data['country'],
      isLocal: data['isLocal'] ?? false,
      isStarred: data['isStarred'] ?? false,
      cost: data['cost']?.toDouble(),
      imageName: data['imageName'],
      icon: _getIconFromCodePoint(data['iconCodePoint']) ?? Icons.home,
    );
  }

  static IconData? _getIconFromCodePoint(int? codePoint) {
    if (codePoint == null) return null;
    return availableIcons.firstWhere(
      (icon) => icon.codePoint == codePoint,
      orElse: () => Icons.home,
    );
  }

  String get displayName => manufacturer != null ? '$name ($manufacturer)' : name;
    
  @override
  List<Object?> get props => [
    ...baseSyncProps, name, manufacturer, material, hasFrames, broodFrameCount, honeyFrameCount,
    frameStandard, boxCount, superBoxCount, framesPerBox, maxBroodFrameCount,
    maxHoneyFrameCount, maxBoxCount, maxSuperBoxCount, accessories, country, isLocal, isStarred, cost, imageName, icon
  ];  
  
  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'name': name,
      'manufacturer': manufacturer,
      'material': material.name,
      'hasFrames': hasFrames,
      'broodFrameCount': broodFrameCount,
      'honeyFrameCount': honeyFrameCount,
      'frameStandard': frameStandard,
      'boxCount': boxCount,
      'superBoxCount': superBoxCount,
      'framesPerBox': framesPerBox,
      'maxBroodFrameCount': maxBroodFrameCount,
      'maxHoneyFrameCount': maxHoneyFrameCount,
      'maxBoxCount': maxBoxCount,
      'maxSuperBoxCount': maxSuperBoxCount,      
      'accessories': accessories,
      'country': country,
      'isLocal': isLocal,
      'isStarred': isStarred,
      'cost': cost,
      'imageName': imageName,
      'iconCodePoint': icon.codePoint,
    };
  }

  HiveType copyWith({
    String? Function()? name,
    String? Function()? manufacturer,
    HiveMaterial? Function()? material,
    bool? Function()? hasFrames,
    int? Function()? broodFrameCount,
    int? Function()? honeyFrameCount,
    String? Function()? frameStandard,
    int? Function()? boxCount,
    int? Function()? superBoxCount,
    int? Function()? framesPerBox,
    int? Function()? maxBroodFrameCount,
    int? Function()? maxHoneyFrameCount,
    int? Function()? maxBoxCount,
    int? Function()? maxSuperBoxCount,
    List<String>? Function()? accessories,
    String? Function()? country,
    bool? Function()? isLocal,
    bool? Function()? isStarred,
    double? Function()? cost,
    String? Function()? imageName,
    IconData? Function()? icon,
    DateTime? Function()? updatedAt,
    SyncStatus? Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool? Function()? deleted,
    int? Function()? serverVersion,
  }) {
    return HiveType(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt?.call() ?? DateTime.now(),
      syncStatus: syncStatus?.call() ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt?.call() ?? this.lastSyncedAt,
      deleted: deleted?.call() ?? this.deleted,
      serverVersion: serverVersion?.call() ?? this.serverVersion,
      name: name?.call() ?? this.name,
      manufacturer: manufacturer?.call() ?? this.manufacturer,
      material: material?.call() ?? this.material,
      hasFrames: hasFrames?.call() ?? this.hasFrames,
      broodFrameCount: broodFrameCount?.call() ?? this.broodFrameCount,
      honeyFrameCount: honeyFrameCount?.call() ?? this.honeyFrameCount,
      frameStandard: frameStandard?.call() ?? this.frameStandard,
      boxCount: boxCount?.call() ?? this.boxCount,
      superBoxCount: superBoxCount?.call() ?? this.superBoxCount,
      framesPerBox: framesPerBox?.call() ?? this.framesPerBox,
      maxBroodFrameCount: maxBroodFrameCount?.call() ?? this.maxBroodFrameCount,
      maxHoneyFrameCount: maxHoneyFrameCount?.call() ?? this.maxHoneyFrameCount,
      maxBoxCount: maxBoxCount?.call() ?? this.maxBoxCount,
      maxSuperBoxCount: maxSuperBoxCount?.call() ?? this.maxSuperBoxCount,
      accessories: accessories?.call() ?? this.accessories,
      country: country?.call() ?? this.country,
      isLocal: isLocal?.call() ?? this.isLocal,
      isStarred: isStarred?.call() ?? this.isStarred,
      cost: cost?.call() ?? this.cost,
      imageName: imageName?.call() ?? this.imageName,
      icon: icon?.call() ?? this.icon,
    );
  }

  Future<String?> getLocalImagePath() async {
    if (imageName == null || imageName!.isEmpty) return null;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/images/hive_types/$imageName';
      final file = File(localPath);
      return await file.exists() ? localPath : null;
    } catch (e) {
      return null;
    }
  }
}
