import 'package:uuid/uuid.dart';
import '../shared.dart';

class HistoryService {
  static const String _tag = 'HistoryService';
  static const Uuid _uuid = Uuid();
  
  final HistoryLogRepository _repository;
  final UserRepository _userRepository;
  
  HistoryService({
    required HistoryLogRepository repository,
    required UserRepository userRepository,
  }) : _repository = repository,
       _userRepository = userRepository;
  
  Future<void> initialize() async {
    await _repository.initialize();
    Logger.i('History service initialized', tag: _tag);
  }
  
  Future<List<HistoryLog>> getAllHistoryLogs({int limit = 100}) async {
    return await _repository.getAllHistoryLogs(limit: limit);
  }
  
  Future<List<HistoryLog>> getHistoryLogsByEntityId(String entityId, {int limit = 50}) async {
    return await _repository.getHistoryLogsByEntityId(entityId, limit: limit);
  }
  
  Future<List<HistoryLog>> getHistoryLogsByType(String entityType, {int limit = 50}) async {
    return await _repository.getHistoryLogsByType(entityType, limit: limit);
  }

  Future<List<HistoryLog>> getGroupedHistoryLogs({int limit = 100}) async {
    return await _repository.getGroupedHistoryLogs(limit: limit);
  }
  
  Future<List<HistoryLog>> getHistoryLogsByGroupId(String groupId) async {
    return await _repository.getHistoryLogsByGroupId(groupId);
  }

  // Generic method to log entity creation
  Future<void> logEntityCreate({
    required String entityId,
    required String entityType,
    required String entityName,
    required Map<String, dynamic> entityData,
    String? groupId,
  }) async {
    try {
      final now = DateTime.now();
      
      // For create, store complete entity data
      // Remove sync metadata fields that aren't relevant for history
      final Map<String, dynamic> cleanedData = Map.from(entityData);
      cleanedData.removeWhere((key, value) => 
        ['syncStatus', 'lastSyncedAt', 'serverVersion'].contains(key));
      
      final log = HistoryLog(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
        changedFields: cleanedData,
        previousValues: {}, // Empty for creation - everything is "new"
        actionType: HistoryActionType.create,
        timestamp: now,
        groupId: groupId,
      );
      
      await _repository.saveHistoryLog(log);
      await _syncLog(log);
      
      Logger.i('Logged create for $entityType: $entityName', tag: _tag);
    } catch (e) {
      Logger.e('Failed to log create for $entityType: $entityName', tag: _tag, error: e);
    }
  }
  
  // Generic method to log entity updates using map diff
  Future<void> logEntityUpdate({
    required String entityId,
    required String entityType,
    required String entityName,
    required Map<String, dynamic> oldData,
    required Map<String, dynamic> newData,
    String? groupId,
  }) async {
    try {
      final now = DateTime.now();
      
      // Use the map diff extension to get changes
      final diff = oldData.differenceWith(newData);
      
      // Skip if nothing significant changed
      if (!diff.hasChanges) {
        return;
      }
      
      final log = HistoryLog(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
        changedFields: Map<String, dynamic>.from(diff.changedFields),
        previousValues: Map<String, dynamic>.from(diff.previousValues),
        actionType: HistoryActionType.update,
        timestamp: now,
        groupId: groupId,
      );
      
      await _repository.saveHistoryLog(log);
      await _syncLog(log);
      
      Logger.i('Logged update for $entityType: $entityName (${diff.changedFields.length} fields changed)', tag: _tag);
    } catch (e) {
      Logger.e('Failed to log update for $entityType: $entityName', tag: _tag, error: e);
    }
  }
  
  // Generic method to log entity deletion
  Future<void> logEntityDelete({
    required String entityId,
    required String entityType,
    required String entityName,
    String? groupId,
  }) async {
    try {
      final now = DateTime.now();
      
      final log = HistoryLog(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        entityId: entityId,
        entityType: entityType,
        entityName: entityName,
        changedFields: {'deleted': true},
        previousValues: {},
        actionType: HistoryActionType.delete,
        timestamp: now,
        groupId: groupId,
      );
      
      await _repository.saveHistoryLog(log);
      await _syncLog(log);
      
      Logger.i('Logged delete for $entityType: $entityName', tag: _tag);
    } catch (e) {
      Logger.e('Failed to log delete for $entityType: $entityName', tag: _tag, error: e);
    }
  }
  
  // Method for logging apiary reports (grouped updates)
  Future<void> logApiaryReport({
    required String apiaryId,
    required String apiaryName,
    required String reportTitle,
    required List<Map<String, dynamic>> oldHivesData,
    required List<Map<String, dynamic>> newHivesData,
  }) async {
    try {
      final groupId = _uuid.v4();
      final now = DateTime.now();
      
      // Create a report group entry
      final reportLog = HistoryLog(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        entityId: apiaryId,
        entityType: 'reportGroup',
        entityName: reportTitle,
        changedFields: {
          'reportTitle': reportTitle,
          'apiaryName': apiaryName,
          'hiveCount': newHivesData.length,
          'timestamp': now.toIso8601String(),
        },
        previousValues: {},
        actionType: HistoryActionType.update,
        timestamp: now,
        groupId: groupId,
      );
      
      await _repository.saveHistoryLog(reportLog);
      
      // Log individual hive changes with the same groupId
      for (int i = 0; i < newHivesData.length; i++) {
        await logEntityUpdate(
          entityId: newHivesData[i]['id'],
          entityType: 'hive',
          entityName: newHivesData[i]['name'],
          oldData: oldHivesData[i],
          newData: newHivesData[i],
          groupId: groupId,
        );
      }
      
      await _syncLog(reportLog);
      
      Logger.i('Logged apiary report: $reportTitle (${newHivesData.length} hives)', tag: _tag);
    } catch (e) {
      Logger.e('Failed to log apiary report: $reportTitle', tag: _tag, error: e);
    }
  }
  
  
  Future<void> cleanupOldLogs({int keepDays = 30}) async {
    await _repository.cleanupOldLogs(keepDays: keepDays);
  }
  
  Future<void> _syncLog(HistoryLog log) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _repository.syncToFirestore(log, userId);
      } catch (e) {
        Logger.e('Failed to sync history log to Firestore', tag: _tag, error: e);
      }
    } else {
      Logger.d('Skipping history log sync - not premium or not logged in', tag: _tag);
    }
  }
  
  Future<void> syncFromFirestore() async {
    if (!_userRepository.isPremium || _userRepository.currentUser == null) {
      Logger.w('Firestore sync skipped - not premium or not logged in', tag: _tag);
      return;
    }

    try {
      final userId = _userRepository.currentUser!.id;
      final lastSync = await _userRepository.getLastSyncTime();
      
      await _repository.syncFromFirestore(userId, lastSyncTime: lastSync);
      
      Logger.i('Synced history logs from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync history logs from Firestore', tag: _tag, error: e);
    }
  }
  
  Future<void> dispose() async {
    await _repository.dispose();
    Logger.i('History service disposed', tag: _tag);
  }
}
