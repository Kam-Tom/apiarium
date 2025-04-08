import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

class HistoryLog extends Equatable {
  final String id;
  final String entityId;
  final EntityType entityType; // 'queen', 'hive', etc.
  final HistoryAction action;
  final DateTime timestamp;
  final String? description;
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
    this.changes,
  });
  
  @override
  List<Object?> get props => [
    id, entityId, entityType, action, timestamp, changes, description
  ];
}
