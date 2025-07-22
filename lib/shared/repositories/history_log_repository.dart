import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared.dart';

class HistoryLogRepository {
  static const String _boxName = 'history_logs';
  static const String _tag = 'HistoryLogRepository';
  
  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('History log repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize history log repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<HistoryLog>> getAllHistoryLogs({int limit = 100}) async {
    try {
      final logs = <HistoryLog>[];
      
      // Get all logs, sorted by timestamp (most recent first)
      final values = _box.values.toList();
      values.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']).millisecondsSinceEpoch;
        final bTime = DateTime.parse(b['timestamp']).millisecondsSinceEpoch;
        return bTime.compareTo(aTime); // Descending order
      });
      
      // Apply limit
      final limitedValues = values.take(limit).toList();
      
      for (final data in limitedValues) {
        logs.add(HistoryLog.fromMap(Map<String, dynamic>.from(data)));
      }
      
      return logs;
    } catch (e) {
      Logger.e('Failed to get history logs', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<HistoryLog>> getHistoryLogsByEntityId(String entityId, {int limit = 50}) async {
    try {
      final logs = <HistoryLog>[];
      
      // Filter logs by entityId and sort by timestamp
      final filteredValues = _box.values
          .where((data) => data['entityId'] == entityId)
          .toList();
      
      filteredValues.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']).millisecondsSinceEpoch;
        final bTime = DateTime.parse(b['timestamp']).millisecondsSinceEpoch;
        return bTime.compareTo(aTime); // Descending order
      });
      
      // Apply limit
      final limitedValues = filteredValues.take(limit).toList();
      
      for (final data in limitedValues) {
        logs.add(HistoryLog.fromMap(Map<String, dynamic>.from(data)));
      }
      
      return logs;
    } catch (e) {
      Logger.e('Failed to get history logs for entity: $entityId', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<HistoryLog>> getHistoryLogsByType(String entityType, {int limit = 50}) async {
    try {
      final logs = <HistoryLog>[];
      
      // Filter logs by entityType and sort by timestamp
      final filteredValues = _box.values
          .where((data) => data['entityType'] == entityType)
          .toList();
      
      filteredValues.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']).millisecondsSinceEpoch;
        final bTime = DateTime.parse(b['timestamp']).millisecondsSinceEpoch;
        return bTime.compareTo(aTime); // Descending order
      });
      
      // Apply limit
      final limitedValues = filteredValues.take(limit).toList();
      
      for (final data in limitedValues) {
        logs.add(HistoryLog.fromMap(Map<String, dynamic>.from(data)));
      }
      
      return logs;
    } catch (e) {
      Logger.e('Failed to get history logs for type: $entityType', tag: _tag, error: e);
      return [];
    }
  }

  Future<void> saveHistoryLog(HistoryLog log) async {
    try {
      await _box.put(log.id, log.toMap());
      Logger.i('Saved history log: ${log.id}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save history log: ${log.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncToFirestore(HistoryLog log, String userId) async {
    try {
      final logToSync = log.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('history_logs')
          .doc(log.id);

      await docRef.set(logToSync.toMap(), SetOptions(merge: true));
      await saveHistoryLog(logToSync);

      Logger.i('Synced history log to Firestore: ${log.id}', tag: _tag);
    } catch (e) {
      final failedLog = log.copyWith(syncStatus: () => SyncStatus.failed);
      await saveHistoryLog(failedLog);

      Logger.e('Failed to sync history log to Firestore: ${log.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('history_logs');

      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }

      // Limit the query to reduce data transfer
      query = query.limit(100);

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        final firestoreLog = HistoryLog.fromMap(doc.data());
        
        final syncedLog = firestoreLog.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );
        
        await saveHistoryLog(syncedLog);
      }

      Logger.i('Synced ${snapshot.docs.length} history logs from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync history logs from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> cleanupOldLogs({int keepDays = 30}) async {
    try {
      final now = DateTime.now();
      final cutoffDate = now.subtract(Duration(days: keepDays));
      
      final oldLogs = _box.values.where((data) {
        final timestamp = DateTime.parse(data['timestamp']);
        return timestamp.isBefore(cutoffDate);
      }).toList();
      
      for (final data in oldLogs) {
        await _box.delete(data['id']);
      }
      
      Logger.i('Cleaned up ${oldLogs.length} old history logs', tag: _tag);
    } catch (e) {
      Logger.e('Failed to cleanup old history logs', tag: _tag, error: e);
    }
  }

  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('History log repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose history log repository', tag: _tag, error: e);
    }
  }

  Future<List<HistoryLog>> getGroupedHistoryLogs({int limit = 100}) async {
    try {
      final logs = <HistoryLog>[];
      
      // Get all logs, sorted by timestamp (most recent first)
      final values = _box.values.toList();
      values.sort((a, b) {
        final aTime = DateTime.parse(a['timestamp']).millisecondsSinceEpoch;
        final bTime = DateTime.parse(b['timestamp']).millisecondsSinceEpoch;
        return bTime.compareTo(aTime); // Descending order
      });
      
      final seenGroups = <String>{};
      final limitedValues = <Map<dynamic, dynamic>>[];
      
      for (final data in values) {
        final log = HistoryLog.fromMap(Map<String, dynamic>.from(data));
        
        if (log.isGrouped) {
          // Only include one entry per group (first one encountered)
          if (!seenGroups.contains(log.groupId)) {
            seenGroups.add(log.groupId!);
            limitedValues.add(data);
            if (limitedValues.length >= limit) break;
          }
        } else {
          // Include non-grouped logs
          limitedValues.add(data);
          if (limitedValues.length >= limit) break;
        }
      }
      
      for (final data in limitedValues) {
        logs.add(HistoryLog.fromMap(Map<String, dynamic>.from(data)));
      }
      
      return logs;
    } catch (e) {
      Logger.e('Failed to get grouped history logs', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<HistoryLog>> getHistoryLogsByGroupId(String groupId) async {
    try {
      final logs = <HistoryLog>[];
      
      // Filter logs by groupId and sort by groupItemIndex
      final filteredValues = _box.values
          .where((data) => data['groupId'] == groupId)
          .toList();
      
      filteredValues.sort((a, b) {
        final aIndex = a['groupItemIndex'] ?? 0;
        final bIndex = b['groupItemIndex'] ?? 0;
        return aIndex.compareTo(bIndex); // Ascending order by index
      });
      
      for (final data in filteredValues) {
        logs.add(HistoryLog.fromMap(Map<String, dynamic>.from(data)));
      }
      
      return logs;
    } catch (e) {
      Logger.e('Failed to get history logs for group: $groupId', tag: _tag, error: e);
      return [];
    }
  }

  Future<void> saveHistoryLogsBatch(List<HistoryLog> logs) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {
        for (final log in logs) log.id: log.toMap()
      };
      
      await _box.putAll(batchData);
      Logger.i('Saved ${logs.length} history logs in batch', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save history logs batch', tag: _tag, error: e);
      rethrow;
    }
  }
}