import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

/// Data Transfer Object for history logs with database mapping
class HistoryLogDto extends Equatable {
  final String id;
  final String entityId;
  final EntityType entityType;
  final HistoryAction action;
  final DateTime timestamp;
  final String? description;
  /// JSON payload containing changes in format:
  /// {
  ///   "fieldName": {
  ///     "old": "previous value", 
  ///     "new": "new value"
  ///   },
  ///   "anotherField": {
  ///     "old": 123, 
  ///     "new": 456
  ///   }
  /// }
  final String? jsonPayload;
  
  // For sync with backend
  final bool isSynced;
  final bool isDeleted;
  
  const HistoryLogDto({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.timestamp,
    this.description,
    this.jsonPayload,
    this.isSynced = false,
    this.isDeleted = false,
  });
  
  @override
  List<Object?> get props => [
    id, entityId, entityType, action, timestamp, 
    description, jsonPayload, isSynced, isDeleted
  ];
  
  Map<String, dynamic> toMap() => {
    'id': id,
    'entity_id': entityId,
    'entity_type': entityType.name,
    'action': action.name,
    'timestamp': timestamp.toIso8601String(),
    'description': description,
    'json_payload': jsonPayload,
    'is_synced': isSynced ? 1 : 0,
    'is_deleted': isDeleted ? 1 : 0,
  };
  
  factory HistoryLogDto.fromMap(Map<String, dynamic> map, {String prefix = ''}) {
    return HistoryLogDto(
      id: map['${prefix}id'],
      entityId: map['${prefix}entity_d'],
      entityType: EntityType.values.byNameOrDefault(
        map['${prefix}entity_type'], 
        defaultValue: EntityType.apiary
      ),
      action: HistoryAction.values.byNameOrDefault(
        map['${prefix}action'], 
        defaultValue: HistoryAction.created
      ),
      timestamp: DateTime.parse(map['${prefix}timestamp']),
      description: map['${prefix}description'],
      jsonPayload: map['${prefix}json_payload'],
      isSynced: map['${prefix}is_synced'] == 1 || map['${prefix}is_synced'] == true,
      isDeleted: map['${prefix}is_deleted'] == 1 || map['${prefix}is_deleted'] == true,
    );
  }
  
  // Helper method to decode the JSON payload
  Map<String, dynamic>? get decodedPayload => 
      jsonPayload != null ? json.decode(jsonPayload!) : null;
  
  // Convert DTO to model
  HistoryLog toModel() => HistoryLog(
    id: id,
    entityId: entityId,
    entityType: entityType,
    action: action,
    timestamp: timestamp,
    description: description,
    changes: decodedPayload,
  );
}