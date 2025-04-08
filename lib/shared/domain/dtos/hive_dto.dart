import 'package:apiarium/shared/shared.dart';

class HiveDto extends BaseDto {
  final String id;
  final String name;
  final String? apiaryId;
  final String hiveTypeId;
  final String? queenId;
  final HiveStatus status;
  final DateTime acquisitionDate;
  final String? imageUrl;
  final int position;
  final String? hexColor;
  final int? currentFrameCount;
  final int? currentBroodFrameCount;
  final int? currentBroodBoxCount;
  final int? currentHoneySuperBoxCount;

  const HiveDto({
    required this.id,
    required this.name,
    required this.apiaryId,
    required this.hiveTypeId,
    this.queenId,
    required this.status,
    required this.acquisitionDate,
    this.imageUrl,
    required this.position,
    this.hexColor,
    this.currentFrameCount,
    this.currentBroodFrameCount,
    this.currentBroodBoxCount,
    this.currentHoneySuperBoxCount,
    // BaseDto fields
    super.isDeleted = false,
    super.isSynced = false,
    required super.updatedAt,
  });

  factory HiveDto.fromModel(Hive model, {
    bool isDeleted = false,
    bool isSynced = false,
    DateTime? updatedAt,
  }) {
    return HiveDto(
      id: model.id,
      name: model.name,
      apiaryId: model.apiary?.id,
      hiveTypeId: model.hiveType.id,
      queenId: model.queen?.id,
      status: model.status,
      acquisitionDate: model.acquisitionDate,
      imageUrl: model.imageUrl,
      position: model.position,
      hexColor: model.color?.toHex(),
      currentFrameCount: model.currentFrameCount,
      currentBroodFrameCount: model.currentBroodFrameCount,
      currentBroodBoxCount: model.currentBroodBoxCount,
      currentHoneySuperBoxCount: model.currentHoneySuperBoxCount,
      isDeleted: isDeleted,
      isSynced: isSynced,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    apiaryId,
    hiveTypeId,
    queenId,
    status,
    acquisitionDate,
    imageUrl,
    position,
    hexColor,
    currentFrameCount,
    currentBroodFrameCount,
    currentBroodBoxCount,
    currentHoneySuperBoxCount,
    ...super.props,
  ];

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'apiary_id': apiaryId,
    'hive_type_id': hiveTypeId,
    'queen_id': queenId,
    'status': status.name,
    'acquisition_date': acquisitionDate.toIso8601String(),
    'image_url': imageUrl,
    'position': position,
    'hex_color': hexColor,
    'current_frame_count': currentFrameCount,
    'current_brood_frame_count': currentBroodFrameCount,
    'current_brood_box_count': currentBroodBoxCount,
    'current_honey_super_box_count': currentHoneySuperBoxCount,
    ...super.toSyncMap(),
  };

  factory HiveDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) => HiveDto(
    id: map['${prefix}id'],
    name: map['${prefix}name'],
    apiaryId: map['${prefix}apiary_id'],
    hiveTypeId: map['${prefix}hive_type_id'],
    queenId: map['${prefix}queen_id'],
    status: HiveStatus.values.byNameOrDefault(
      map['${prefix}status'], 
      defaultValue: HiveStatus.active
    ),
    acquisitionDate: DateTime.parse(map['${prefix}acquisition_date']),
    imageUrl: map['${prefix}image_url'],
    position: map['${prefix}position'],
    hexColor: map['${prefix}hex_color'],
    currentFrameCount: map['${prefix}current_frame_count'],
    currentBroodFrameCount: map['${prefix}current_brood_frame_count'],
    currentBroodBoxCount: map['${prefix}current_brood_box_count'],
    currentHoneySuperBoxCount: map['${prefix}current_honey_super_box_count'],
    // Extract sync fields
    isDeleted: map['${prefix}is_deleted'] == 1 || map['${prefix}is_deleted'] == true,
    isSynced: map['${prefix}is_synced'] == 1 || map['${prefix}is_synced'] == true,
    updatedAt: DateTime.parse(map['${prefix}updated_at'] ?? DateTime.now().toIso8601String()),
  );
  
  Hive toModel({
    Apiary? apiary,
    required HiveType hiveType,
    Queen? queen,
  }) {
    return Hive(
      id: id,
      name: name,
      apiary: apiary,
      hiveType: hiveType,
      queen: queen,
      status: status,
      acquisitionDate: acquisitionDate,
      imageUrl: imageUrl,
      position: position,
      color: hexColor?.toColor(),
      currentFrameCount: currentFrameCount,
      currentBroodFrameCount: currentBroodFrameCount,
      currentBroodBoxCount: currentBroodBoxCount,
      currentHoneySuperBoxCount: currentHoneySuperBoxCount,
    );
  }
}
