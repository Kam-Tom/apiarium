import 'package:apiarium/shared/shared.dart';

class QueenDto extends BaseDto {
  final String id;
  final String name;  // Name or marking number
  final String breedId;
  final DateTime birthDate;
  final QueenSource source;
  final bool marked;
  final String? markColorHex;
  final QueenStatus status;
  final String? origin; // Where the queen comes from
  
  const QueenDto({
    required this.id,
    required this.name,
    required this.breedId,
    required this.birthDate,
    required this.source,
    required this.marked,
    this.markColorHex,
    required this.status,
    this.origin,
    // BaseDto fields
    super.isDeleted = false,
    super.isSynced = false,
    required super.updatedAt,
  });

  factory QueenDto.fromModel(Queen model, {
    bool isDeleted = false,
    bool isSynced = false,
    DateTime? updatedAt,
  }) {
    return QueenDto(
      id: model.id,
      name: model.name,
      breedId: model.breed.id,
      birthDate: model.birthDate,
      source: model.source,
      marked: model.marked,
      markColorHex: model.markColor?.toHex(),
      status: model.status,
      origin: model.origin,
      isDeleted: isDeleted,
      isSynced: isSynced,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id, name, breedId, birthDate, source, 
    marked, markColorHex, status, origin, 
    ...super.props,
  ];

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'breed_id': breedId,
    'birth_date': birthDate.toIso8601String(),
    'source': source.name,
    'marked': marked,
    'mark_color_hex': markColorHex,
    'status': status.name,
    'origin': origin,
    ...super.toSyncMap(),
  };

  factory QueenDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) => QueenDto(
    id: map['${prefix}id'],
    name: map['${prefix}name'],
    breedId: map['${prefix}breed_id'],
    birthDate: DateTime.parse(map['${prefix}birth_date']),
    source: QueenSource.values.byNameOrDefault(
      map['${prefix}source'],
      defaultValue: QueenSource.other,
    ),
    marked: map['${prefix}marked'] == 1 || map['${prefix}marked'] == true,
    markColorHex: map['${prefix}mark_color_hex'],
    status: QueenStatus.values.byNameOrDefault(
      map['${prefix}status'],
      defaultValue: QueenStatus.active,
    ),
    origin: map['${prefix}origin'],
    // Extract sync fields
    isDeleted: map['${prefix}is_deleted'] == 1 || map['${prefix}is_deleted'] == true,
    isSynced: map['${prefix}is_synced'] == 1 || map['${prefix}is_synced'] == true,
    updatedAt: DateTime.parse(map['${prefix}updated_at'] ?? DateTime.now().toIso8601String()),
  );

  Queen toModel({required QueenBreed breed, Apiary? apiary, Hive? hive}) {
    return Queen(
      id: id,
      name: name,
      breed: breed,
      birthDate: birthDate,
      source: source,
      marked: marked,
      markColor: markColorHex?.toColor(),
      status: status,
      origin: origin,
      apiary: apiary,
      hive: hive,
    );
  }
}
