import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

class HistoryLog extends Equatable {
  final String id;
  final String entityId;
  final EntityType entityType; // 'queen', 'hive', etc.
  final HistoryAction action;
  final DateTime timestamp;
  final String? description;
  /// Optional group ID to group related history logs together
  final String? groupId;
  /// Number of logs in this group, only populated when returning distinct/grouped logs
  final int? logCount;
  /// Changes in format:
  /// {
  ///   "fieldName": {
  ///     "old": "previous value", 
  ///     "new": "new value"
  ///   }
  /// }
  final Map<String, dynamic>? changes;
  
  const HistoryLog({
    required this.id,
    required this.entityId,
    required this.entityType,
    required this.action,
    required this.timestamp,
    this.description,
    this.groupId,
    this.logCount,
    this.changes,
  });
  
  @override
  List<Object?> get props => [
    id, entityId, entityType, action, timestamp, changes, description, groupId, logCount
  ];
  
  HistoryLog copyWith({
    String? id,
    String? entityId,
    EntityType? entityType,
    HistoryAction? action,
    DateTime? timestamp,
    String? Function()? description,
    String? Function()? groupId,
    int? Function()? logCount,
    Map<String, dynamic>? Function()? changes,
  }) {
    return HistoryLog(
      id: id ?? this.id,
      entityId: entityId ?? this.entityId,
      entityType: entityType ?? this.entityType,
      action: action ?? this.action,
      timestamp: timestamp ?? this.timestamp,
      description: description != null ? description() : this.description,
      groupId: groupId != null ? groupId() : this.groupId,
      logCount: logCount != null ? logCount() : this.logCount,
      changes: changes != null ? changes() : this.changes,
    );
  }
}
