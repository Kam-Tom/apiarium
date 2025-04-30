import 'package:apiarium/shared/shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing apiaries in the database
class ApiaryRepository {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  ApiaryRepository({DatabaseHelper? databaseHelper})
      : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Retrieves all apiaries from the database
  Future<List<Apiary>> getAllApiaries() async {
    final db = await _databaseHelper.database;
    final apiaryTable = _databaseHelper.apiaryTable;
    final hiveTable = _databaseHelper.hiveTable;

    final query = '''
      SELECT a.*, 
        (SELECT COUNT(*) 
         FROM ${hiveTable.tableName} h 
         WHERE h.${hiveTable.apiaryId} = a.${apiaryTable.id} 
         AND h.${hiveTable.isDeleted} = 0) as hive_count
      FROM ${apiaryTable.tableName} a
      WHERE a.${apiaryTable.isDeleted} = 0
      ORDER BY a.${apiaryTable.position} ASC, a.${apiaryTable.createdAt} DESC
    ''';

    final results = await db.rawQuery(query);

    return results.map((map) {
      final dto = ApiaryDto.fromMap(map);
      return dto.toModel().copyWith(
        hiveCount: () => map['hive_count'] as int? ?? 0,
      );
    }).toList();
  }

  /// Retrieves all apiaries from the database with their hives
  Future<List<Apiary>> getAllApiariesWithHives({bool includeQueen = false}) async {
    final apiaries = await getAllApiaries();
    
    // Load hives for each apiary
    final List<Apiary> apiariesWithHives = [];
    for (final apiary in apiaries) {
      final hives = await getHivesByApiaryId(apiary.id, includeQueen: includeQueen);
      apiariesWithHives.add(apiary.copyWith(hives: () => hives));
    }
    
    return apiariesWithHives;
  }
  
  /// Unified method to get all apiaries with optional hive inclusion
  ///
  /// If [includeHives] is true, hives will be loaded for each apiary
  /// If [includeQueen] is true, queen information will be loaded for each hive
  Future<List<Apiary>> getApiaries({
    bool includeHives = false,
    bool includeQueen = false
  }) async {
    if (includeHives) {
      return getAllApiariesWithHives(includeQueen: includeQueen);
    } else {
      return getAllApiaries();
    }
  }

  /// Retrieves a specific apiary by ID with its current hive count
  Future<Apiary?> getApiaryById(String id) async {
    final db = await _databaseHelper.database;
    final apiaryTable = _databaseHelper.apiaryTable;
    final hiveTable = _databaseHelper.hiveTable;

    final query = '''
      SELECT a.*, 
        (SELECT COUNT(*) 
         FROM ${hiveTable.tableName} h 
         WHERE h.${hiveTable.apiaryId} = a.${apiaryTable.id} 
         AND h.${hiveTable.isDeleted} = 0) as hive_count
      FROM ${apiaryTable.tableName} a
      WHERE a.${apiaryTable.id} = ?
      AND a.${apiaryTable.isDeleted} = 0
    ''';

    final results = await db.rawQuery(query, [id]);

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;
    final dto = ApiaryDto.fromMap(map);
    return dto.toModel().copyWith(
      hiveCount: () => map['hive_count'] as int? ?? 0,
    );
  }

  /// Retrieves a specific apiary by ID with its hives
  Future<Apiary?> getApiaryWithHives(String id, {bool includeQueen = false}) async {
    final apiary = await getApiaryById(id);
    if (apiary == null) return null;
    
    final hives = await getHivesByApiaryId(id, includeQueen: includeQueen);
    return apiary.copyWith(
      hives: () => hives,
    );
  }
  
  /// Unified method to get a specific apiary with optional hive inclusion
  ///
  /// If [includeHives] is true, hives will be loaded for the apiary
  /// If [includeQueen] is true, queen information will be loaded for each hive
  Future<Apiary?> getApiary(String id, {
    bool includeHives = false,
    bool includeQueen = false
  }) async {
    if (includeHives) {
      return getApiaryWithHives(id, includeQueen: includeQueen);
    } else {
      return getApiaryById(id);
    }
  }

  /// Retrieves all hives for a specific apiary
  Future<List<Hive>> getHivesByApiaryId(String apiaryId, {bool includeQueen = false}) async {
    final db = await _databaseHelper.database;
    final hiveTable = _databaseHelper.hiveTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    
    // Build SELECT clause
    String selectClause = '''
      SELECT h.* 
      FROM ${hiveTable.tableName} h
      WHERE h.${hiveTable.apiaryId} = ?
      AND h.${hiveTable.isDeleted} = 0
      ORDER BY h.${hiveTable.position} ASC
    ''';
    
    final results = await db.rawQuery(selectClause, [apiaryId]);
    
    // We'll need to fetch the hive type for each hive
    List<Hive> hives = [];
    for (final map in results) {
      final hiveDto = HiveDto.fromMap(map);
      
      // Get hive type
      final hiveTypeQuery = '''
        SELECT * FROM ${hiveTypeTable.tableName} 
        WHERE id = ? AND is_deleted = 0
      ''';
      final hiveTypeResults = await db.rawQuery(
        hiveTypeQuery, 
        [hiveDto.hiveTypeId]
      );
      
      if (hiveTypeResults.isNotEmpty) {
        final hiveTypeDto = HiveTypeDto.fromMap(hiveTypeResults.first);
        final hiveType = hiveTypeDto.toModel();
        
        Queen? queen = null;
        // If includeQueen is true, get queen data
        if (includeQueen && hiveDto.queenId != null) {
          final queenTable = _databaseHelper.queenTable;
          final queenBreedTable = _databaseHelper.queenBreedTable;
          
          final queenQuery = '''
            SELECT q.*, b.*
            FROM ${queenTable.tableName} q
            LEFT JOIN ${queenBreedTable.tableName} b ON q.${queenTable.breedId} = b.id
            WHERE q.id = ? AND q.is_deleted = 0
          ''';
          
          final queenResults = await db.rawQuery(queenQuery, [hiveDto.queenId]);
          
          if (queenResults.isNotEmpty) {
            final queenMap = queenResults.first;
            final queenDto = QueenDto.fromMap(queenMap);
            final queenBreedDto = QueenBreedDto.fromMap(queenMap);
            queen = queenDto.toModel(breed: queenBreedDto.toModel());
          }
        }
        
        // Create the hive model
        hives.add(hiveDto.toModel(
          hiveType: hiveType,
          apiary: null,
          queen: queen,
        ));
      }
    }
    
    return hives;
  }

