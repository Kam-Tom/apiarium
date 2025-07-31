import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared.dart';

class HiveRepository {
  static const String _boxName = 'hives';
  static const String _tag = 'HiveRepository';

  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the local Hive box for hives.
  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('Hive repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize hive repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<Hive>> _getHives({required bool deleted}) async {
    try {
      final hives = <Hive>[];
      for (final data in _box.values) {
        final hive = Hive.fromMap(Map<String, dynamic>.from(data));
        if (hive.deleted == deleted) {
          hives.add(hive);
        }
      }
      return hives;
    } catch (e) {
      Logger.e('Failed to get hives', tag: _tag, error: e);
      return [];
    }
  }

  /// Returns all non-deleted hives, sorted by order.
  Future<List<Hive>> getAllHives() async {
    final hives = await _getHives(deleted: false);
    hives.sort((a, b) => a.order.compareTo(b.order));
    return hives;
  }

  /// Returns all deleted hives, sorted by most recently updated.
  Future<List<Hive>> getDeletedHives() async {
    final deletedHives = await _getHives(deleted: true);
    deletedHives.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return deletedHives;
  }

  /// Gets a hive by its ID.
  Future<Hive?> getHiveById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? Hive.fromMap(Map<String, dynamic>.from(data)) : null;
    } catch (e) {
      Logger.e('Failed to get hive by id: $id', tag: _tag, error: e);
      return null;
    }
  }

  /// Saves a hive locally.
  Future<void> saveHive(Hive hive) async {
    try {
      await _box.put(hive.id, hive.toMap());
      Logger.i('Hive saved: ${hive.name}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save hive: ${hive.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Saves a batch of hives locally.
  Future<void> saveHivesBatch(List<Hive> hives) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {
        for (final hive in hives) hive.id: hive.toMap()
      };
      await _box.putAll(batchData);
      Logger.i('Batch saved: ${hives.length} hives', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save hives batch', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a single hive to Firestore.
  Future<void> syncToFirestore(Hive hive, String userId) async {
    try {
      final hiveToSync = hive.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('hives')
          .doc(hive.id);
      await docRef.set(hiveToSync.toMap(), SetOptions(merge: true));
      await saveHive(hiveToSync);
      Logger.i('Synced hive to Firestore: ${hive.id}', tag: _tag);
    } catch (e) {
      final failedHive = hive.copyWith(syncStatus: () => SyncStatus.failed);
      await saveHive(failedHive);
      Logger.e('Failed to sync hive to Firestore: ${hive.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a batch of hives to Firestore.
  Future<void> syncBatchToFirestore(List<Hive> hives, String userId) async {
    try {
      final batch = _firestore.batch();
      final hivesToUpdate = <Hive>[];
      for (final hive in hives) {
        final hiveToSync = hive.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('hives')
            .doc(hive.id);
        batch.set(docRef, hiveToSync.toMap(), SetOptions(merge: true));
        hivesToUpdate.add(hiveToSync);
      }
      await batch.commit();
      await saveHivesBatch(hivesToUpdate);
      Logger.i('Synced ${hives.length} hives to Firestore in batch', tag: _tag);
    } catch (e) {
      final failedHives = hives.map((h) => h.copyWith(syncStatus: () => SyncStatus.failed)).toList();
      await saveHivesBatch(failedHives);
      Logger.e('Failed to sync hives batch to Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs hives from Firestore to local storage.
  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('hives');
      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final firestoreHive = Hive.fromMap(doc.data());
        final localHive = await getHiveById(doc.id);
        if (localHive == null ||
            firestoreHive.updatedAt.isAfter(localHive.updatedAt) ||
            (firestoreHive.updatedAt.isAtSameMomentAs(localHive.updatedAt) &&
             firestoreHive.serverVersion > localHive.serverVersion)) {
          final syncedHive = firestoreHive.copyWith(
            syncStatus: () => SyncStatus.synced,
            lastSyncedAt: () => DateTime.now(),
            serverVersion: () => firestoreHive.serverVersion + 1,
          );
          await saveHive(syncedHive);
        }
      }
      Logger.i('Synced hives from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disposes the repository and closes the Hive box.
  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('Hive repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose hive repository', tag: _tag, error: e);
    }
  }
}