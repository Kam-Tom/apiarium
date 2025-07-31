import 'package:apiarium/shared/shared.dart';

enum HistoryActionType { create, update, delete }

class HistoryLog extends BaseModel {
  final String entityId;
  final String entityType; // 'apiary', 'hive', 'queen', 'hiveType', 'queenBreed', 'reportGroup'
  final String entityName; // Human readable name for display
  final Map<String, dynamic> changedFields;
  final Map<String, dynamic> previousValues;
  final HistoryActionType actionType;
  final DateTime timestamp;
  final String? groupId; // For grouping related operations (e.g., apiary reports)

  const HistoryLog({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    super.serverVersion = 0,
    required this.entityId,
    required this.entityType,
    required this.entityName,
    required this.changedFields,
    this.previousValues = const {},
    required this.actionType,
    required this.timestamp,
    this.groupId,
  });

  factory HistoryLog.fromMap(Map<String, dynamic> data) {
    return HistoryLog(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == data['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: data['lastSyncedAt'] != null 
          ? DateTime.parse(data['lastSyncedAt']) 
          : null,
      deleted: data['deleted'] ?? false,
      serverVersion: data['serverVersion'] ?? 0,
      entityId: data['entityId'],
      entityType: data['entityType'],
      entityName: data['entityName'],
      changedFields: Map<String, dynamic>.from(data['changedFields']),
      previousValues: data['previousValues'] != null 
          ? Map<String, dynamic>.from(data['previousValues']) 
          : {},
      actionType: HistoryActionType.values.firstWhere(
        (a) => a.name == data['actionType'],
        orElse: () => HistoryActionType.update,
      ),
      timestamp: DateTime.parse(data['timestamp']),
      groupId: data['groupId'],
    );
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    entityId,
    entityType,
    entityName,
    changedFields,
    previousValues,
    actionType,
    timestamp,
    groupId,
  ];

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'entityId': entityId,
      'entityType': entityType,
      'entityName': entityName,
      'changedFields': changedFields,
      'previousValues': previousValues,
      'actionType': actionType.name,
      'timestamp': timestamp.toIso8601String(),
      'groupId': groupId,
    };
  }

  HistoryLog copyWith({
    String Function()? entityId,
    String Function()? entityType,
    String Function()? entityName,
    Map<String, dynamic> Function()? changedFields,
    Map<String, dynamic> Function()? previousValues,
    HistoryActionType Function()? actionType,
    DateTime Function()? timestamp,
    DateTime Function()? updatedAt,
    SyncStatus Function()? syncStatus,
    DateTime Function()? lastSyncedAt,
    bool Function()? deleted,
    int Function()? serverVersion,
    String? Function()? groupId,
  }) {
    return HistoryLog(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : this.syncStatus,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      serverVersion: serverVersion != null ? serverVersion() : this.serverVersion,
      entityId: entityId != null ? entityId() : this.entityId,
      entityType: entityType != null ? entityType() : this.entityType,
      entityName: entityName != null ? entityName() : this.entityName,
      changedFields: changedFields != null ? changedFields() : this.changedFields,
      previousValues: previousValues != null ? previousValues() : this.previousValues,
      actionType: actionType != null ? actionType() : this.actionType,
      timestamp: timestamp != null ? timestamp() : this.timestamp,
      groupId: groupId != null ? groupId() : this.groupId,
    );
  }
  
  bool get isGrouped => groupId != null;
  
}
