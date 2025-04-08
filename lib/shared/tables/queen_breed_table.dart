import 'package:apiarium/shared/tables/base_table.dart';

class QueenBreedTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'queen_breeds';
  @override
  String get alias => 'qb';

  // Column names (snake_case in database)
  String get id => 'id';
  String get name => 'name';
  String get scientificName => 'scientific_name';
  String get origin => 'origin';
  String get priority => 'priority';
  String get country => 'country';
  String get isStarred => 'is_starred';
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';
  String get updatedAt => 'updated_at';

  // Aliased column names (snake_case in database)
  String get xId => '${alias}_$id';
  String get xName => '${alias}_$name';
  String get xScientificName => '${alias}_$scientificName';
  String get xOrigin => '${alias}_$origin';
  String get xPriority => '${alias}_$priority';
  String get xCountry => '${alias}_$country';
  String get xIsStarred => '${alias}_$isStarred';
  String get xIsDeleted => '${alias}_$isDeleted';
  String get xIsSynced => '${alias}_$isSynced';
  String get xUpdatedAt => '${alias}_$updatedAt';

  // SELECT query helpers
  @override
  String get select => '''
    $tableName.$id AS ${alias}_$id,
    $tableName.$name AS ${alias}_$name,
    $tableName.$scientificName AS ${alias}_$scientificName,
    $tableName.$origin AS ${alias}_$origin,
    $tableName.$priority AS ${alias}_$priority,
    $tableName.$country AS ${alias}_$country,
    $tableName.$isStarred AS ${alias}_$isStarred,
    $tableName.$isDeleted AS ${alias}_$isDeleted,
    $tableName.$isSynced AS ${alias}_$isSynced,
    $tableName.$updatedAt AS ${alias}_$updatedAt
  ''';

  // Table creation query
  @override
  String get createTableQuery => '''
    CREATE TABLE $tableName (
      $id TEXT PRIMARY KEY,
      $name TEXT NOT NULL,
      $scientificName TEXT,
      $origin TEXT,
      $priority INTEGER NOT NULL DEFAULT 0,
      $country TEXT,
      $isStarred INTEGER NOT NULL DEFAULT 0,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0,
      $updatedAt TEXT NOT NULL
    )
  ''';
}