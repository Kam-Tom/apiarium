import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';

class ApiaryRepository {
  static const String _boxName = 'apiaries';
  static const String _tag = 'ApiaryRepository';

  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the local Hive box for apiaries.
  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('Apiary repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize apiary repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<Apiary>> _getApiaries({required bool deleted}) async {
    try {
      final apiaries = <Apiary>[];
      for (final data in _box.values) {
        final apiary = Apiary.fromMap(Map<String, dynamic>.from(data));
        if (apiary.deleted == deleted) {
          apiaries.add(apiary);
        }
      }
      return apiaries;
    } catch (e) {
      Logger.e('Failed to get apiaries', tag: _tag, error: e);
      return [];
    }
  }

  /// Returns all non-deleted apiaries, sorted by order.
  Future<List<Apiary>> getAllApiaries() async {
    final apiaries = await _getApiaries(deleted: false);
    apiaries.sort((a, b) => a.order.compareTo(b.order));
    return apiaries;
  }

  /// Returns all deleted apiaries, sorted by most recently updated.
  Future<List<Apiary>> getDeletedApiaries() async {
    final deletedApiaries = await _getApiaries(deleted: true);
    deletedApiaries.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return deletedApiaries;
  }

  /// Gets an apiary by its ID.
  Future<Apiary?> getApiaryById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? Apiary.fromMap(Map<String, dynamic>.from(data)) : null;
    } catch (e) {
      Logger.e('Failed to get apiary by id: $id', tag: _tag, error: e);
      return null;
    }
  }

  /// Saves an apiary locally, handling image storage.
  Future<void> saveApiary(Apiary apiary) async {
    try {
      String? imageName = apiary.imageName;
      final appDir = await getApplicationDocumentsDirectory();
      final apiaryImagesDir = Directory('${appDir.path}/images/apiaries');

      if (imageName == null) {
        // Remove all images for this apiary by id
        final files = apiaryImagesDir.existsSync()
            ? apiaryImagesDir.listSync().whereType<File>().where((f) => f.path.contains(apiary.id)).toList()
            : [];
        for (final file in files) {
          try {
            await file.delete();
          } catch (_) {}
        }
      } else if (p.basename(imageName) != imageName) {
        // If imageName is a path, copy it locally and set imageName
        if (!await apiaryImagesDir.exists()) {
          await apiaryImagesDir.create(recursive: true);
        }
        final fileName = '${apiary.id}.jpg';
        final localFile = File('${apiaryImagesDir.path}/$fileName');

        if (await localFile.exists()) {
          await localFile.delete();
        }

        await File(apiary.imageName!).copy(localFile.path);
        imageName = fileName;
      }

      await _box.put(apiary.id, apiary.copyWith(imageName: () => imageName).toMap());
      Logger.i('Saved apiary: ${apiary.name}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save apiary: ${apiary.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Saves a batch of apiaries locally.
  Future<void> saveApiariesBatch(List<Apiary> apiaries) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {};

      for (final apiary in apiaries) {
        String? imageName = apiary.imageName;
        final appDir = await getApplicationDocumentsDirectory();
        final apiaryImagesDir = Directory('${appDir.path}/images/apiaries');

        if (imageName == null) {
          // Remove all images for this apiary by id
          final files = apiaryImagesDir.existsSync()
              ? apiaryImagesDir.listSync().whereType<File>().where((f) => f.path.contains(apiary.id)).toList()
              : [];
          for (final file in files) {
            try {
              await file.delete();
            } catch (_) {}
          }
        } else if (p.basename(imageName) != imageName) {
          // If imageName is a path, copy it locally and set imageName
          if (!await apiaryImagesDir.exists()) {
            await apiaryImagesDir.create(recursive: true);
          }
          final fileName = '${apiary.id}.jpg';
          final localFile = File('${apiaryImagesDir.path}/$fileName');

          if (await localFile.exists()) {
            await localFile.delete();
          }

          await File(apiary.imageName!).copy(localFile.path);
          imageName = fileName;
        }

        batchData[apiary.id] = apiary.copyWith(imageName: () => imageName).toMap();
      }

      await _box.putAll(batchData);
      Logger.i('Saved ${apiaries.length} apiaries in batch', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save apiaries batch', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a single apiary to Firestore and Firebase Storage.
  Future<void> syncToFirestore(Apiary apiary, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('apiaries');

      if (apiary.imageName != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = '${appDir.path}/images/apiaries/${apiary.imageName}';
        final file = File(localPath);
        if (await file.exists()) {
          final ref = storageRef.child(apiary.imageName!);
          await ref.putFile(file);
        }
      } else {
        // Delete image from Firebase Storage if imageName is null
         try {
          final all = await storageRef.listAll();
          for (final item in all.items) {
            if (item.name.contains(apiary.id)) {
              try {
                await item.delete();
              } catch (e) {
                Logger.e('Failed to delete image: ${item.name}, error: $e');
              }
            }
          }
        } on FirebaseException catch (e) {
          if (e.code == 'object-not-found') {
            // The directory doesn't exist; nothing to delete.
            Logger.i('No storage objects found to delete for user $userId');
          } else {
            Logger.e('Unexpected Firebase error while listing: ${e.message}');
          }
        } catch (e) {
          Logger.e('Unexpected error while listing storage: $e');
        }
      }

      // Update sync metadata before sending to Firestore
      final apiaryToSync = apiary.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('apiaries')
          .doc(apiary.id);

      await docRef.set(apiaryToSync.toMap(), SetOptions(merge: true));

      // Save the updated version locally
      await saveApiary(apiaryToSync);

      Logger.i('Synced apiary to Firestore: ${apiary.id}', tag: _tag);
    } catch (e) {
      // Update sync status to failed
      final failedApiary = apiary.copyWith(syncStatus: () => SyncStatus.failed);
      await saveApiary(failedApiary);

      Logger.e('Failed to sync apiary to Firestore: ${apiary.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a batch of apiaries to Firestore.
  Future<void> syncBatchToFirestore(List<Apiary> apiaries, String userId) async {
    try {
      final batch = _firestore.batch();
      final apiariesToUpdate = <Apiary>[];

      for (final apiary in apiaries) {
        final apiaryToSync = apiary.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );

        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('apiaries')
            .doc(apiary.id);

        batch.set(docRef, apiaryToSync.toMap(), SetOptions(merge: true));
        apiariesToUpdate.add(apiaryToSync);
      }

      await batch.commit();
      await saveApiariesBatch(apiariesToUpdate);

      Logger.i('Synced ${apiaries.length} apiaries to Firestore in batch', tag: _tag);
    } catch (e) {
      final failedApiaries = apiaries.map((a) => a.copyWith(syncStatus: () => SyncStatus.failed)).toList();
      await saveApiariesBatch(failedApiaries);

      Logger.e('Failed to sync apiaries batch to Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs apiaries from Firestore to local storage.
  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('apiaries');

      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        final firestoreApiary = Apiary.fromMap(doc.data());
        final localApiary = await getApiaryById(doc.id);

        if (firestoreApiary.imageName != null && firestoreApiary.imageName!.isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance
                .ref()
                .child('users')
                .child(userId)
                .child('apiaries')
                .child(firestoreApiary.imageName!);
            final appDir = await getApplicationDocumentsDirectory();
            final apiaryImagesDir = Directory('${appDir.path}/images/apiaries');
            if (!await apiaryImagesDir.exists()) {
              await apiaryImagesDir.create(recursive: true);
            }
            final localFile = File('${apiaryImagesDir.path}/${firestoreApiary.imageName!}');
            await ref.writeToFile(localFile);
          } catch (e) {
            Logger.e('Failed to download image for apiary ${firestoreApiary.id}', tag: _tag, error: e);
          }
        }

        if (localApiary == null ||
            firestoreApiary.updatedAt.isAfter(localApiary.updatedAt) ||
            (firestoreApiary.updatedAt.isAtSameMomentAs(localApiary.updatedAt) &&
             firestoreApiary.serverVersion > localApiary.serverVersion)) {
          final syncedApiary = firestoreApiary.copyWith(
            syncStatus: () => SyncStatus.synced,
            lastSyncedAt: () => DateTime.now(),
            serverVersion: () => firestoreApiary.serverVersion + 1,
          );
          await saveApiary(syncedApiary);
        }
      }

      Logger.i('Synced ${snapshot.docs.length} apiaries from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disposes the repository and closes the Hive box.
  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('Apiary repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose apiary repository', tag: _tag, error: e);
    }
  }
}