import 'package:apiarium/shared/shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

/// Repository for managing queen bee data in the local database
/// with future support for remote synchronization.
class QueenRepository {
  final DatabaseHelper _databaseHelper;
  final Uuid _uuid = const Uuid();

  QueenRepository({DatabaseHelper? databaseHelper}) 
      : _databaseHelper = databaseHelper ?? DatabaseHelper();
  
  /// Retrieves all queens from the database with customizable related data.
  /// 
  /// Parameters:
  /// - [includeApiary]: Whether to include apiary information
  /// - [includeHive]: Whether to include hive and hive type information
  Future<List<Queen>> getAllQueens({
    bool includeApiary = false,
    bool includeHive = false,
  }) async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    final breedTable = _databaseHelper.queenBreedTable;
    final apiaryTable = _databaseHelper.apiaryTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    final hiveTable = _databaseHelper.hiveTable;

    // Build SELECT clause
    String selectClause = '''
      SELECT ${queenTable.select}, 
             ${breedTable.select}''';
    
    // Tables to join
    String fromClause = '''
      FROM ${queenTable.tableName}
      JOIN ${breedTable.tableName}
        ON ${queenTable.xBreedId} = ${breedTable.xId}''';
    
    // Add hive join if needed by either apiary or hive
    if (includeApiary && !includeHive) {
      fromClause += '''
      LEFT JOIN ${hiveTable.tableName}
        ON ${queenTable.xId} = ${hiveTable.alias}.${hiveTable.queenId}
      LEFT JOIN ${apiaryTable.tableName}
        ON ${hiveTable.alias}.${hiveTable.apiaryId} = ${apiaryTable.xId}''';  

      selectClause += ''',
             ${apiaryTable.select}''';
    }
    else if(includeApiary && includeHive) {
      fromClause += '''
      LEFT JOIN ${hiveTable.tableName}
        ON ${queenTable.xId} = ${hiveTable.xQueenId}
      LEFT JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}
      LEFT JOIN ${apiaryTable.tableName}
        ON ${hiveTable.xApiaryId} = ${apiaryTable.xId}''';
        
      selectClause += ''',
             ${apiaryTable.select},
             ${hiveTable.select},
             ${hiveTypeTable.select}''';
    }
    else if(includeHive) {
      fromClause += '''
      LEFT JOIN ${hiveTable.tableName}
        ON ${queenTable.xId} = ${hiveTable.xQueenId}
      LEFT JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}''';
        
      selectClause += ''',
             ${hiveTable.select},
             ${hiveTypeTable.select}''';
    }
    
    // Complete the query
    final query = '''
      $selectClause
      $fromClause
      WHERE ${queenTable.xIsDeleted} = 0
      ORDER BY ${queenTable.xUpdatedAt} DESC
    ''';

    final List<Map<String, dynamic>> results = await db.rawQuery(query);
    
