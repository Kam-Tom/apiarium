import 'package:equatable/equatable.dart';

enum SyncStatus { synced, pending, failed }

abstract class BaseModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final bool deleted;
  final int serverVersion;

  const BaseModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.lastSyncedAt,
    this.deleted = false,
    this.serverVersion = 0,
  });

  Map<String, dynamic> get baseSyncFields => {
    'id': id,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'syncStatus': syncStatus.name,
    'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    'deleted': deleted,
    'serverVersion': serverVersion,
  };

  List<Object?> get baseSyncProps => [
    id, createdAt, updatedAt, syncStatus, lastSyncedAt, deleted, serverVersion
  ];
}
