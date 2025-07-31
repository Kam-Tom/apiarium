import 'package:apiarium/shared/shared.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class QueenBreed extends BaseModel {
  final String name;
  final String? scientificName;
  final String? origin;
  final String? country;
  final bool isStarred;
  final bool isLocal;
  final int? honeyProductionRating;      // 1-5 (low-high)
  final int? springDevelopmentRating;    // 1-5 (slow-fast)
  final int? gentlenessRating;           // 1-5 (aggressive-gentle)
  final int? swarmingTendencyRating;     // 1-5 (high-low)
  final int? winterHardinessRating;      // 1-5 (poor-excellent)
  final int? diseaseResistanceRating;    // 1-5 (poor-excellent)
  final int? heatToleranceRating;        // 1-5 (poor-excellent)  
  final String? characteristics;
  final String? imageName;
  final double? cost;

  const QueenBreed({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    super.serverVersion = 0,
    required this.name,
    this.scientificName,
    this.origin,
    this.country,
    this.isStarred = false,
    this.isLocal = false,
    this.honeyProductionRating,
    this.springDevelopmentRating,
    this.gentlenessRating,
    this.swarmingTendencyRating,
    this.winterHardinessRating,
    this.diseaseResistanceRating,
    this.heatToleranceRating,
    this.characteristics,
    this.imageName,
    this.cost,
  });

  Future<String?> getLocalImagePath() async {
    if (imageName == null || imageName!.isEmpty) return null;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final localPath = '${appDir.path}/images/queen_breeds/$imageName';
      final file = File(localPath);
      return await file.exists() ? localPath : null;
    } catch (e) {
      return null;
    }
  }

  factory QueenBreed.fromMap(Map<String, dynamic> data) {
    return QueenBreed(
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
      scientificName: data['scientificName'],
      origin: data['origin'],
      country: data['country'],
      isStarred: data['isStarred'] ?? false,
      isLocal: data['isLocal'] ?? false,
      honeyProductionRating: data['honeyProductionRating'],
      springDevelopmentRating: data['springDevelopmentRating'],
      gentlenessRating: data['gentlenessRating'],
      swarmingTendencyRating: data['swarmingTendencyRating'],
      winterHardinessRating: data['winterHardinessRating'],
      diseaseResistanceRating: data['diseaseResistanceRating'],
      heatToleranceRating: data['heatToleranceRating'],
      characteristics: data['characteristics'],
      imageName: data['imageName'],
      cost: data['cost']?.toDouble(),
    );
  }

  String get displayName => scientificName != null 
    ? '$name ($scientificName)'
    : name;

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, scientificName, origin, country, isStarred, isLocal, 
    honeyProductionRating, springDevelopmentRating, gentlenessRating, 
    swarmingTendencyRating, winterHardinessRating, diseaseResistanceRating, 
    heatToleranceRating, characteristics, imageName, cost
  ];

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'name': name,
      'scientificName': scientificName,
      'origin': origin,
      'country': country,
      'isStarred': isStarred,
      'isLocal': isLocal,
      'honeyProductionRating': honeyProductionRating,
      'springDevelopmentRating': springDevelopmentRating,
      'gentlenessRating': gentlenessRating,
      'swarmingTendencyRating': swarmingTendencyRating,
      'winterHardinessRating': winterHardinessRating,
      'diseaseResistanceRating': diseaseResistanceRating,
      'heatToleranceRating': heatToleranceRating,
      'characteristics': characteristics,
      'imageName': imageName,
      'cost': cost,
    };
  }

  QueenBreed copyWith({
    String Function()? name,
    String? Function()? scientificName,
    String? Function()? origin,
    String? Function()? country,
    bool Function()? isStarred,
    bool Function()? isLocal,
    int? Function()? honeyProductionRating,
    int? Function()? springDevelopmentRating,
    int? Function()? gentlenessRating,
    int? Function()? swarmingTendencyRating,
    int? Function()? winterHardinessRating,
    int? Function()? diseaseResistanceRating,
    int? Function()? heatToleranceRating,
    String? Function()? characteristics,
    String? Function()? imageName,
    double? Function()? cost,
    DateTime Function()? updatedAt,
    SyncStatus Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool Function()? deleted,
    int Function()? serverVersion,
  }) {
    return QueenBreed(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : SyncStatus.pending,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      serverVersion: serverVersion != null ? serverVersion() : this.serverVersion,
      name: name != null ? name() : this.name,
      scientificName: scientificName != null ? scientificName() : this.scientificName,
      origin: origin != null ? origin() : this.origin,
      country: country != null ? country() : this.country,
      isStarred: isStarred != null ? isStarred() : this.isStarred,
      isLocal: isLocal != null ? isLocal() : this.isLocal,
      honeyProductionRating: honeyProductionRating != null ? honeyProductionRating() : this.honeyProductionRating,
      springDevelopmentRating: springDevelopmentRating != null ? springDevelopmentRating() : this.springDevelopmentRating,
      gentlenessRating: gentlenessRating != null ? gentlenessRating() : this.gentlenessRating,
      swarmingTendencyRating: swarmingTendencyRating != null ? swarmingTendencyRating() : this.swarmingTendencyRating,
      winterHardinessRating: winterHardinessRating != null ? winterHardinessRating() : this.winterHardinessRating,
      diseaseResistanceRating: diseaseResistanceRating != null ? diseaseResistanceRating() : this.diseaseResistanceRating,
      heatToleranceRating: heatToleranceRating != null ? heatToleranceRating() : this.heatToleranceRating,
      characteristics: characteristics != null ? characteristics() : this.characteristics,
      imageName: imageName != null ? imageName() : this.imageName,
      cost: cost != null ? cost() : this.cost,
    );
  }
}