  /// Inserts a new apiary into the database.
  /// 
  /// If the apiary doesn't have an ID, one will be generated.
  /// If position is 0, it will be set to max position + 1.
  /// Returns the inserted apiary with its ID.
  Future<Apiary> insertApiary(Apiary apiary) async {
    final db = await _databaseHelper.database;
    final apiaryTable = _databaseHelper.apiaryTable;

    final apiaryId = apiary.id.isEmpty ? _uuid.v4() : apiary.id;
    
    // If position is 0, calculate the maximum position + 1
    int position = apiary.position;
    if (position == 0) {
      final positionResult = await db.rawQuery(
        'SELECT MAX(${apiaryTable.position}) as max_position FROM ${apiaryTable.tableName} WHERE ${apiaryTable.isDeleted} = 0'
      );
      
      if (positionResult.isNotEmpty && positionResult.first['max_position'] != null) {
        position = (positionResult.first['max_position'] as int) + 1;
      } else {
        position = 1; // First apiary
      }
    }

    ApiaryDto dto = ApiaryDto.fromModel(
      apiary.copyWith(
        id: () => apiaryId,
        position: () => position,
      ),
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await db.insert(
      apiaryTable.tableName,
      dto.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return apiary.copyWith(
      id: () => apiaryId,
      position: () => position,
    );
  }

  /// Updates an existing apiary in the database.
  /// 
  /// The apiary must have a valid ID.
  /// Returns the updated apiary.
  Future<Apiary> updateApiary(Apiary apiary) async {
    final db = await _databaseHelper.database;
    final apiaryTable = _databaseHelper.apiaryTable;

    if (apiary.id.isEmpty) {
      throw Exception('Cannot update apiary without an ID');
    }

    ApiaryDto dto = ApiaryDto.fromModel(
      apiary,
      isDeleted: false,
      isSynced: false,
      updatedAt: DateTime.now(),
    );

    await db.update(
      apiaryTable.tableName,
      dto.toMap(),
      where: '${apiaryTable.id} = ?',
      whereArgs: [apiary.id],
    );

    return apiary;
  }

  /// Updates multiple apiaries in a single batch operation.
  ///
  /// This is more efficient than updating each apiary individually.
  /// All apiaries must have valid IDs.
  /// Returns the list of updated apiaries.
  Future<List<Apiary>> updateApiariesBatch(List<Apiary> apiaries) async {
    final db = await _databaseHelper.database;
    final apiaryTable = _databaseHelper.apiaryTable;
    
    // Verify all apiaries have IDs
    if (apiaries.any((apiary) => apiary.id.isEmpty)) {
      throw ArgumentError('Cannot update apiaries without IDs');
    }
    
    // Use a batch for more efficient updates
    final batch = db.batch();
    final now = DateTime.now();
    
    for (final apiary in apiaries) {
      final dto = ApiaryDto.fromModel(
        apiary,
        isDeleted: false,
        isSynced: false,
        updatedAt: now,
      );
      
      batch.update(
        apiaryTable.tableName,
        dto.toMap(),
        where: '${apiaryTable.id} = ?',
        whereArgs: [apiary.id],
      );
    }
    
    // Execute all updates in a single batch operation
    await batch.commit(noResult: true);
    
    return apiaries;
  }

  /// Soft-deletes an apiary by marking it as deleted in the database.
  /// 
  /// The apiary will no longer be returned by regular queries but can be recovered
  /// if needed by directly querying with isDeleted=1. All hives associated with
  /// this apiary will have their apiary relationship cleared.
  /// 
  /// Parameters:
  /// - [apiaryId]: The ID of the apiary to delete
  /// 
  /// Returns true if the delete was successful, false otherwise.
  Future<bool> deleteApiary(String apiaryId) async {
    final db = await _databaseHelper.database;
    final apiaryTable = _databaseHelper.apiaryTable;
    final hiveTable = _databaseHelper.hiveTable;
    
    // Start a transaction to ensure both operations complete
    return await db.transaction((txn) async {
      //Update all hives to remove the apiary reference
      await txn.update(
        hiveTable.tableName,
        {
          hiveTable.apiaryId: null,
          hiveTable.updatedAt: DateTime.now().toIso8601String(),
          hiveTable.isSynced: 0,
        },
        where: '${hiveTable.apiaryId} = ? AND ${hiveTable.isDeleted} = 0',
        whereArgs: [apiaryId],
      );
      
      // Handle 
      final updateCount = await txn.update(
        apiaryTable.tableName,
        {
          apiaryTable.isDeleted: 1,
          apiaryTable.updatedAt: DateTime.now().toIso8601String(), 
          apiaryTable.isSynced: 0,  
        },
        where: '${apiaryTable.id} = ?',
        whereArgs: [apiaryId],
      );
      return updateCount == 1;
    });
  }
}
