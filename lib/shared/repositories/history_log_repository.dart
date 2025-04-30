import 'package:apiarium/shared/shared.dart';

/// Repository for managing history logs in the local database
/// with methods to retrieve logs filtered by entity type and ID.
class HistoryLogRepository {
  final DatabaseHelper _databaseHelper;

  HistoryLogRepository({DatabaseHelper? databaseHelper}) 
      : _databaseHelper = databaseHelper ?? DatabaseHelper();
  
  /// Retrieves all history logs from the database without grouping.
  Future<List<HistoryLog>> getAllHistoryLogs() async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.isDeleted} = 0',
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves history logs grouped by groupId, with individual logs without groupId included.
  /// This returns one log per group with a count of logs in that group, plus individual logs.
  Future<List<HistoryLog>> getGroupedHistoryLogs() async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    // Part 1: Get grouped logs
    final groupedQuery = '''
      WITH GroupedLogs AS (
        SELECT 
          ${historyLogTable.groupId},
          MAX(${historyLogTable.timestamp}) as latest_timestamp,
          COUNT(*) as log_count
        FROM ${historyLogTable.tableName}
        WHERE ${historyLogTable.groupId} IS NOT NULL 
          AND ${historyLogTable.isDeleted} = 0
        GROUP BY ${historyLogTable.groupId}
      )
      SELECT hl.*, gl.log_count
      FROM ${historyLogTable.tableName} hl
      JOIN GroupedLogs gl ON hl.${historyLogTable.groupId} = gl.${historyLogTable.groupId}
      WHERE hl.${historyLogTable.timestamp} = gl.latest_timestamp
        AND hl.${historyLogTable.isDeleted} = 0
    ''';
    
    final groupedResults = await db.rawQuery(groupedQuery);
    
    // Part 2: Get individual logs that don't have a groupId
    final nonGroupedResults = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.groupId} IS NULL AND ${historyLogTable.isDeleted} = 0',
    );
    
    // Process grouped logs
    List<HistoryLog> logs = groupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      final logModel = historyLogDto.toModel();
      
      // Add the log count
      return logModel.copyWith(
        logCount: () => result['log_count'] as int,
      );
    }).toList();
    
    // Process non-grouped logs
    logs.addAll(nonGroupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }));
    
    // Sort all logs by timestamp
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return logs;
  }
  
  /// Retrieves history logs for a specific entity type without grouping.
  Future<List<HistoryLog>> getHistoryLogsByEntityType(EntityType entityType) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.entityType} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [entityType.index],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves grouped history logs for a specific entity type,
  /// with individual logs without groupId included.
  Future<List<HistoryLog>> getGroupedHistoryLogsByEntityType(EntityType entityType) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    // Part 1: Get grouped logs for this entity type
    final groupedQuery = '''
      WITH GroupedLogs AS (
        SELECT 
          ${historyLogTable.groupId},
          MAX(${historyLogTable.timestamp}) as latest_timestamp,
          COUNT(*) as log_count
        FROM ${historyLogTable.tableName}
        WHERE ${historyLogTable.groupId} IS NOT NULL 
          AND ${historyLogTable.entityType} = ?
          AND ${historyLogTable.isDeleted} = 0
        GROUP BY ${historyLogTable.groupId}
      )
      SELECT hl.*, gl.log_count
      FROM ${historyLogTable.tableName} hl
      JOIN GroupedLogs gl ON hl.${historyLogTable.groupId} = gl.${historyLogTable.groupId}
      WHERE hl.${historyLogTable.timestamp} = gl.latest_timestamp
        AND hl.${historyLogTable.entityType} = ?
        AND hl.${historyLogTable.isDeleted} = 0
    ''';
    
    final groupedResults = await db.rawQuery(groupedQuery, [entityType.index, entityType.index]);
    
    // Part 2: Get individual logs for this entity type that don't have a groupId
    final nonGroupedResults = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.groupId} IS NULL AND ${historyLogTable.entityType} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [entityType.index],
    );
    
    // Process grouped logs
    List<HistoryLog> logs = groupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      final logModel = historyLogDto.toModel();
      
      // Add the log count
      return logModel.copyWith(
        logCount: () => result['log_count'] as int,
      );
    }).toList();
    
    // Process non-grouped logs
    logs.addAll(nonGroupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }));
    
    // Sort all logs by timestamp
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return logs;
  }
  
  /// Retrieves history logs for a specific entity ID without grouping.
  Future<List<HistoryLog>> getHistoryLogsByEntityId(String entityId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.entityId} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [entityId],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves grouped history logs for a specific entity ID,
  /// with individual logs without groupId included.
  Future<List<HistoryLog>> getGroupedHistoryLogsByEntityId(String entityId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    // Part 1: Get grouped logs for this entity ID
    final groupedQuery = '''
      WITH GroupedLogs AS (
        SELECT 
          ${historyLogTable.groupId},
          MAX(${historyLogTable.timestamp}) as latest_timestamp,
          COUNT(*) as log_count
        FROM ${historyLogTable.tableName}
        WHERE ${historyLogTable.groupId} IS NOT NULL 
          AND ${historyLogTable.entityId} = ?
          AND ${historyLogTable.isDeleted} = 0
        GROUP BY ${historyLogTable.groupId}
      )
      SELECT hl.*, gl.log_count
      FROM ${historyLogTable.tableName} hl
      JOIN GroupedLogs gl ON hl.${historyLogTable.groupId} = gl.${historyLogTable.groupId}
      WHERE hl.${historyLogTable.timestamp} = gl.latest_timestamp
        AND hl.${historyLogTable.entityId} = ?
        AND hl.${historyLogTable.isDeleted} = 0
    ''';
    
    final groupedResults = await db.rawQuery(groupedQuery, [entityId, entityId]);
    
    // Part 2: Get individual logs for this entity ID that don't have a groupId
    final nonGroupedResults = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.groupId} IS NULL AND ${historyLogTable.entityId} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [entityId],
    );
    
    // Process grouped logs
    List<HistoryLog> logs = groupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      final logModel = historyLogDto.toModel();
      
      // Add the log count
      return logModel.copyWith(
        logCount: () => result['log_count'] as int,
      );
    }).toList();
    
    // Process non-grouped logs
    logs.addAll(nonGroupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }));
    
    // Sort all logs by timestamp
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return logs;
  }
  
  /// Retrieves history logs for a specific entity type and ID without grouping.
  Future<List<HistoryLog>> getHistoryLogsByEntityTypeAndId(
    EntityType entityType, 
    String entityId
  ) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.entityType} = ? AND ${historyLogTable.entityId} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [entityType.index, entityId],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves grouped history logs for a specific entity type and ID,
  /// with individual logs without groupId included.
  Future<List<HistoryLog>> getGroupedHistoryLogsByEntityTypeAndId(
    EntityType entityType,
    String entityId
  ) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    // Part 1: Get grouped logs for this entity type and ID
    final groupedQuery = '''
      WITH GroupedLogs AS (
        SELECT 
          ${historyLogTable.groupId},
          MAX(${historyLogTable.timestamp}) as latest_timestamp,
          COUNT(*) as log_count
        FROM ${historyLogTable.tableName}
        WHERE ${historyLogTable.groupId} IS NOT NULL 
          AND ${historyLogTable.entityType} = ?
          AND ${historyLogTable.entityId} = ?
          AND ${historyLogTable.isDeleted} = 0
        GROUP BY ${historyLogTable.groupId}
      )
      SELECT hl.*, gl.log_count
      FROM ${historyLogTable.tableName} hl
      JOIN GroupedLogs gl ON hl.${historyLogTable.groupId} = gl.${historyLogTable.groupId}
      WHERE hl.${historyLogTable.timestamp} = gl.latest_timestamp
        AND hl.${historyLogTable.entityType} = ?
        AND hl.${historyLogTable.entityId} = ?
        AND hl.${historyLogTable.isDeleted} = 0
    ''';
    
    final groupedResults = await db.rawQuery(groupedQuery, [
      entityType.index, entityId, entityType.index, entityId
    ]);
    
    // Part 2: Get individual logs for this entity type and ID that don't have a groupId
    final nonGroupedResults = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.groupId} IS NULL AND ${historyLogTable.entityType} = ? AND ${historyLogTable.entityId} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [entityType.index, entityId],
    );
    
    // Process grouped logs
    List<HistoryLog> logs = groupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      final logModel = historyLogDto.toModel();
      
      // Add the log count
      return logModel.copyWith(
        logCount: () => result['log_count'] as int,
      );
    }).toList();
    
    // Process non-grouped logs
    logs.addAll(nonGroupedResults.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }));
    
    // Sort all logs by timestamp
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return logs;
  }
  
  /// Retrieves history logs by group ID.
  Future<List<HistoryLog>> getHistoryLogsByGroupId(String groupId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.groupId} = ? AND ${historyLogTable.isDeleted} = 0',
      whereArgs: [groupId],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Adds a new history log entry.
  Future<bool> insertHistoryLog(HistoryLog historyLog) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;
    
    final dto = HistoryLogDto.fromModel(historyLog);
    final id = await db.insert(
      historyLogTable.tableName,
      dto.toMap(),
    );
    
    return id > 0;
  }
  
  /// Soft-delete history logs for a specific entity.
  Future<int> deleteHistoryLogsForEntity(String entityId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;
    
    return await db.update(
      historyLogTable.tableName,
      {historyLogTable.isDeleted: 1},
      where: '${historyLogTable.entityId} = ?',
      whereArgs: [entityId],
    );
  }
  
  /// Soft-delete a specific history log by ID.
  Future<bool> deleteHistoryLog(String logId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;
    
    final count = await db.update(
      historyLogTable.tableName,
      {historyLogTable.isDeleted: 1},
      where: '${historyLogTable.id} = ?',
      whereArgs: [logId],
    );
    
    return count > 0;
  }
  
  /// Soft-delete all history logs in a group.
  Future<int> deleteHistoryLogGroup(String groupId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;
    
    return await db.update(
      historyLogTable.tableName,
      {historyLogTable.isDeleted: 1},
      where: '${historyLogTable.groupId} = ?',
      whereArgs: [groupId],
    );
  }
}
