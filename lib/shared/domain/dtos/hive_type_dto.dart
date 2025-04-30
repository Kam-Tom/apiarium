import 'package:apiarium/shared/shared.dart';

class HiveTypeDto extends BaseDto {
  final String id;
  final String name;
  final String? manufacturer;
  final HiveMaterial mainMaterial;
  final bool hasFrames;
  
  // Frame specifications
  final int? defaultFrameCount;
  final double? frameWidth;
  final double? frameHeight;
  final double? broodFrameWidth;
  final double? broodFrameHeight;
  final String? frameStandard;
  final int? broodBoxCount;
  final int? honeySuperBoxCount;
  
  // Cost information
  final double? hiveCost;
  final Currency? currency;
  final double? frameUnitCost;
  final double? broodFrameUnitCost;
  final double? broodBoxUnitCost;
  final double? honeySuperBoxUnitCost;
  
  // Sorting and filtering fields
  final int priority;
  final String? country;
  final bool isStarred;

  const HiveTypeDto({
    required this.id,
    required this.name,
    this.manufacturer,
    required this.mainMaterial,
    required this.hasFrames,
    this.defaultFrameCount,
    this.frameWidth,
    this.frameHeight,
    this.broodFrameWidth,
    this.broodFrameHeight,
    this.frameStandard,
    this.broodBoxCount,
    this.honeySuperBoxCount,
    this.hiveCost,
    this.currency,
    this.frameUnitCost,
    this.broodFrameUnitCost,
    this.broodBoxUnitCost,
    this.honeySuperBoxUnitCost,
    this.priority = 0,
    this.country,
    this.isStarred = false,
    // BaseDto fields
    super.isDeleted = false,
    super.isSynced = false,
    required super.updatedAt,
  });

  factory HiveTypeDto.fromModel(HiveType model, {
    bool isDeleted = false,
    bool isSynced = false,
    DateTime? updatedAt,
  }) {
    return HiveTypeDto(
      id: model.id,
      name: model.name,
      manufacturer: model.manufacturer,
      mainMaterial: model.mainMaterial,
      hasFrames: model.hasFrames,
      defaultFrameCount: model.defaultFrameCount,
      frameWidth: model.frameWidth,
      frameHeight: model.frameHeight,
      broodFrameWidth: model.broodFrameWidth,
      broodFrameHeight: model.broodFrameHeight,
      frameStandard: model.frameStandard,
      broodBoxCount: model.broodBoxCount,
      honeySuperBoxCount: model.honeySuperBoxCount,
      hiveCost: model.hiveCost,
      currency: model.currency,
      frameUnitCost: model.frameUnitCost,
      broodFrameUnitCost: model.broodFrameUnitCost,
      broodBoxUnitCost: model.broodBoxUnitCost,
      honeySuperBoxUnitCost: model.honeySuperBoxUnitCost,
      priority: model.priority,
      country: model.country,
      isStarred: model.isStarred,
      isDeleted: isDeleted,
      isSynced: isSynced,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    manufacturer,
    mainMaterial,
    hasFrames,
    defaultFrameCount,
    frameWidth,
    frameHeight,
    broodFrameWidth,
    broodFrameHeight,
    frameStandard,
    broodBoxCount,
    honeySuperBoxCount,
    hiveCost,
    currency,
    frameUnitCost,
    broodFrameUnitCost,
    broodBoxUnitCost,
    honeySuperBoxUnitCost,
    priority,
    country,
    isStarred,
    ...super.props,
  ];

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'manufacturer': manufacturer,
    'main_material': mainMaterial.name,
    'has_frames': hasFrames,
    'default_frame_count': defaultFrameCount,
    'frame_width': frameWidth,
    'frame_height': frameHeight,
    'brood_frame_width': broodFrameWidth,
    'brood_frame_height': broodFrameHeight,
    'frame_standard': frameStandard,
    'brood_box_count': broodBoxCount,
    'honey_super_box_count': honeySuperBoxCount,
    'hive_cost': hiveCost,
    'currency': currency?.name,
    'frame_unit_cost': frameUnitCost,
    'brood_frame_unit_cost': broodFrameUnitCost,
    'brood_box_unit_cost': broodBoxUnitCost,
    'honey_super_box_unit_cost': honeySuperBoxUnitCost,
    'priority': priority,
    'country': country,
    'is_starred': isStarred ? 1 : 0,
    ...super.toSyncMap(),
  };

  factory HiveTypeDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) => HiveTypeDto(
    id: map['${prefix}id'],
    name: map['${prefix}name'],
    manufacturer: map['${prefix}manufacturer'],
    mainMaterial: HiveMaterial.values.byNameOrDefault(
      map['${prefix}main_material'],
      defaultValue: HiveMaterial.other
    ),
    hasFrames: map['${prefix}has_frames'] == 1 || map['${prefix}has_frames'] == true,
    defaultFrameCount: map['${prefix}default_frame_count'],
    frameWidth: map['${prefix}frame_width'],
    frameHeight: map['${prefix}frame_height'],
    broodFrameWidth: map['${prefix}brood_frame_width'],
    broodFrameHeight: map['${prefix}brood_frame_height'],
    frameStandard: map['${prefix}frame_standard'],
    broodBoxCount: map['${prefix}brood_box_count'] != null ? 
        int.tryParse(map['${prefix}brood_box_count'].toString()) : null,
    honeySuperBoxCount: map['${prefix}honey_super_box_count'] != null ? 
        int.tryParse(map['${prefix}honey_super_box_count'].toString()) : null,
    hiveCost: map['${prefix}hive_cost'],
    currency: Currency.values.byNameOrNull(map['${prefix}currency']),
    frameUnitCost: map['${prefix}frame_unit_cost'],
    broodFrameUnitCost: map['${prefix}brood_frame_unit_cost'],
    broodBoxUnitCost: map['${prefix}brood_box_unit_cost'],
    honeySuperBoxUnitCost: map['${prefix}honey_super_box_unit_cost'],
    priority: map['${prefix}priority'] ?? 0,
    country: map['${prefix}country'],
    isStarred: map['${prefix}is_starred'] == 1 || map['${prefix}is_starred'] == true,
    // Extract sync fields
    isDeleted: map['${prefix}is_deleted'] == 1 || map['${prefix}is_deleted'] == true,
    isSynced: map['${prefix}is_synced'] == 1 || map['${prefix}is_synced'] == true,
    updatedAt: DateTime.parse(map['${prefix}updated_at'] ?? DateTime.now().toIso8601String()),
  );
  
  HiveType toModel() {
    return HiveType(
      id: id,
      name: name,
      manufacturer: manufacturer,
      mainMaterial: mainMaterial,
      hasFrames: hasFrames,
      defaultFrameCount: defaultFrameCount,
      frameWidth: frameWidth,
      frameHeight: frameHeight,
      broodFrameWidth: broodFrameWidth,
      broodFrameHeight: broodFrameHeight,
      frameStandard: frameStandard,
      broodBoxCount: broodBoxCount,
      honeySuperBoxCount: honeySuperBoxCount,
      hiveCost: hiveCost,
      currency: currency,
      frameUnitCost: frameUnitCost,
      broodFrameUnitCost: broodFrameUnitCost,
      broodBoxUnitCost: broodBoxUnitCost,
      honeySuperBoxUnitCost: honeySuperBoxUnitCost,
      priority: priority,
      country: country,
      isStarred: isStarred,
    );
  }
}

