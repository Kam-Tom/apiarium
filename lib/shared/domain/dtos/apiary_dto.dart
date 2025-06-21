// import 'package:apiarium/shared/shared.dart';

// class ApiaryDto extends BaseDto {
//   final String id;
//   final String name;
//   final String? description;
//   final String? location;
//   final int position;
//   final String? imageUrl;
//   final DateTime createdAt;

//   final double? latitude;
//   final double? longitude;
//   final bool isMigratory;
//   final String? hexColor;
//   final ApiaryStatus status;

//   const ApiaryDto({
//     required this.id,
//     required this.name,
//     this.description,
//     this.location,
//     required this.position,
//     this.imageUrl,
//     required this.createdAt,
//     this.latitude,
//     this.longitude,
//     this.isMigratory = false,
//     this.hexColor,
//     this.status = ApiaryStatus.active,
//     // BaseDto fields
//     super.isDeleted = false,
//     super.isSynced = false,
//     required super.updatedAt,
//   });

//   /// Creates an ApiaryDto from a database map
//   factory ApiaryDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) {
//     return ApiaryDto(
//       id: map['${prefix}id'],
//       name: map['${prefix}name'],
//       description: map['${prefix}description'],
//       location: map['${prefix}location'],
//       position: map['${prefix}position'],
//       imageUrl: map['${prefix}image_url'],
//       createdAt: DateTime.parse(map['${prefix}created_at']),
//       latitude: map['${prefix}latitude'],
//       longitude: map['${prefix}longitude'],
//       isMigratory: map['${prefix}is_migratory'] == 1 || map['${prefix}is_migratory'] == true,
//       hexColor: map['${prefix}hex_color'],
//       status: ApiaryStatus.values[map['${prefix}status'] ?? 0],
//       // Extract sync fields
//       isDeleted: map['${prefix}is_deleted'] == 1 || map['${prefix}is_deleted'] == true,
//       isSynced: map['${prefix}is_synced'] == 1 || map['${prefix}is_synced'] == true,
//       updatedAt: DateTime.parse(map['${prefix}updated_at']),
//     );
//   }

//   /// Creates an ApiaryDto from an Apiary model
//   factory ApiaryDto.fromModel(
//     Apiary apiary, {
//     required bool isDeleted,
//     required bool isSynced,
//     required DateTime updatedAt,
//   }) {
//     return ApiaryDto(
//       id: apiary.id,
//       name: apiary.name,
//       description: apiary.description,
//       location: apiary.location,
//       position: apiary.position,
//       imageUrl: apiary.imageUrl,
//       createdAt: apiary.createdAt,
//       latitude: apiary.latitude,
//       longitude: apiary.longitude,
//       isMigratory: apiary.isMigratory,
//       hexColor: apiary.color?.toHex(),
//       status: apiary.status,
//       isDeleted: isDeleted,
//       isSynced: isSynced,
//       updatedAt: updatedAt,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'description': description,
//       'location': location,
//       'position': position,
//       'image_url': imageUrl,
//       'created_at': createdAt.toIso8601String(),
//       'latitude': latitude,
//       'longitude': longitude,
//       'is_migratory': isMigratory,
//       'hex_color': hexColor,
//       'status': status.index,
//       ...super.toSyncMap(), // Include sync fields
//     };
//   }
  
//   Apiary toModel() {
//     return Apiary(
//       id: id,
//       name: name,
//       description: description,
//       location: location,
//       position: position,
//       imageUrl: imageUrl,
//       createdAt: createdAt,
//       latitude: latitude,
//       longitude: longitude,
//       isMigratory: isMigratory,
//       color: hexColor?.toColor(),
//       status: status,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     id, 
//     name, 
//     description, 
//     location, 
//     position,
//     imageUrl,
//     createdAt,
//     latitude, 
//     longitude, 
//     isMigratory,
//     hexColor,
//     status,
//     ...super.props
//   ];
// }