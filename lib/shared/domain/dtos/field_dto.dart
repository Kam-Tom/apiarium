// import 'package:apiarium/shared/shared.dart';
// import 'package:equatable/equatable.dart';

// class FieldDto extends Equatable {
//   final String reportId;
//   final String attributeId;
//   final String value;
//   final DateTime createdAt; // Add createdAt property

//   const FieldDto({
//     required this.reportId,
//     required this.attributeId,
//     required this.value,
//     required this.createdAt, // Add createdAt to constructor
//   });

//   factory FieldDto.fromModel(Field model) {
//     return FieldDto(
//       reportId: model.reportId,
//       attributeId: model.attributeId,
//       value: model.value.toString(),
//       createdAt: model.createdAt, // Add createdAt to fromModel
//     );
//   }

//   @override
//   List<Object?> get props => [
//     reportId, 
//     attributeId, 
//     value,
//     createdAt, // Add createdAt to props
//   ];

//   Map<String, dynamic> toMap() => {
//     'report_id': reportId,
//     'attribute_id': attributeId,
//     'value': value,
//     'created_at': createdAt.toIso8601String(), // Add createdAt to map
//   };

//   factory FieldDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) => FieldDto(
//     reportId: map['${prefix}report_id'],
//     attributeId: map['${prefix}attribute_id'],
//     value: map['${prefix}value'] ?? '',
//     createdAt: DateTime.parse(map['${prefix}created_at']), // Parse createdAt
//   );

//   Field toModel() {
//     // Find the attribute enum based on the ID
//     final attribute = Attribute.values.firstWhere(
//       (attr) => attr.name == attributeId,
//       orElse: () => Attribute.none, // Default fallback
//     );
    
//     return Field(
//       reportId: reportId,
//       attributeId: attributeId,
//       value: value,
//       attribute: attribute,
//       createdAt: createdAt, // Map createdAt to model
//     );
//   }
// }
