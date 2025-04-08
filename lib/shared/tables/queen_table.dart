import 'package:apiarium/shared/tables/base_table.dart';

class QueenTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'queens';
  @override
  String get alias => 'q';

  // Column names (snake_case in database)
  String get id => 'id';
  String get name => 'name';
  String get breedId => 'breed_id';
  String get birthDate => 'birth_date';
  String get source => 'source';
  String get marked => 'marked';
  String get markColorHex => 'mark_color_hex';
  String get status => 'status';
  String get origin => 'origin';
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';
  String get updatedAt => 'updated_at';

  // Aliased column names (snake_case in database)
  String get xId => '${alias}_$id';
  String get xName => '${alias}_$name';
  String get xBreedId => '${alias}_$breedId';
  String get xBirthDate => '${alias}_$birthDate';
  String get xSource => '${alias}_$source';
  String get xMarked => '${alias}_$marked';
  String get xMarkColorHex => '${alias}_$markColorHex';
  String get xStatus => '${alias}_$status';
  String get xOrigin => '${alias}_$origin';
  String get xIsDeleted => '${alias}_$isDeleted';
  String get xIsSynced => '${alias}_$isSynced';
  String get xUpdatedAt => '${alias}_$updatedAt';

  // SELECT query helpers
  @override
  String get select => '''
    $tableName.$id AS ${alias}_$id,
    $tableName.$name AS ${alias}_$name,
    $tableName.$breedId AS ${alias}_$breedId,
    $tableName.$birthDate AS ${alias}_$birthDate,
    $tableName.$source AS ${alias}_$source,
    $tableName.$marked AS ${alias}_$marked,
    $tableName.$markColorHex AS ${alias}_$markColorHex,
    $tableName.$status AS ${alias}_$status,
    $tableName.$origin AS ${alias}_$origin,
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
      $breedId TEXT NOT NULL,
      $birthDate TEXT NOT NULL,
      $source TEXT NOT NULL,
      $marked INTEGER NOT NULL DEFAULT 0,
      $markColorHex TEXT,
      $status TEXT NOT NULL,
      $origin TEXT,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0,
      $updatedAt TEXT NOT NULL,
      FOREIGN KEY ($breedId) REFERENCES queen_breeds (id)
    )
  ''';
}