    return results.map((result) {
      final queenDto = QueenDto.fromMap(result, prefix: '${queenTable.alias}_');
      final breedData = QueenBreedDto.fromMap(result, prefix: '${breedTable.alias}_');
      
      // Start with the basic queen model with breed
      Queen queen = queenDto.toModel(breed: breedData.toModel());
      
      // Add apiary if requested
      if (includeApiary && result['${apiaryTable.alias}_${apiaryTable.id}'] != null) {
        final apiaryTable = _databaseHelper.apiaryTable;
        final apiaryData = ApiaryDto.fromMap(result, prefix: '${apiaryTable.alias}_');
        queen = queen.copyWith(apiary: () => apiaryData.toModel());
      }
      
      // Add hive if requested
      if (includeHive && result['${hiveTable.alias}_${hiveTable.id}'] != null) {
        final hiveTypeTable = _databaseHelper.hiveTypeTable;
        final hiveTable = _databaseHelper.hiveTable;
        final hiveTypeData = HiveTypeDto.fromMap(result, prefix: '${hiveTypeTable.alias}_');
        final hiveData = HiveDto.fromMap(result, prefix: '${hiveTable.alias}_');
        queen = queen.copyWith(hive: () => hiveData.toModel(hiveType: hiveTypeData.toModel()));
      }
      
      return queen;
    }).toList();
  }
  
  /// Retrieves a specific queen by ID with customizable related data.
  /// 
  /// Parameters:
  /// - [id]: The ID of the queen to retrieve
  /// - [includeApiary]: Whether to include apiary information
  /// - [includeHive]: Whether to include hive and hive type information
  Future<Queen?> getQueenById(
    String id, {
    bool includeApiary = false,
    bool includeHive = false,
  }) async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    final breedTable = _databaseHelper.queenBreedTable;
    final apiaryTable = _databaseHelper.apiaryTable;
    final hiveTypeTable = _databaseHelper.hiveTypeTable;
    final hiveTable = _databaseHelper.hiveTable;
    
    // Build SELECT clause
    String selectClause = '''
      SELECT ${queenTable.select}, 
             ${breedTable.select}''';
    
    // Tables to join
    String fromClause = '''
      FROM ${queenTable.tableName}
      JOIN ${breedTable.tableName}
        ON ${queenTable.xBreedId} = ${breedTable.xId}''';
    
    // Add hive join if needed by either apiary or hive
    if (includeApiary || includeHive) {
      fromClause += '''
      LEFT JOIN ${hiveTable.tableName}
        ON ${queenTable.xId} = ${hiveTable.xQueenId}''';
      
      selectClause += ''',
        ${hiveTable.select}''';

      // Add apiary if needed
      if (includeApiary) {
        selectClause += ''',
             ${apiaryTable.select}''';
        
        fromClause += '''
      LEFT JOIN ${apiaryTable.tableName}
        ON ${hiveTable.xApiaryId} = ${apiaryTable.xId}''';
      }
      
      // Add hive type if needed
      if (includeHive) {
        selectClause += ''',
             ${hiveTypeTable.select}''';
        fromClause += '''
      LEFT JOIN ${hiveTypeTable.tableName}
        ON ${hiveTable.xHiveTypeId} = ${hiveTypeTable.xId}''';
      }
    }
    
    // Complete the query with WHERE clause
    final query = '''
      $selectClause
      $fromClause
      WHERE ${queenTable.xId} = ?
      AND ${queenTable.xIsDeleted} = 0
      ORDER BY ${queenTable.xBirthDate} DESC
    ''';

    final results = await db.rawQuery(query, [id]);
    
    if (results.isEmpty) {
      return null;
    }
    
    final result = results.first;
    final queenDto = QueenDto.fromMap(result, prefix: '${queenTable.alias}_');
    final breedData = QueenBreedDto.fromMap(result, prefix: '${breedTable.alias}_');
    
    // Start with the basic queen model with breed
    Queen queen = queenDto.toModel(breed: breedData.toModel());
    
    // Add apiary if requested
    if (includeApiary && result['${apiaryTable.alias}_${apiaryTable.id}'] != null) {
      final apiaryData = ApiaryDto.fromMap(result, prefix: '${apiaryTable.alias}_');
      queen = queen.copyWith(apiary: () => apiaryData.toModel());
    }
    
    // Add hive if requested
    if (includeHive && result['${hiveTable.alias}_${hiveTable.id}'] != null) {
      final hiveTypeTable = _databaseHelper.hiveTypeTable;
      final hiveTable = _databaseHelper.hiveTable;
      final hiveTypeData = HiveTypeDto.fromMap(result, prefix: '${hiveTypeTable.alias}_');
      final hiveData = HiveDto.fromMap(result, prefix: '${hiveTable.alias}_');
      queen = queen.copyWith(hive: () => hiveData.toModel(hiveType: hiveTypeData.toModel()));
    }
    
    return queen;
  }
  
/// Inserts a new queen into the database.
/// 
/// If the queen doesn't have an ID, one will be generated.
/// Returns the inserted queen with its ID.
Future<Queen> insertQueen(Queen queen) async {
  final db = await _databaseHelper.database;
  final queenTable = _databaseHelper.queenTable;
  
  final queenId = queen.id.isEmpty ? _uuid.v4() : queen.id;
  
  final queenDto = QueenDto.fromModel(
    queen.copyWith(id: () => queenId),
    isDeleted: false,
    isSynced: false,
    updatedAt: DateTime.now(),
  );
  
  await db.insert(
    queenTable.tableName,
    queenDto.toMap(),
  );
  
  return queen.copyWith(id: () => queenId);
}

