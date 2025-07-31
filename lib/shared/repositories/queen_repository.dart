import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared.dart';

class QueenRepository {
  static const String _boxName = 'queens';
  static const String _tag = 'QueenRepository';

  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the local Hive box for queens.
  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('Queen repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize queen repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<Queen>> _getQueens({required bool deleted}) async {
    try {
      final queens = <Queen>[];
      for (final data in _box.values) {
        final queen = Queen.fromMap(Map<String, dynamic>.from(data));
        if (queen.deleted == deleted) {
          queens.add(queen);
        }
      }
      return queens;
    } catch (e) {
      Logger.e('Failed to get queens', tag: _tag, error: e);
      return [];
    }
  }

  /// Returns all non-deleted queens, sorted by name.
  Future<List<Queen>> getAllQueens() async {
    final queens = await _getQueens(deleted: false);
    queens.sort((a, b) => a.name.compareTo(b.name));
    return queens;
  }

  /// Returns all deleted queens, sorted by most recently updated.
  Future<List<Queen>> getDeletedQueens() async {
    final deletedQueens = await _getQueens(deleted: true);
    deletedQueens.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return deletedQueens;
  }

  /// Gets a queen by its ID.
  Future<Queen?> getQueenById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? Queen.fromMap(Map<String, dynamic>.from(data)) : null;
    } catch (e) {
      Logger.e('Failed to get queen by id: $id', tag: _tag, error: e);
      return null;
    }
  }

  /// Saves a queen locally.
  Future<void> saveQueen(Queen queen) async {
    try {
      await _box.put(queen.id, queen.toMap());
      Logger.i('Saved queen: ${queen.name}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save queen: ${queen.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Saves a batch of queens locally.
  Future<void> saveQueensBatch(List<Queen> queens) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {
        for (final queen in queens) queen.id: queen.toMap()
      };
      await _box.putAll(batchData);
      Logger.i('Saved ${queens.length} queens in batch', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save queens batch', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a single queen to Firestore.
  Future<void> syncToFirestore(Queen queen, String userId) async {
    try {
      final queenToSync = queen.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('queens')
          .doc(queen.id);
      await docRef.set(queenToSync.toMap(), SetOptions(merge: true));
      await saveQueen(queenToSync);
      Logger.i('Synced queen to Firestore: ${queen.id}', tag: _tag);
    } catch (e) {
      final failedQueen = queen.copyWith(syncStatus: () => SyncStatus.failed);
      await saveQueen(failedQueen);
      Logger.e('Failed to sync queen to Firestore: ${queen.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a batch of queens to Firestore.
  Future<void> syncBatchToFirestore(List<Queen> queens, String userId) async {
    try {
      final batch = _firestore.batch();
      final queensToUpdate = <Queen>[];
      for (final queen in queens) {
        final queenToSync = queen.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('queens')
            .doc(queen.id);
        batch.set(docRef, queenToSync.toMap(), SetOptions(merge: true));
        queensToUpdate.add(queenToSync);
      }
      await batch.commit();
      await saveQueensBatch(queensToUpdate);
      Logger.i('Synced ${queens.length} queens to Firestore in batch', tag: _tag);
    } catch (e) {
      final failedQueens = queens.map((q) => q.copyWith(syncStatus: () => SyncStatus.failed)).toList();
      await saveQueensBatch(failedQueens);
      Logger.e('Failed to sync queens batch to Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs queens from Firestore to local storage.
  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('queens');
      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final firestoreQueen = Queen.fromMap(doc.data());
        final localQueen = await getQueenById(doc.id);
        if (localQueen == null ||
            firestoreQueen.updatedAt.isAfter(localQueen.updatedAt) ||
            (firestoreQueen.updatedAt.isAtSameMomentAs(localQueen.updatedAt) &&
             firestoreQueen.serverVersion > localQueen.serverVersion)) {
          final syncedQueen = firestoreQueen.copyWith(
            syncStatus: () => SyncStatus.synced,
            lastSyncedAt: () => DateTime.now(),
            serverVersion: () => firestoreQueen.serverVersion + 1,
          );
          await saveQueen(syncedQueen);
        }
      }
      Logger.i('Synced ${snapshot.docs.length} queens from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disposes the repository and closes the Hive box.
  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('Queen repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose queen repository', tag: _tag, error: e);
    }
  }
}