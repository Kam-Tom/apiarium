import 'package:apiarium/shared/tables/base_table.dart';

class HiveTypeTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'hive_types';
  @override
  String get alias => 'ht';

  // Column names (snake_case in database)
  String get id => 'id';
  String get name => 'name';
  String get manufacturer => 'manufacturer';
  String get mainMaterial => 'main_material';
  String get hasFrames => 'has_frames';
  
  // Frame specifications
  String get defaultFrameCount => 'default_frame_count';
  String get frameWidth => 'frame_width';
  String get frameHeight => 'frame_height';
  String get broodFrameWidth => 'brood_frame_width';
  String get broodFrameHeight => 'brood_frame_height';
  String get frameStandard => 'frame_standard';
  String get broodBoxCount => 'brood_box_count';
  String get honeySuperBoxCount => 'honey_super_box_count';
  
  // Cost information
  String get hiveCost => 'hive_cost';
  String get currency => 'currency';
  String get frameUnitCost => 'frame_unit_cost';
  String get broodFrameUnitCost => 'brood_frame_unit_cost';
  String get broodBoxUnitCost => 'brood_box_unit_cost';
  String get honeySuperBoxUnitCost => 'honey_super_box_unit_cost';
  
  // Sorting and filtering fields
  String get priority => 'priority';
  String get country => 'country';
  String get isStarred => 'is_starred';
  
  // Base fields
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';
  String get updatedAt => 'updated_at';


  // Aliased column names (snake_case in database)
  String get xId => '${alias}_$id';
  String get xName => '${alias}_$name';
  String get xManufacturer => '${alias}_$manufacturer';
  String get xMainMaterial => '${alias}_$mainMaterial';
  String get xHasFrames => '${alias}_$hasFrames';
  String get xDefaultFrameCount => '${alias}_$defaultFrameCount';
  String get xFrameWidth => '${alias}_$frameWidth';
  String get xFrameHeight => '${alias}_$frameHeight';
  String get xBroodFrameWidth => '${alias}_$broodFrameWidth';
  String get xBroodFrameHeight => '${alias}_$broodFrameHeight';
  String get xFrameStandard => '${alias}_$frameStandard';
  String get xBroodBoxCount => '${alias}_$broodBoxCount';
  String get xHoneySuperBoxCount => '${alias}_$honeySuperBoxCount';
  String get xHiveCost => '${alias}_$hiveCost';
  String get xCurrency => '${alias}_$currency';
  String get xFrameUnitCost => '${alias}_$frameUnitCost';
  String get xBroodFrameUnitCost => '${alias}_$broodFrameUnitCost';
  String get xBroodBoxUnitCost => '${alias}_$broodBoxUnitCost';
  String get xHoneySuperBoxUnitCost => '${alias}_$honeySuperBoxUnitCost';
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
    $tableName.$manufacturer AS ${alias}_$manufacturer,
    $tableName.$mainMaterial AS ${alias}_$mainMaterial,
    $tableName.$hasFrames AS ${alias}_$hasFrames,
    $tableName.$defaultFrameCount AS ${alias}_$defaultFrameCount,
    $tableName.$frameWidth AS ${alias}_$frameWidth,
    $tableName.$frameHeight AS ${alias}_$frameHeight,
    $tableName.$broodFrameWidth AS ${alias}_$broodFrameWidth,
    $tableName.$broodFrameHeight AS ${alias}_$broodFrameHeight,
    $tableName.$frameStandard AS ${alias}_$frameStandard,
    $tableName.$broodBoxCount AS ${alias}_$broodBoxCount,
    $tableName.$honeySuperBoxCount AS ${alias}_$honeySuperBoxCount,
    $tableName.$hiveCost AS ${alias}_$hiveCost,
    $tableName.$currency AS ${alias}_$currency,
    $tableName.$frameUnitCost AS ${alias}_$frameUnitCost,
    $tableName.$broodFrameUnitCost AS ${alias}_$broodFrameUnitCost,
    $tableName.$broodBoxUnitCost AS ${alias}_$broodBoxUnitCost,
    $tableName.$honeySuperBoxUnitCost AS ${alias}_$honeySuperBoxUnitCost,
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
      $manufacturer TEXT,
      $mainMaterial TEXT NOT NULL,
      $hasFrames INTEGER NOT NULL DEFAULT 1,
      $defaultFrameCount INTEGER,
      $frameWidth REAL,
      $frameHeight REAL,
      $broodFrameWidth REAL,
      $broodFrameHeight REAL,
      $frameStandard TEXT,
      $broodBoxCount INTEGER,
      $honeySuperBoxCount INTEGER,
      $hiveCost REAL,
      $currency TEXT,
      $frameUnitCost REAL,
      $broodFrameUnitCost REAL,
      $broodBoxUnitCost REAL,
      $honeySuperBoxUnitCost REAL,
      $priority INTEGER NOT NULL DEFAULT 0,
      $country TEXT,
      $isStarred INTEGER NOT NULL DEFAULT 0,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0,
      $updatedAt TEXT NOT NULL
    )
  ''';
}