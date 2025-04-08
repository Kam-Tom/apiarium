import 'package:apiarium/shared/tables/base_table.dart';

class HiveTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'hives';
  @override
  String get alias => 'h';

  // Column names (snake_case in database)
  String get id => 'id';
  String get name => 'name';
  String get apiaryId => 'apiary_id';
  String get hiveTypeId => 'hive_type_id';
  String get queenId => 'queen_id';
  String get status => 'status';
  String get acquisitionDate => 'acquisition_date';
  String get imageUrl => 'image_url';
  String get position => 'position';
  String get hexColor => 'hex_color';
  String get currentFrameCount => 'current_frame_count';
  String get currentBroodFrameCount => 'current_brood_frame_count';
  String get currentBroodBoxCount => 'current_brood_box_count';
  String get currentHoneySuperBoxCount => 'current_honey_super_box_count';
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';
  String get updatedAt => 'updated_at';

  // Aliased column names (snake_case in database)
  String get xId => '${alias}_$id';
  String get xName => '${alias}_$name';
  String get xApiaryId => '${alias}_$apiaryId';
  String get xHiveTypeId => '${alias}_$hiveTypeId';
  String get xQueenId => '${alias}_$queenId';
  String get xStatus => '${alias}_$status';
  String get xAcquisitionDate => '${alias}_$acquisitionDate';
  String get xImageUrl => '${alias}_$imageUrl';
  String get xPosition => '${alias}_$position';
  String get xHexColor => '${alias}_$hexColor';
  String get xCurrentFrameCount => '${alias}_$currentFrameCount';
  String get xCurrentBroodFrameCount => '${alias}_$currentBroodFrameCount';
  String get xCurrentBroodBoxCount => '${alias}_$currentBroodBoxCount';
  String get xCurrentHoneySuperBoxCount => '${alias}_$currentHoneySuperBoxCount';
  String get xIsDeleted => '${alias}_$isDeleted';
  String get xIsSynced => '${alias}_$isSynced';
  String get xUpdatedAt => '${alias}_$updatedAt';

  // SELECT query helpers
  @override
  String get select => '''
    $tableName.$id AS ${alias}_$id,
    $tableName.$name AS ${alias}_$name,
    $tableName.$apiaryId AS ${alias}_$apiaryId,
    $tableName.$hiveTypeId AS ${alias}_$hiveTypeId,
    $tableName.$queenId AS ${alias}_$queenId,
    $tableName.$status AS ${alias}_$status,
    $tableName.$acquisitionDate AS ${alias}_$acquisitionDate,
    $tableName.$imageUrl AS ${alias}_$imageUrl,
    $tableName.$position AS ${alias}_$position,
    $tableName.$hexColor AS ${alias}_$hexColor,
    $tableName.$currentFrameCount AS ${alias}_$currentFrameCount,
    $tableName.$currentBroodFrameCount AS ${alias}_$currentBroodFrameCount,
    $tableName.$currentBroodBoxCount AS ${alias}_$currentBroodBoxCount,
    $tableName.$currentHoneySuperBoxCount AS ${alias}_$currentHoneySuperBoxCount,
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
      $apiaryId TEXT,
      $hiveTypeId TEXT NOT NULL,
      $queenId TEXT,
      $status TEXT NOT NULL,
      $acquisitionDate TEXT NOT NULL,
      $imageUrl TEXT,
      $position INTEGER NOT NULL,
      $hexColor TEXT,
      $currentFrameCount INTEGER,
      $currentBroodFrameCount INTEGER,
      $currentBroodBoxCount INTEGER,
      $currentHoneySuperBoxCount INTEGER,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0,
      $updatedAt TEXT NOT NULL,
      FOREIGN KEY ($apiaryId) REFERENCES apiaries (id),
      FOREIGN KEY ($hiveTypeId) REFERENCES hive_types (id),
      FOREIGN KEY ($queenId) REFERENCES queens (id)
    )
  ''';
}