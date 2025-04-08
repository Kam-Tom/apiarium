import 'package:apiarium/shared/tables/base_table.dart';

class ApiaryTable extends BaseTable {
  // Table definition
  @override
  String get tableName => 'apiaries';
  @override
  String get alias => 'a';

  // Column names (snake_case in database)
  String get id => 'id';
  String get name => 'name';
  String get description => 'description';
  String get location => 'location';
  String get position => 'position';
  String get imageUrl => 'image_url';
  String get createdAt => 'created_at';
  String get latitude => 'latitude';
  String get longitude => 'longitude';
  String get isMigratory => 'is_migratory';
  String get hexColor => 'hex_color';
  String get status => 'status';
  String get isDeleted => 'is_deleted';
  String get isSynced => 'is_synced';
  String get updatedAt => 'updated_at';

  // Aliased column names (snake_case in database)
  String get xId => '${alias}_$id';
  String get xName => '${alias}_$name';
  String get xDescription => '${alias}_$description';
  String get xLocation => '${alias}_$location';
  String get xPosition => '${alias}_$position';
  String get xImageUrl => '${alias}_$imageUrl';
  String get xCreatedAt => '${alias}_$createdAt';
  String get xLatitude => '${alias}_$latitude';
  String get xLongitude => '${alias}_$longitude';
  String get xIsMigratory => '${alias}_$isMigratory';
  String get xHexColor => '${alias}_$hexColor';
  String get xStatus => '${alias}_$status';
  String get xIsDeleted => '${alias}_$isDeleted';
  String get xIsSynced => '${alias}_$isSynced';
  String get xUpdatedAt => '${alias}_$updatedAt';

  // SELECT query helpers
  @override
  String get select => '''
    $tableName.$id AS ${alias}_$id,
    $tableName.$name AS ${alias}_$name,
    $tableName.$description AS ${alias}_$description,
    $tableName.$location AS ${alias}_$location,
    $tableName.$position AS ${alias}_$position,
    $tableName.$imageUrl AS ${alias}_$imageUrl,
    $tableName.$createdAt AS ${alias}_$createdAt,
    $tableName.$latitude AS ${alias}_$latitude,
    $tableName.$longitude AS ${alias}_$longitude,
    $tableName.$isMigratory AS ${alias}_$isMigratory,
    $tableName.$hexColor AS ${alias}_$hexColor,
    $tableName.$status AS ${alias}_$status,
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
      $description TEXT,
      $location TEXT,
      $position INTEGER NOT NULL,
      $imageUrl TEXT,
      $createdAt TEXT NOT NULL,
      $latitude REAL,
      $longitude REAL,
      $isMigratory INTEGER NOT NULL DEFAULT 0,
      $hexColor TEXT,
      $status INTEGER NOT NULL DEFAULT 0,
      $isDeleted INTEGER NOT NULL DEFAULT 0,
      $isSynced INTEGER NOT NULL DEFAULT 0,
      $updatedAt TEXT NOT NULL
    )
  ''';
}