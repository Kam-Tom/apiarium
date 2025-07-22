import 'dart:io';
import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';

class HiveTypeRepository {
  static const String _boxName = 'hive_types';
  static const String _tag = 'HiveTypeRepository';
  
  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('HiveType repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize hive type repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<HiveType>> _getHiveTypes({required bool deleted}) async {
    try {
      final hiveTypes = <HiveType>[];
      for (final data in _box.values) {
        final hiveType = HiveType.fromMap(Map<String, dynamic>.from(data));
        if (hiveType.deleted == deleted) {
          hiveTypes.add(hiveType);
        }
      }
      return hiveTypes;
    } catch (e) {
      Logger.e('Failed to get hive types', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<HiveType>> getAllHiveTypes() async {
    final hiveTypes = await _getHiveTypes(deleted: false);
    hiveTypes.sort((a, b) {
      if (a.isStarred != b.isStarred) {
        return a.isStarred ? -1 : 1; // Starred first
      }
      return a.name.compareTo(b.name); // Then by name
    });
    return hiveTypes;
  }

  Future<List<HiveType>> getDeletedHiveTypes() async {
    final deletedHiveTypes = await _getHiveTypes(deleted: true);
    deletedHiveTypes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt)); // Most recent first
    return deletedHiveTypes;
  }

  Future<HiveType?> getHiveTypeById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? HiveType.fromMap(Map<String, dynamic>.from(data)) : null;
    } catch (e) {
      Logger.e('Failed to get hive type by id: $id', tag: _tag, error: e);
      return null;
    }
  }

  Future<void> saveHiveType(HiveType hiveType) async {
    try {
      String? imageName = hiveType.imageName;
      final appDir = await getApplicationDocumentsDirectory();
      final hiveTypeImagesDir = Directory('${appDir.path}/images/hive_types');

      if (imageName == null) {
        // Remove all possible images for this hive type (by id)
        final files = hiveTypeImagesDir.existsSync()
            ? hiveTypeImagesDir.listSync().whereType<File>().where((f) => f.path.contains(hiveType.id)).toList()
            : [];
        for (final file in files) {
          try {
            await file.delete();
          } catch (_) {}
        }
      } else if (p.basename(imageName) != imageName) {
        // If imageName is a path (not just a filename), copy it locally and set imageName
        if (!await hiveTypeImagesDir.exists()) {
          await hiveTypeImagesDir.create(recursive: true);
        }
        final fileName = '${hiveType.id}.jpg';
        final localFile = File('${hiveTypeImagesDir.path}/$fileName');

        if (await localFile.exists()) {
          await localFile.delete();
        }

        await File(hiveType.imageName!).copy(localFile.path);
        imageName = fileName;
      }

      await _box.put(hiveType.id, hiveType.copyWith(imageName: () => imageName).toMap());
      Logger.i('Saved hive type: ${hiveType.name}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save hive type: ${hiveType.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> saveHiveTypesBatch(List<HiveType> hiveTypes) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {};
      
      for (final hiveType in hiveTypes) {
        String? imageName = hiveType.imageName;
        final appDir = await getApplicationDocumentsDirectory();
        final hiveTypeImagesDir = Directory('${appDir.path}/images/hive_types');

        if (imageName == null) {
          // Remove all possible images for this hive type (by id)
          final files = hiveTypeImagesDir.existsSync()
              ? hiveTypeImagesDir.listSync().whereType<File>().where((f) => f.path.contains(hiveType.id)).toList()
              : [];
          for (final file in files) {
            try {
              await file.delete();
            } catch (_) {}
          }
        } else if (p.basename(imageName) != imageName) {
          // If imageName is a path (not just a filename), copy it locally and set imageName
          if (!await hiveTypeImagesDir.exists()) {
            await hiveTypeImagesDir.create(recursive: true);
          }
          final fileName = '${hiveType.id}.jpg';
          final localFile = File('${hiveTypeImagesDir.path}/$fileName');

          if (await localFile.exists()) {
            await localFile.delete();
          }

          await File(hiveType.imageName!).copy(localFile.path);
          imageName = fileName;
        }

        batchData[hiveType.id] = hiveType.copyWith(imageName: () => imageName).toMap();
      }

      await _box.putAll(batchData);
      Logger.i('Saved ${hiveTypes.length} hive types in batch', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save hive types batch', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncToFirestore(HiveType hiveType, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('hive_types');

      if (hiveType.imageName != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = '${appDir.path}/images/hive_types/${hiveType.imageName}';
        final file = File(localPath);
        if (await file.exists()) {
          final ref = storageRef.child(hiveType.imageName!);
          await ref.putFile(file);
        }
      } else {
        // Delete image from Firebase Storage if imageName is null
        final all = await storageRef.listAll();
        for (final item in all.items) {
          if (item.name.contains(hiveType.id)) {
            try {
              await item.delete();
            } catch (_) {}
          }
        }
      }

      // Update sync metadata BEFORE sending to Firestore
      final hiveTypeToSync = hiveType.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('hive_types')
          .doc(hiveType.id);

      await docRef.set(hiveTypeToSync.toMap(), SetOptions(merge: true));

      // Save the updated version locally
      await saveHiveType(hiveTypeToSync);

      Logger.i('Synced hive type to Firestore: ${hiveType.id}', tag: _tag);
    } catch (e) {
      // Update sync status to failed
      final failedHiveType = hiveType.copyWith(syncStatus: () => SyncStatus.failed);
      await saveHiveType(failedHiveType);

      Logger.e('Failed to sync hive type to Firestore: ${hiveType.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncBatchToFirestore(List<HiveType> hiveTypes, String userId) async {
    try {
      final batch = _firestore.batch();
      final hiveTypesToUpdate = <HiveType>[];

      for (final hiveType in hiveTypes) {
        final hiveTypeToSync = hiveType.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );

        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('hive_types')
            .doc(hiveType.id);

        batch.set(docRef, hiveTypeToSync.toMap(), SetOptions(merge: true));
        hiveTypesToUpdate.add(hiveTypeToSync);
      }

      await batch.commit();
      await saveHiveTypesBatch(hiveTypesToUpdate);

      Logger.i('Synced ${hiveTypes.length} hive types to Firestore in batch', tag: _tag);
    } catch (e) {
      final failedHiveTypes = hiveTypes.map((h) => h.copyWith(syncStatus: () => SyncStatus.failed)).toList();
      await saveHiveTypesBatch(failedHiveTypes);

      Logger.e('Failed to sync hive types batch to Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('hive_types');

      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        final firestoreHiveType = HiveType.fromMap(doc.data());
        final localHiveType = await getHiveTypeById(doc.id);

        if (firestoreHiveType.imageName != null && firestoreHiveType.imageName!.isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance
                .ref()
                .child('users')
                .child(userId)
                .child('hive_types')
                .child(firestoreHiveType.imageName!);
            final appDir = await getApplicationDocumentsDirectory();
            final hiveTypeImagesDir = Directory('${appDir.path}/images/hive_types');
            if (!await hiveTypeImagesDir.exists()) {
              await hiveTypeImagesDir.create(recursive: true);
            }
            final localFile = File('${hiveTypeImagesDir.path}/${firestoreHiveType.imageName!}');
            await ref.writeToFile(localFile);
          } catch (e) {
            Logger.e('Failed to download image for hive type ${firestoreHiveType.id}', tag: _tag, error: e);
          }
        }

        if (localHiveType == null || 
            firestoreHiveType.updatedAt.isAfter(localHiveType.updatedAt) || 
            (firestoreHiveType.updatedAt.isAtSameMomentAs(localHiveType.updatedAt) && 
             firestoreHiveType.serverVersion > localHiveType.serverVersion)) {
          final syncedHiveType = firestoreHiveType.copyWith(
            syncStatus: () => SyncStatus.synced,
            lastSyncedAt: () => DateTime.now(),
            serverVersion: () => firestoreHiveType.serverVersion + 1,
          );
          await saveHiveType(syncedHiveType);
        }
      }

      Logger.i('Synced ${snapshot.docs.length} hive types from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('HiveType repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose hive type repository', tag: _tag, error: e);
    }
  }
}