/// Updates an existing queen in the database.
/// 
/// The queen must have a valid ID.
/// Returns the updated queen.
Future<Queen> updateQueen(Queen queen) async {
  final db = await _databaseHelper.database;
  final queenTable = _databaseHelper.queenTable;
  
  if (queen.id.isEmpty) {
    throw ArgumentError('Cannot update a queen without an ID');
  }
  
  final queenDto = QueenDto.fromModel(
    queen,
    isDeleted: false,
    isSynced: false,
    updatedAt: DateTime.now(),
  );
  
  await db.update(
    queenTable.tableName,
    queenDto.toMap(),
    where: '${queenTable.id} = ?',
    whereArgs: [queen.id],
  );
  
  return queen;
}
  
  /// Deletes a queen by ID (soft delete).
  /// 
  /// Returns true if the queen was successfully deleted.
  Future<bool> deleteQueen(String id) async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    final hiveTable = _databaseHelper.hiveTable;
    
    final rowsAffected = await db.update(
      queenTable.tableName,
      {
        'is_deleted': 1,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    // Unassign queen from any hive
    await db.update(
      hiveTable.tableName,
      {
        'queen_id': null,
        'is_synced': 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'queen_id = ?',
      whereArgs: [id],
    );
    
    return rowsAffected > 0;
  }
  
  /// Returns the total count of non-deleted queens in the database.
  Future<int> getQueensCount() async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${queenTable.tableName} WHERE ${queenTable.isDeleted} = 0'
    );
    
    return Sqflite.firstIntValue(result) ?? 0;
  }
  
  /// Returns the count of queens filtered by apiary.
  /// 
  /// Parameters:
  /// - [apiaryId]: Optional apiary ID to filter by
  ///   - If provided, returns count of queens in that apiary
  ///   - If null, returns count of queens not assigned to any hive
  Future<int> getQueensCountByApiary(String? apiaryId) async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    final hiveTable = _databaseHelper.hiveTable;
    
    if (apiaryId != null) {
      // Count queens in a specific apiary
      final query = '''
        SELECT COUNT(DISTINCT ${queenTable.xId}) as count 
        FROM ${queenTable.tableName} q
        JOIN ${hiveTable.tableName} h ON q.${queenTable.id} = h.${hiveTable.queenId}
        WHERE q.${queenTable.isDeleted} = 0 
        AND h.${hiveTable.apiaryId} = ?
      ''';
      final result = await db.rawQuery(query, [apiaryId]);
      return Sqflite.firstIntValue(result) ?? 0;
    } else {
      // Count queens not assigned to any hive (unassigned queens)
      final query = '''
        SELECT COUNT(*) as count 
        FROM ${queenTable.tableName} q
        WHERE NOT EXISTS (
          SELECT 1 
          FROM ${hiveTable.tableName} h
          WHERE h.${hiveTable.queenId} = q.${queenTable.id}
        )
        AND q.${queenTable.isDeleted} = 0
      ''';
      final result = await db.rawQuery(query);
      return Sqflite.firstIntValue(result) ?? 0;
    }
  }

  /// Retrieves all queens that are not assigned to any hive.
  /// 
  /// Returns a list of Queen objects with their breed information.
  Future<List<Queen>> getUnassignedQueens() async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    final breedTable = _databaseHelper.queenBreedTable;
    final hiveTable = _databaseHelper.hiveTable;
    
    final query = '''
      SELECT ${queenTable.select}, 
             ${breedTable.select},
             ${hiveTable.select}
      FROM ${queenTable.tableName}
      JOIN ${breedTable.tableName}
        ON ${queenTable.xBreedId} = ${breedTable.xId}
      LEFT JOIN ${hiveTable.tableName}
        ON ${queenTable.xId} = ${hiveTable.xQueenId}
      WHERE ${queenTable.xIsDeleted} = 0
      AND ${hiveTable.xId} IS NULL
      ORDER BY ${queenTable.xBirthDate} DESC
    ''';

    final List<Map<String, dynamic>> results = await db.rawQuery(query);
    
    return results.map((result) {
      final queenDto = QueenDto.fromMap(result, prefix: '${queenTable.alias}_');
      final breedData = QueenBreedDto.fromMap(result, prefix: '${breedTable.alias}_');
      
      // Return queen with breed information
      return queenDto.toModel(breed: breedData.toModel());
    }).toList();
  }
  
  /// Creates a new queen with default values based on the most recent queen.
  /// 
  /// If specific parameters are provided, those will be used instead of defaults.
  /// Otherwise, values from the most recent queen will be used as defaults.
  /// 
  /// Returns the created queen with its ID.
  Future<Queen> createDefaultQueen({
    String? breedId,
    String name = 'New Queen',
    DateTime? birthDate,
    QueenSource? source,
    bool? marked,
    String? markColorHex,
    QueenStatus? status,
    String? origin,
  }) async {
    final db = await _databaseHelper.database;
    final queenId = _uuid.v4();
    final queenTable = _databaseHelper.queenTable;
    
    // Get the most recent queen for default values
    final queensResult = await db.query(
      queenTable.tableName,
      where: '${queenTable.isDeleted} = 0',
      orderBy: '${queenTable.updatedAt} DESC',
      limit: 1,
    );
    if(queensResult.isEmpty) {
      throw Exception('Failed to copy recent queen: no queens found');
    }
    
    final lastQueenDto = QueenDto.fromMap(queensResult.first);
    
    // Create the queen with provided values or defaults from the most recent queen
    final queenDto = QueenDto(
      id: queenId,
      name: name,
      breedId: breedId ?? lastQueenDto.breedId,
      birthDate: birthDate ?? lastQueenDto.birthDate,
      marked: marked ?? lastQueenDto.marked,
      markColorHex: markColorHex ?? lastQueenDto.markColorHex,
      status: status ?? lastQueenDto.status,
      source: source ?? lastQueenDto.source,
      origin: origin ?? lastQueenDto.origin,
      updatedAt: DateTime.now(),
      isDeleted: false,
      isSynced: false,
    );
    
    await db.insert(queenTable.tableName, queenDto.toMap());
    
    // Return the newly created queen with breed information
    final newQueen = await getQueenById(queenId);
    if (newQueen != null) {
      return newQueen;
    } else {
      throw Exception('Failed to create queen');
    }
  }

  /// Checks if there are queens in the database that can be used as templates
  /// for creating default queens.
  /// 
  /// Returns true if at least one non-deleted queen exists, false otherwise.
  Future<bool> canCreateDefaultQueen() async {
    final db = await _databaseHelper.database;
    final queenTable = _databaseHelper.queenTable;
    
    final result = await db.rawQuery(
      'SELECT EXISTS(SELECT 1 FROM ${queenTable.tableName} WHERE ${queenTable.isDeleted} = 0) as exists_queen'
    );
    
    return (result.isNotEmpty && result.first['exists_queen'] == 1);
  }
}