import 'package:apiarium/shared/shared.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
  final int? maxSuperBoxCount;  
  final List<String>? accessories;
  final String? country;
  final bool isLocal;
  final bool isStarred;
  final double? cost;
  final String? imageName;
  final HiveIconType iconType;

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
    this.iconType = HiveIconType.beehive1,
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
      iconType: data['iconType'] != null
        ? HiveIconTypeExtension.fromString(data['iconType'])
        : HiveIconType.beehive1,
    );
  }

  String get displayName => manufacturer != null ? '$name ($manufacturer)' : name;
    
  @override
  List<Object?> get props => [
    ...baseSyncProps, name, manufacturer, material, hasFrames, broodFrameCount, honeyFrameCount,
    frameStandard, boxCount, superBoxCount, framesPerBox, maxBroodFrameCount,
    maxHoneyFrameCount, maxBoxCount, maxSuperBoxCount, accessories, country, isLocal, isStarred, cost, imageName, iconType
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
      'iconType': iconType.name,
    };
  }

  HiveType copyWith({
    String Function()? name,
    String? Function()? manufacturer,
    HiveMaterial Function()? material,
    bool Function()? hasFrames,
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
    bool Function()? isLocal,
    bool Function()? isStarred,
    double? Function()? cost,
    String? Function()? imageName,
    HiveIconType Function()? iconType,
    DateTime Function()? updatedAt,
    SyncStatus Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool Function()? deleted,
    int Function()? serverVersion,
  }) {
    return HiveType(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : SyncStatus.pending,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      serverVersion: serverVersion != null ? serverVersion() : this.serverVersion,
      name: name != null ? name() : this.name,
      manufacturer: manufacturer != null ? manufacturer() : this.manufacturer,
      material: material != null ? material() : this.material,
      hasFrames: hasFrames != null ? hasFrames() : this.hasFrames,
      broodFrameCount: broodFrameCount != null ? broodFrameCount() : this.broodFrameCount,
      honeyFrameCount: honeyFrameCount != null ? honeyFrameCount() : this.honeyFrameCount,
      frameStandard: frameStandard != null ? frameStandard() : this.frameStandard,
      boxCount: boxCount != null ? boxCount() : this.boxCount,
      superBoxCount: superBoxCount != null ? superBoxCount() : this.superBoxCount,
      framesPerBox: framesPerBox != null ? framesPerBox() : this.framesPerBox,
      maxBroodFrameCount: maxBroodFrameCount != null ? maxBroodFrameCount() : this.maxBroodFrameCount,
      maxHoneyFrameCount: maxHoneyFrameCount != null ? maxHoneyFrameCount() : this.maxHoneyFrameCount,
      maxBoxCount: maxBoxCount != null ? maxBoxCount() : this.maxBoxCount,
      maxSuperBoxCount: maxSuperBoxCount != null ? maxSuperBoxCount() : this.maxSuperBoxCount,
      accessories: accessories != null ? accessories() : this.accessories,
      country: country != null ? country() : this.country,
      isLocal: isLocal != null ? isLocal() : this.isLocal,
      isStarred: isStarred != null ? isStarred() : this.isStarred,
      cost: cost != null ? cost() : this.cost,
      imageName: imageName != null ? imageName() : this.imageName,
      iconType: iconType != null ? iconType() : this.iconType,
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
