import 'dart:ui';

import 'package:apiarium/shared/shared.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing hives in the database
class HiveRepository {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  HiveRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Retrieves all hives from the database with customizable related data.
  /// 
  /// Parameters:
  /// - [includeApiary]: Whether to include apiary information
  /// - [includeQueen]: Whether to include queen and breed information
  Future<List<Hive>> getAllHives({
    bool includeApiary = false,
    bool includeQueen = false,
  }) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    
    // Build SELECT clause
    String selectClause = '''
      SELECT ${hiveTable.select},
             ${hiveTypeTable.select}''';
    
    // Tables to join
    String fromClause = '''
      FROM ${hiveTable.tableName}
      JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}''';
    
    // Add apiary if needed
    if (includeApiary) {
      final apiaryTable = _databaseHelper.apiaryTable;
      selectClause += ''',
             ${apiaryTable.select}''';
      
      fromClause += '''
      LEFT JOIN ${apiaryTable.tableName}
        ON ${hiveTable.xApiaryId} = ${apiaryTable.xId}''';
    }
    
    // Add queen if needed
    if (includeQueen) {
      final queenTable = _databaseHelper.queenTable;
      final queenBreedTable = _databaseHelper.queenBreedTable;
      
      selectClause += ''',
             ${queenTable.select},
             ${queenBreedTable.select}''';
      
      fromClause += '''
      LEFT JOIN ${queenTable.tableName}
        ON ${hiveTable.xQueenId} = ${queenTable.xId}
      LEFT JOIN ${queenBreedTable.tableName}
        ON ${queenTable.xBreedId} = ${queenBreedTable.xId}''';
    }
    
    final query = '''
      $selectClause
      $fromClause
      WHERE ${hiveTable.xIsDeleted} = 0
      ORDER BY ${hiveTable.xPosition} ASC
    ''';
    
    final results = await db.rawQuery(query);
    
