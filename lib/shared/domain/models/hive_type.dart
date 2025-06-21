import 'package:apiarium/shared/shared.dart';

class HiveType extends BaseModel {
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
  final int? maxSuperBoxCount;  final List<String>? accessories;
  final String? country;
  final bool isLocal;
  final bool isStarred;
  final double? cost;

  const HiveType({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
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
    this.maxSuperBoxCount,    this.accessories,
    this.country,
    this.isLocal = false,
    this.isStarred = false,
    this.cost,
  });
  String get displayName => manufacturer != null 
    ? '$name ($manufacturer)'
    : name;@override
  List<Object?> get props => [
    ...baseSyncProps,    name, manufacturer, material, hasFrames, broodFrameCount, honeyFrameCount,
    frameStandard, boxCount, superBoxCount, framesPerBox, maxBroodFrameCount,
    maxHoneyFrameCount, maxBoxCount, maxSuperBoxCount, accessories, country, isLocal, isStarred, cost
  ];  Map<String, dynamic> toMap() {
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
      'maxSuperBoxCount': maxSuperBoxCount,      'accessories': accessories,
      'country': country,
      'isLocal': isLocal,
      'isStarred': isStarred,
      'cost': cost,
    };
  }HiveType copyWith({
    String? name,
    String? manufacturer,
    HiveMaterial? material,
    bool? hasFrames,
    int? broodFrameCount,
    int? honeyFrameCount,
    String? frameStandard,
    int? boxCount,
    int? superBoxCount,
    int? framesPerBox,
    int? maxBroodFrameCount,
    int? maxHoneyFrameCount,
    int? maxBoxCount,
    int? maxSuperBoxCount,    List<String>? accessories,
    String? country,
    bool? isLocal,
    bool? isStarred,
    double? cost,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return HiveType(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      material: material ?? this.material,
      hasFrames: hasFrames ?? this.hasFrames,
      broodFrameCount: broodFrameCount ?? this.broodFrameCount,
      honeyFrameCount: honeyFrameCount ?? this.honeyFrameCount,
      frameStandard: frameStandard ?? this.frameStandard,
      boxCount: boxCount ?? this.boxCount,
      superBoxCount: superBoxCount ?? this.superBoxCount,
      framesPerBox: framesPerBox ?? this.framesPerBox,
      maxBroodFrameCount: maxBroodFrameCount ?? this.maxBroodFrameCount,
      maxHoneyFrameCount: maxHoneyFrameCount ?? this.maxHoneyFrameCount,
      maxBoxCount: maxBoxCount ?? this.maxBoxCount,
      maxSuperBoxCount: maxSuperBoxCount ?? this.maxSuperBoxCount,      accessories: accessories ?? this.accessories,
      country: country ?? this.country,
      isLocal: isLocal ?? this.isLocal,
      isStarred: isStarred ?? this.isStarred,
      cost: cost ?? this.cost,
    );
  }
}
