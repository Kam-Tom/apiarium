import 'package:apiarium/shared/shared.dart';

/// Repository for managing history logs in the local database
/// with methods to retrieve logs filtered by entity type and ID.
class HistoryLogRepository {
  final DatabaseHelper _databaseHelper;

  HistoryLogRepository({DatabaseHelper? databaseHelper}) 
      : _databaseHelper = databaseHelper ?? DatabaseHelper();
  
  /// Retrieves all history logs from the database.
  Future<List<HistoryLog>> getAllHistoryLogs() async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves history logs for a specific entity type.
  Future<List<HistoryLog>> getHistoryLogsByEntityType(EntityType entityType) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.entityType} = ?',
      whereArgs: [entityType.index],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves history logs for a specific entity ID.
  Future<List<HistoryLog>> getHistoryLogsByEntityId(String entityId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.entityId} = ?',
      whereArgs: [entityId],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Retrieves history logs for a specific entity type and ID.
  Future<List<HistoryLog>> getHistoryLogsByEntityTypeAndId(
    EntityType entityType, 
    String entityId
  ) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;

    final List<Map<String, dynamic>> results = await db.query(
      historyLogTable.tableName,
      where: '${historyLogTable.entityType} = ? AND ${historyLogTable.entityId} = ?',
      whereArgs: [entityType.index, entityId],
      orderBy: '${historyLogTable.timestamp} DESC',
    );
    
    return results.map((result) {
      final historyLogDto = HistoryLogDto.fromMap(result);
      return historyLogDto.toModel();
    }).toList();
  }
  
  /// Adds a new history log entry.
  Future<bool> addHistoryLog(HistoryLogDto historyLog) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;
    
    final id = await db.insert(
      historyLogTable.tableName,
      historyLog.toMap(),
    );
    
    return id > 0;
  }
  
  /// Delete history logs for a specific entity.
  Future<int> deleteHistoryLogsForEntity(String entityId) async {
    final db = await _databaseHelper.database;
    final historyLogTable = _databaseHelper.historylogTable;
    
    return await db.delete(
      historyLogTable.tableName,
      where: '${historyLogTable.entityId} = ?',
      whereArgs: [entityId],
    );
  }
}
