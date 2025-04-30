import 'package:apiarium/shared/tables/base_table.dart';

class ReportTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'reports';
  @override
  String get alias => 'r';

  // Column names (snake_case in database)
  String get id => 'id';
  String get name => 'name';
  String get type => 'type';
  String get createdAt => 'created_at';
  String get updatedAt => 'updated_at';
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';
  String get hiveId => 'hive_id';
  String get queenId => 'queen_id';
  String get apiaryId => 'apiary_id';

  // Aliased column names (snake_case in database)
  String get xId => '${alias}_$id';
  String get xName => '${alias}_$name';
  String get xType => '${alias}_$type';
  String get xCreatedAt => '${alias}_$createdAt';
  String get xUpdatedAt => '${alias}_$updatedAt';
  String get xIsDeleted => '${alias}_$isDeleted';
  String get xIsSynced => '${alias}_$isSynced';
  String get xHiveId => '${alias}_$hiveId';
  String get xQueenId => '${alias}_$queenId';
  String get xApiaryId => '${alias}_$apiaryId';

  // SELECT query helpers
  @override
  String get select => '''
    $tableName.$id AS ${alias}_$id,
    $tableName.$name AS ${alias}_$name,
    $tableName.$type AS ${alias}_$type,
    $tableName.$createdAt AS ${alias}_$createdAt,
    $tableName.$updatedAt AS ${alias}_$updatedAt,
    $tableName.$isDeleted AS ${alias}_$isDeleted,
    $tableName.$isSynced AS ${alias}_$isSynced,
    $tableName.$hiveId AS ${alias}_$hiveId,
    $tableName.$queenId AS ${alias}_$queenId,
    $tableName.$apiaryId AS ${alias}_$apiaryId
  ''';

  // Table creation query
  @override
  String get createTableQuery => '''
    CREATE TABLE $tableName (
      $id TEXT PRIMARY KEY,
      $name TEXT NOT NULL,
      $type TEXT NOT NULL,
      $createdAt TEXT NOT NULL,
      $updatedAt TEXT NOT NULL,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0,
      $hiveId TEXT NOT NULL,
      $queenId TEXT,
      $apiaryId TEXT
    )
  ''';
}