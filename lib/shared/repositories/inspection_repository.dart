import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared.dart';

class InspectionRepository {
  static const String _boxName = 'inspections';
  static const String _tag = 'InspectionRepository';

  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the local Hive box for inspections.
  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('Inspection repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize inspection repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<Inspection>> _getInspections({required bool deleted}) async {
    try {
      final inspections = <Inspection>[];
      for (final data in _box.values) {
        final inspection = Inspection.fromMap(Map<String, dynamic>.from(data));
        if (inspection.deleted == deleted) {
          inspections.add(inspection);
        }
      }
      return inspections;
    } catch (e) {
      Logger.e('Failed to get inspections', tag: _tag, error: e);
      return [];
    }
  }

  /// Returns all non-deleted inspections, sorted by creation date (most recent first).
  Future<List<Inspection>> getAllInspections() async {
    final inspections = await _getInspections(deleted: false);
    inspections.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return inspections;
  }

  /// Returns all deleted inspections, sorted by most recently updated.
  Future<List<Inspection>> getDeletedInspections() async {
    final deletedInspections = await _getInspections(deleted: true);
    deletedInspections.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return deletedInspections;
  }

  /// Gets an inspection by its ID.
  Future<Inspection?> getInspectionById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? Inspection.fromMap(Map<String, dynamic>.from(data)) : null;
    } catch (e) {
      Logger.e('Failed to get inspection by id: $id', tag: _tag, error: e);
      return null;
    }
  }

  /// Returns all inspections for a given hiveId.
  Future<List<Inspection>> getInspectionsByHiveId(String hiveId) async {
    final inspections = await getAllInspections();
    return inspections.where((i) => i.hiveId == hiveId).toList();
  }

  /// Returns all inspections for a given apiaryId.
  Future<List<Inspection>> getInspectionsByApiaryId(String apiaryId) async {
    final inspections = await getAllInspections();
    return inspections.where((i) => i.apiaryId == apiaryId).toList();
  }

  /// Returns all inspections for a given queenId.
  Future<List<Inspection>> getInspectionsByQueenId(String queenId) async {
    final inspections = await getAllInspections();
    return inspections.where((i) => i.queenId == queenId).toList();
  }

  /// Returns all inspections within a date range.
  Future<List<Inspection>> getInspectionsByDateRange(DateTime start, DateTime end) async {
    final inspections = await getAllInspections();
    return inspections.where((i) =>
      i.createdAt.isAfter(start.subtract(const Duration(days: 1))) &&
      i.createdAt.isBefore(end.add(const Duration(days: 1)))
    ).toList();
  }

  /// Saves an inspection locally.
  Future<void> saveInspection(Inspection inspection) async {
    try {
      await _box.put(inspection.id, inspection.toJson());
      Logger.i('Saved inspection: ${inspection.id}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save inspection: ${inspection.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Saves a batch of inspections locally.
  Future<void> saveInspectionsBatch(List<Inspection> inspections) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {
        for (final inspection in inspections) inspection.id: inspection.toJson()
      };
      await _box.putAll(batchData);
      Logger.i('Saved ${inspections.length} inspections in batch', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save inspections batch', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a single inspection to Firestore.
  Future<void> syncToFirestore(Inspection inspection, String userId) async {
    try {
      final inspectionToSync = inspection.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('inspections')
          .doc(inspection.id);
      await docRef.set(inspectionToSync.toJson(), SetOptions(merge: true));
      await saveInspection(inspectionToSync);
      Logger.i('Synced inspection to Firestore: ${inspection.id}', tag: _tag);
    } catch (e) {
      final failedInspection = inspection.copyWith(syncStatus: () => SyncStatus.failed);
      await saveInspection(failedInspection);
      Logger.e('Failed to sync inspection to Firestore: ${inspection.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a batch of inspections to Firestore.
  Future<void> syncBatchToFirestore(List<Inspection> inspections, String userId) async {
    try {
      final batch = _firestore.batch();
      final inspectionsToUpdate = <Inspection>[];
      for (final inspection in inspections) {
        final inspectionToSync = inspection.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('inspections')
            .doc(inspection.id);
        batch.set(docRef, inspectionToSync.toJson(), SetOptions(merge: true));
        inspectionsToUpdate.add(inspectionToSync);
      }
      await batch.commit();
      await saveInspectionsBatch(inspectionsToUpdate);
      Logger.i('Synced ${inspections.length} inspections to Firestore in batch', tag: _tag);
    } catch (e) {
      final failedInspections = inspections.map((i) => i.copyWith(syncStatus: () => SyncStatus.failed)).toList();
      await saveInspectionsBatch(failedInspections);
      Logger.e('Failed to sync inspections batch to Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs inspections from Firestore to local storage.
  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('inspections');
      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final firestoreInspection = Inspection.fromMap(doc.data());
        final localInspection = await getInspectionById(doc.id);
        if (localInspection == null ||
            firestoreInspection.updatedAt.isAfter(localInspection.updatedAt) ||
            (firestoreInspection.updatedAt.isAtSameMomentAs(localInspection.updatedAt) &&
             firestoreInspection.serverVersion > localInspection.serverVersion)) {
          final syncedInspection = firestoreInspection.copyWith(
            syncStatus: () => SyncStatus.synced,
            lastSyncedAt: () => DateTime.now(),
            serverVersion: () => firestoreInspection.serverVersion + 1,
          );
          await saveInspection(syncedInspection);
        }
      }
      Logger.i('Synced ${snapshot.docs.length} inspections from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disposes the repository and closes the Hive box.
  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('Inspection repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose inspection repository', tag: _tag, error: e);
    }
  }
}