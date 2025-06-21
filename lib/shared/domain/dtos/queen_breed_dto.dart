// import 'package:apiarium/shared/shared.dart';

// class QueenBreedDto extends BaseDto {
//   final String id;
//   final String name;
//   final String? scientificName;
//   final String? origin;
  
//   // Sorting and filtering fields
//   final int priority;
//   final String? country;
//   final bool isStarred;
  
//   const QueenBreedDto({
//     required this.id,
//     required this.name,
//     this.scientificName,
//     this.origin,
//     this.priority = 0,
//     this.country,
//     this.isStarred = false,
//     // BaseDto fields
//     super.isDeleted,
//     super.isSynced,
//     required super.updatedAt,
//   });

//   factory QueenBreedDto.fromModel(QueenBreed model, {
//     bool isDeleted = false,
//     bool isSynced = false,
//     DateTime? updatedAt,
//   }) {
//     return QueenBreedDto(
//       id: model.id,
//       name: model.name,
//       scientificName: model.scientificName,
//       origin: model.origin,
//       priority: model.priority,
//       country: model.country,
//       isStarred: model.isStarred,
//       isDeleted: isDeleted,
//       isSynced: isSynced,
//       updatedAt: updatedAt ?? DateTime.now(),
//     );
//   }

//   @override
//   List<Object?> get props => [
//     id, name, scientificName, origin,
//     priority, country, isStarred,
//     ...super.props, // Include BaseDto props
//   ];

//   Map<String, dynamic> toMap() => {
//     'id': id,
//     'name': name,
//     'scientific_name': scientificName,
//     'origin': origin,
//     'priority': priority,
//     'country': country,
//     'is_starred': isStarred ? 1 : 0,
//     ...super.toSyncMap(), // Include sync fields
//   };

//   factory QueenBreedDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) {
//     return QueenBreedDto(
//       id: map['${prefix}id'],
//       name: map['${prefix}name'],
//       scientificName: map['${prefix}scientific_name'],
//       origin: map['${prefix}origin'],
//       priority: map['${prefix}priority'] ?? 0,
//       country: map['${prefix}country'],
//       isStarred: map['${prefix}is_starred'] == 1 || map['${prefix}is_starred'] == true,
//       // Extract sync fields
//       isDeleted: map['${prefix}is_deleted'] == 1,
//       isSynced: map['${prefix}is_synced'] == 1,
//       updatedAt: DateTime.parse(map['${prefix}updated_at']),
//     );
//   }

//   QueenBreed toModel() {
//     return QueenBreed(
//       id: id,
//       name: name,
//       scientificName: scientificName,
//       origin: origin,
//       priority: priority,
//       country: country,
//       isStarred: isStarred,
//     );
//   }
// }