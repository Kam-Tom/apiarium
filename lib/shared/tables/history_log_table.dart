import 'package:apiarium/shared/tables/base_table.dart';

class HistoryLogTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'history_logs';
  @override
  String get alias => 'hl';

  // Column names (snake_case in database)
  String get id => 'id';
  String get entityId => 'entity_id';
  String get entityType => 'entity_type';
  String get action => 'action';
  String get timestamp => 'timestamp';
  String get description => 'description';
  String get jsonPayload => 'json_payload';
  String get groupId => 'group_id';
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';

  // SELECT query helpers
  @override
  String get select => '''
    $tableName.$id AS ${alias}_$id,
    $tableName.$entityId AS ${alias}_$entityId,
    $tableName.$entityType AS ${alias}_$entityType,
    $tableName.$action AS ${alias}_$action,
    $tableName.$timestamp AS ${alias}_$timestamp,
    $tableName.$description AS ${alias}_$description,
    $tableName.$jsonPayload AS ${alias}_$jsonPayload,
    $tableName.$groupId AS ${alias}_$groupId,
    $tableName.$isDeleted AS ${alias}_$isDeleted,
    $tableName.$isSynced AS ${alias}_$isSynced
  ''';

  // Table creation query
  @override
  String get createTableQuery => '''
    CREATE TABLE $tableName (
      $id TEXT PRIMARY KEY,
      $entityId TEXT NOT NULL,
      $entityType TEXT NOT NULL,
      $action TEXT NOT NULL,
      $timestamp TEXT NOT NULL,
      $description TEXT,
      $jsonPayload TEXT,
      $groupId TEXT,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0
    )
  ''';
}