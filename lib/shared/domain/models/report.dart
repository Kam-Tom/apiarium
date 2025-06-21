import 'dart:core';

import 'package:apiarium/shared/shared.dart';
import 'package:equatable/equatable.dart';

class Report extends Equatable {
  final String id;
  final String name;
  final ReportType type;
  final DateTime createdAt;
  final List<Field>? fields;
  final String hiveId;
  final String? queenId;
  final String? apiaryId;

  const Report({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    required this.hiveId,
    this.fields,
    this.queenId,
    this.apiaryId,
  });

  @override
  List<Object?> get props => [
    id, 
    name, 
    type, 
    createdAt, 
    fields, 
    hiveId, 
    queenId, 
    apiaryId
  ];

  /// Get a field by attribute ID
  Field? getField(String attributeId) {
    if (fields == null) return null;
    try {
      return fields!.firstWhere((f) => f.attributeId == attributeId);
    } catch (_) {
      return null;
    }
  }

  /// Check if a field exists
  bool hasField(String attributeId) {
    return getField(attributeId) != null;
  }

  /// Get all field values as a map (for backward compatibility)
  Map<String, String> get fieldsAsMap {
    if (fields == null) return {};
    return {
      for (final field in fields!)
        field.attributeId: field.value
    };
  }

  /// Convert report to a flat map for comparing changes
  Map<String, String> toFlatMap() {
    final map = <String, String>{
      'id': id,
      'name': name,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'hiveId': hiveId,
    };
    
    if (queenId != null) map['queenId'] = queenId!;
    if (apiaryId != null) map['apiaryId'] = apiaryId!;
    
    // Add fields
    if (fields != null) {
      for (final field in fields!) {
        map[field.attributeId] = field.value;
      }
    }
    
    return map;
  }

  Report copyWith({
    String Function()? id,
    String Function()? name,
    ReportType Function()? type,
    DateTime Function()? createdAt,
    List<Field>? Function()? fields,
    String Function()? hiveId,
    String? Function()? queenId,
    String? Function()? apiaryId,
  }) {
    return Report(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      type: type != null ? type() : this.type,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      fields: fields != null ? fields() : this.fields,
      hiveId: hiveId != null ? hiveId() : this.hiveId,
      queenId: queenId != null ? queenId() : this.queenId,
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
    );
  }
}