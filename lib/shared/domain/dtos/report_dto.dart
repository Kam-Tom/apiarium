// import 'package:apiarium/shared/shared.dart';

// class ReportDto extends BaseDto {
//   final String id;
//   final String name;
//   final String type;
//   final DateTime createdAt;
//   final String hiveId;
//   final String? queenId;
//   final String? apiaryId;
  
//   const ReportDto({
//     required this.id,
//     required this.name,
//     required this.type,
//     required this.createdAt,
//     required this.hiveId,
//     this.queenId,
//     this.apiaryId,
//     // BaseDto fields
//     super.isDeleted = false,
//     super.isSynced = false,
//     required super.updatedAt,
//   });

//   factory ReportDto.fromModel(Report model, {
//     bool isDeleted = false,
//     bool isSynced = false,
//     DateTime? updatedAt,
//   }) {
//     return ReportDto(
//       id: model.id,
//       name: model.name,
//       type: model.type.name,
//       createdAt: model.createdAt,
//       hiveId: model.hiveId,
//       queenId: model.queenId,
//       apiaryId: model.apiaryId,
//       isDeleted: isDeleted,
//       isSynced: isSynced,
//       updatedAt: updatedAt ?? DateTime.now(),
//     );
//   }

//   @override
//   List<Object?> get props => [
//     id, name, type, createdAt, hiveId, queenId, apiaryId,
//     ...super.props,
//   ];

//   Map<String, dynamic> toMap() => {
//     'id': id,
//     'name': name,
//     'type': type,
//     'created_at': createdAt.toIso8601String(),
//     'hive_id': hiveId,
//     'queen_id': queenId,
//     'apiary_id': apiaryId,
//     ...super.toSyncMap(),
//   };

//   factory ReportDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) => ReportDto(
//     id: map['${prefix}id'],
//     name: map['${prefix}name'],
//     type: map['${prefix}type'],
//     createdAt: DateTime.parse(map['${prefix}created_at']),
//     hiveId: map['${prefix}hive_id'],
//     queenId: map['${prefix}queen_id'],
//     apiaryId: map['${prefix}apiary_id'],
//     // Extract sync fields
//     isDeleted: map['${prefix}is_deleted'] == 1 || map['${prefix}is_deleted'] == true,
//     isSynced: map['${prefix}is_synced'] == 1 || map['${prefix}is_synced'] == true,
//     updatedAt: DateTime.parse(map['${prefix}updated_at']),
//   );

//   Report toModel({List<Field>? fields}) {
//     return Report(
//       id: id,
//       name: name,
//       type: ReportType.values.firstWhere(
//         (e) => e.name == type,
//         orElse: () => ReportType.inspection,
//       ),
//       createdAt: createdAt,
//       hiveId: hiveId,
//       queenId: queenId,
//       apiaryId: apiaryId,
//       fields: fields,
//     );
//   }

//   ReportDto copyWith({
//     String Function()? id,
//     String Function()? name,
//     String Function()? type,
//     DateTime Function()? createdAt,
//     String Function()? hiveId,
//     String? Function()? queenId,
//     String? Function()? apiaryId,
//     bool Function()? isDeleted,
//     bool Function()? isSynced,
//     DateTime Function()? updatedAt,
//   }) {
//     return ReportDto(
//       id: id != null ? id() : this.id,
//       name: name != null ? name() : this.name,
//       type: type != null ? type() : this.type,
//       createdAt: createdAt != null ? createdAt() : this.createdAt,
//       hiveId: hiveId != null ? hiveId() : this.hiveId,
//       queenId: queenId != null ? queenId() : this.queenId,
//       apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
//       isDeleted: isDeleted != null ? isDeleted() : this.isDeleted,
//       isSynced: isSynced != null ? isSynced() : this.isSynced,
//       updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
//     );
//   }
// }