    return results.map((map) {
      final hive = HiveDto.fromMap(map, prefix: '${hiveTable.alias}_');
      final hiveType = HiveTypeDto.fromMap(map, prefix: '${hiveTypeTable.alias}_').toModel();
      
      // Start with basic hive model with hive type
      Hive hiveModel = hive.toModel(
        hiveType: hiveType,
        apiary: null,
        queen: null,
      );
      
      // Add apiary if requested
      if (includeApiary && map[_databaseHelper.apiaryTable.xId] != null) {
        final apiaryTable = _databaseHelper.apiaryTable;
        final apiaryData = ApiaryDto.fromMap(map, prefix: '${apiaryTable.alias}_');
        hiveModel = hiveModel.copyWith(apiary: () => apiaryData.toModel());
      }
      
      // Add queen if requested
      if (includeQueen && map[_databaseHelper.queenTable.xId] != null) {
        final queenTable = _databaseHelper.queenTable;
        final queenBreedTable = _databaseHelper.queenBreedTable;
        
        final queen = QueenDto.fromMap(map, prefix: '${queenTable.alias}_')
          .toModel(breed: QueenBreedDto.fromMap(map, prefix: '${queenBreedTable.alias}_').toModel());
        
        hiveModel = hiveModel.copyWith(queen: () => queen);
      }
      
      return hiveModel;
    }).toList();
  }

  /// Gets a hive by ID with customizable related data.
  /// 
  /// Parameters:
  /// - [id]: The ID of the hive to retrieve
  /// - [includeApiary]: Whether to include apiary information
  /// - [includeQueen]: Whether to include queen and breed information
  Future<Hive?> getHiveById(
    String id, {
    bool includeApiary = false,
    bool includeQueen = false,
  }) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    
    // Build SELECT clause
    String selectClause = '''
      SELECT ${hiveTable.select},
             ${hiveTypeTable.select}''';
    
    // Tables to join
    String fromClause = '''
      FROM ${hiveTable.tableName}
      JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}''';
    
    // Add apiary if needed
    if (includeApiary) {
      final apiaryTable = _databaseHelper.apiaryTable;
      selectClause += ''',
             ${apiaryTable.select}''';
      
      fromClause += '''
      LEFT JOIN ${apiaryTable.tableName}
        ON ${hiveTable.xApiaryId} = ${apiaryTable.xId}''';
    }
    
    // Add queen if needed
    if (includeQueen) {
      final queenTable = _databaseHelper.queenTable;
      final queenBreedTable = _databaseHelper.queenBreedTable;
      
      selectClause += ''',
             ${queenTable.select},
             ${queenBreedTable.select}''';
      
      fromClause += '''
      LEFT JOIN ${queenTable.tableName}
        ON ${hiveTable.xQueenId} = ${queenTable.xId}
      LEFT JOIN ${queenBreedTable.tableName}
        ON ${queenTable.xBreedId} = ${queenBreedTable.xId}''';
    }
    
    final query = '''
      $selectClause
      $fromClause
      WHERE ${hiveTable.xId} = ? AND ${hiveTable.xIsDeleted} = 0
    ''';
    
    final results = await db.rawQuery(query, [id]);
    
    if (results.isEmpty) {
      return null;
    }
    
    final map = results.first;
    final hive = HiveDto.fromMap(map, prefix: '${hiveTable.alias}_');
    final hiveType = HiveTypeDto.fromMap(map, prefix: '${hiveTypeTable.alias}_').toModel();
    
    // Start with basic hive model with hive type
    Hive hiveModel = hive.toModel(
      hiveType: hiveType,
      apiary: null,
      queen: null,
    );
    
    // Add apiary if requested
    if (includeApiary && map['${_databaseHelper.apiaryTable.alias}_id'] != null) {
      final apiaryTable = _databaseHelper.apiaryTable;
      final apiaryData = ApiaryDto.fromMap(map, prefix: '${apiaryTable.alias}_');
      hiveModel = hiveModel.copyWith(apiary: () => apiaryData.toModel());
    }
    
    // Add queen if requested
    if (includeQueen && map['${_databaseHelper.queenTable.alias}_id'] != null) {
      final queenTable = _databaseHelper.queenTable;
      final queenBreedTable = _databaseHelper.queenBreedTable;
      
      final queen = QueenDto.fromMap(map, prefix: '${queenTable.alias}_')
        .toModel(breed: QueenBreedDto.fromMap(map, prefix: '${queenBreedTable.alias}_').toModel());
      
      hiveModel = hiveModel.copyWith(queen: () => queen);
    }
    
    return hiveModel;
  }

  /// Inserts a new hive into the database.
  ///
  /// If the hive doesn't have an ID, one will be generated.
  /// The position will be set to the maximum current position + 1 if not specified.
  /// Returns the inserted hive with its ID.
  Future<Hive> insertHive(Hive hive) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    final hiveId = hive.id.isEmpty ? _uuid.v4() : hive.id;
    
    // If position is 0, calculate the maximum position + 1
    int position = hive.position;
    if (position == 0) {
      final positionResult = await db.rawQuery(
        'SELECT MAX(${hiveTable.position}) as max_position FROM ${hiveTable.tableName} WHERE ${hiveTable.isDeleted} = 0'
      );
      
      if (positionResult.isNotEmpty && positionResult.first['max_position'] != null) {
        position = (positionResult.first['max_position'] as int) + 1;
      } else {
        position = 1; // First hive
      }
    }

    HiveDto dto = HiveDto.fromModel(
      hive.copyWith(
        id: () => hiveId,
        position: () => position,
      ),
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await db.insert(hiveTable.tableName, dto.toMap());

    return hive.copyWith(
      id: () => hiveId,
      position: () => position,
    );
  }

  /// Updates an existing hive in the database.
  ///
  /// The hive must have a valid ID.
  /// Returns the updated hive.
  Future<Hive> updateHive(Hive hive) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    
    if (hive.id.isEmpty) {
      throw ArgumentError('Cannot update a hive without an ID');
    }
    
    HiveDto dto = HiveDto.fromModel(
      hive,
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    
    await db.update(
      hiveTable.tableName,
      dto.toMap(),
      where: '${hiveTable.id} = ?',
      whereArgs: [hive.id],
    );
    
    return hive;
  }

  /// Updates multiple hives in a single batch operation.
  ///
  /// This is more efficient than updating each hive individually.
  /// All hives must have valid IDs.
  /// Returns the list of updated hives.
  Future<List<Hive>> updateHivesBatch(List<Hive> hives) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    
    // Verify all hives have IDs
    if (hives.any((hive) => hive.id.isEmpty)) {
      throw ArgumentError('Cannot update hives without IDs');
    }
    
    // Use a batch for more efficient updates
    final batch = db.batch();
    final now = DateTime.now();
    
    for (final hive in hives) {
      final dto = HiveDto.fromModel(
        hive,
        isDeleted: false,
        isSynced: false,
        updatedAt: now,
      );
      
      batch.update(
        hiveTable.tableName,
        dto.toMap(),
        where: '${hiveTable.id} = ?',
        whereArgs: [hive.id],
      );
    }
    
    // Execute all updates in a single batch operation
    await batch.commit(noResult: true);
    
    return hives;
  }

  /// Retrieves all hives by a specific apiary ID with customizable related data.
  /// 
  /// Parameters:
  /// - [apiaryId]: The ID of the apiary to filter hives by.
  /// - [includeQueen]: Whether to include queen and breed information.
  Future<List<Hive>> getByApiaryId(
    String apiaryId, {
    bool includeQueen = false,
  }) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;

    final queenTable = _databaseHelper.queenTable;
    final queenBreedTable = _databaseHelper.queenBreedTable;
    
    // Build SELECT clause
    String selectClause = '''
      SELECT ${hiveTable.select},
            ${hiveTypeTable.select}''';

    // Tables to join
    String fromClause = '''
      FROM ${hiveTable.tableName}
      JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}''';

    // Add queen if needed
    if (includeQueen) {
      selectClause += ''',
            ${queenTable.select},
            ${queenBreedTable.select}''';

      fromClause += '''
      LEFT JOIN ${queenTable.tableName}
        ON ${hiveTable.xQueenId} = ${queenTable.xId}
      LEFT JOIN ${queenBreedTable.tableName}
        ON ${queenTable.xBreedId} = ${queenBreedTable.xId}''';
    }

    final query = '''
      $selectClause
      $fromClause
      WHERE ${hiveTable.xApiaryId} = ? AND ${hiveTable.xIsDeleted} = 0
      ORDER BY ${hiveTable.xPosition} ASC
    ''';

    final results = await db.rawQuery(query, [apiaryId]);

    return results.map((map) {
      final hive = HiveDto.fromMap(map, prefix: '${hiveTable.alias}_');
      final hiveType = HiveTypeDto.fromMap(map, prefix: '${hiveTypeTable.alias}_').toModel();

      // Start with basic hive model with hive type
      Hive hiveModel = hive.toModel(
        hiveType: hiveType,
        apiary: null,
        queen: null,
      );


      // Add queen if requested
      if (includeQueen && map['${queenTable.alias}_id'] != null) {

        final queen = QueenDto.fromMap(map, prefix: '${queenTable.alias}_')
          .toModel(breed: QueenBreedDto.fromMap(map, prefix: '${queenBreedTable.alias}_').toModel());

        hiveModel = hiveModel.copyWith(queen: () => queen);
      }

      return hiveModel;
    }).toList();
  }

  /// Creates a new hive with most recent values.
  /// 
  /// Parameters:
  /// - [apiaryId]: Optional ID of the apiary to associate with the hive
  /// - [queenId]: Optional ID of the queen to associate with the hive
  /// - [name]: Optional name for the hive (defaults to "New Hive")
  /// - [status]: Optional status for the new hive (defaults to active)
  /// - [color]: Optional color for the new hive
  /// - [hiveTypeId]: Optional hive type ID (otherwise uses the most recent hive's type)
  /// - [imageUrl]: Optional image URL
  /// - [currentFrameCount]: Optional frame count
  /// - [currentBroodFrameCount]: Optional brood frame count
  /// - [currentBroodBoxCount]: Optional brood box count
  /// - [currentHoneySuperBoxCount]: Optional honey super box count
  /// - [acquisitionDate]: Optional acquisition date (defaults to current date)
  /// 
  /// Returns the created hive with its ID.
  Future<Hive> createDefaultHive({
    String? apiaryId,
    String? queenId,
    String name = 'New Hive',
    HiveStatus? status,
    Color? color,
    String? hiveTypeId,
    String? imageUrl,
    int? currentFrameCount,
    int? currentBroodFrameCount,
    int? currentBroodBoxCount,
    int? currentHoneySuperBoxCount,
    DateTime? acquisitionDate,
  }) async {
    final db = await _databaseHelper.database;
    final hiveId = _uuid.v4();
    
    final hiveTable = _databaseHelper.hiveTable;
    // Get a default hive type if none provided
    final hiveResult = await db.query(
      hiveTable.tableName,
      where: '${hiveTable.isDeleted} = 0',
      orderBy: '${hiveTable.updatedAt} DESC',
      limit: 1,
    );
    
    if(hiveResult.isEmpty) {
      throw Exception('Failed to copy recent hive: no hives found');
    }
    final lastHiveDto = HiveDto.fromMap(hiveResult.first);
    
    // Get the current highest position to place this hive at the top
    int position = 0;
    final positionResult = await db.rawQuery(
      'SELECT MAX(${hiveTable.position}) as max_position FROM ${hiveTable.tableName} WHERE ${hiveTable.isDeleted} = 0'
    );
    
    if (positionResult.isNotEmpty && positionResult.first['max_position'] != null) {
      position = (positionResult.first['max_position'] as int) + 1;
    }
    
    // Create the hive with default values
    final hive = HiveDto(
      id: hiveId,
      name: name,
      queenId: queenId,
      hiveTypeId: hiveTypeId ?? lastHiveDto.hiveTypeId,
      apiaryId: apiaryId,
      status: status ?? HiveStatus.active,
      acquisitionDate: acquisitionDate ?? DateTime.now(),
      imageUrl: imageUrl ?? lastHiveDto.imageUrl,
      hexColor: color?.toHex() ?? lastHiveDto.hexColor,
      position: position,
      currentFrameCount: currentFrameCount ?? lastHiveDto.currentFrameCount,
      currentBroodFrameCount: currentBroodFrameCount ?? lastHiveDto.currentBroodFrameCount,
      currentBroodBoxCount: currentBroodBoxCount ?? lastHiveDto.currentBroodBoxCount,
      currentHoneySuperBoxCount: currentHoneySuperBoxCount ?? lastHiveDto.currentHoneySuperBoxCount,
      updatedAt: DateTime.now(),
      isDeleted: false,
      isSynced: false,
    );
    
    await db.insert(hiveTable.tableName, hive.toMap());
    Hive? hiveModel;
    if(apiaryId != null && queenId != null) {
      hiveModel = await getHiveById(hiveId, includeApiary: true, includeQueen: true);
    } else if(apiaryId != null) {
      hiveModel = await getHiveById(hiveId, includeApiary: true);
    } else if (queenId != null) {
      hiveModel = await getHiveById(hiveId, includeQueen: true);
    } else {
      hiveModel = await getHiveById(hiveId);
    }
    if(hiveModel != null) {
      return hiveModel;
    } else {
      throw Exception('Failed to create hive');
    }
  }

  /// Retrieves all hives that don't belong to any apiary.
  /// 
  /// Parameters:
  /// - [includeQueen]: Whether to include queen and breed information.
  Future<List<Hive>> getHivesWithoutApiary({
    bool includeQueen = false,
  }) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    
    // Build SELECT clause
    String selectClause = '''
      SELECT ${hiveTable.select},
             ${hiveTypeTable.select}''';
    
    // Tables to join
    String fromClause = '''
      FROM ${hiveTable.tableName}
      JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}''';
    
    // Add queen if needed
    if (includeQueen) {
      final queenTable = _databaseHelper.queenTable;
      final queenBreedTable = _databaseHelper.queenBreedTable;
      
      selectClause += ''',
             ${queenTable.select},
             ${queenBreedTable.select}''';
      
      fromClause += '''
      LEFT JOIN ${queenTable.tableName}
        ON ${hiveTable.xQueenId} = ${queenTable.xId}
      LEFT JOIN ${queenBreedTable.tableName}
        ON ${queenTable.xBreedId} = ${queenBreedTable.xId}''';
    }
    
    final query = '''
      $selectClause
      $fromClause
      WHERE ${hiveTable.xApiaryId} IS NULL AND ${hiveTable.xIsDeleted} = 0
      ORDER BY ${hiveTable.xPosition} DESC
    ''';
    
    final results = await db.rawQuery(query);
    
    return results.map((map) {
      final hive = HiveDto.fromMap(map, prefix: '${hiveTable.alias}_');
      final hiveType = HiveTypeDto.fromMap(map, prefix: '${hiveTypeTable.alias}_').toModel();
      
      // Start with basic hive model with hive type
      Hive hiveModel = hive.toModel(
        hiveType: hiveType,
        apiary: null,
        queen: null,
      );
      
      // Add queen if requested
      if (includeQueen && map['${_databaseHelper.queenTable.alias}_id'] != null) {
        final queenTable = _databaseHelper.queenTable;
        final queenBreedTable = _databaseHelper.queenBreedTable;
        
        final queen = QueenDto.fromMap(map, prefix: '${queenTable.alias}_')
          .toModel(breed: QueenBreedDto.fromMap(map, prefix: '${queenBreedTable.alias}_').toModel());
        
        hiveModel = hiveModel.copyWith(queen: () => queen);
      }
      
      return hiveModel;
    }).toList();
  }

  /// Soft-deletes a hive by marking it as deleted in the database.
  /// 
  /// The hive will no longer be returned by regular queries but can be recovered
  /// if needed by directly querying with isDeleted=1. All relationships (queen, apiary)
  /// are also cleared during deletion.
  /// 
  /// Parameters:
  /// - [hiveId]: The ID of the hive to delete
  /// 
  /// Returns true if the delete was successful, false otherwise.
  Future<bool> deleteHive(String hiveId) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    
    // Use soft delete by setting the isDeleted flag to true
    // and clearing relationships to queen and apiary
    final updateCount = await db.update(
      hiveTable.tableName,
      {
        hiveTable.isDeleted: 1,  // Mark as deleted
        hiveTable.queenId: null, // Clear queen relationship
        hiveTable.apiaryId: null, // Clear apiary relationship
        hiveTable.updatedAt: DateTime.now().toIso8601String(),  // Update timestamp
        hiveTable.isSynced: 0,  // Mark as needing sync
      },
      where: '${hiveTable.id} = ?',
      whereArgs: [hiveId],
    );
    
    // Return true if exactly one row was updated
    return updateCount == 1;
  }

  /// Checks if there are hives in the database that can be used as templates
  /// for creating default hives.
  /// 
  /// Returns true if at least one non-deleted hive exists, false otherwise.
  Future<bool> canCreateDefaultHive() async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    
    final result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM ${hiveTable.tableName} WHERE ${hiveTable.isDeleted} = 0) as exists_hive'
    );
    
    return (result.isNotEmpty && result.first['exists_hive'] == 1);
  }
}
