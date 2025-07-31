import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class QueenBreedRepository {
  static const String _boxName = 'queen_breeds';
  static const String _tag = 'QueenBreedRepository';

  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the local Hive box for queen breeds.
  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('QueenBreed repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize queen breed repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<QueenBreed>> _getBreeds({required bool deleted}) async {
    try {
      final breeds = <QueenBreed>[];
      for (final data in _box.values) {
        final breed = QueenBreed.fromMap(Map<String, dynamic>.from(data));
        if (breed.deleted == deleted) {
          breeds.add(breed);
        }
      }
      return breeds;
    } catch (e) {
      Logger.e('Failed to get breeds', tag: _tag, error: e);
      return [];
    }
  }

  /// Returns all non-deleted queen breeds, starred first, then by name.
  Future<List<QueenBreed>> getAllQueenBreeds() async {
    final breeds = await _getBreeds(deleted: false);
    breeds.sort((a, b) {
      if (a.isStarred != b.isStarred) {
        return a.isStarred ? -1 : 1;
      }
      return a.name.compareTo(b.name);
    });
    return breeds;
  }

  /// Returns all deleted queen breeds, sorted by most recently updated.
  Future<List<QueenBreed>> getDeletedQueenBreeds() async {
    final deletedBreeds = await _getBreeds(deleted: true);
    deletedBreeds.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return deletedBreeds;
  }

  /// Syncs public queen breeds for the user's country.
  Future<void> syncPublicBreeds(String userCountry) async {
    try {
      final query = _firestore
          .collection('public')
          .doc('queen_breeds')
          .collection('breeds')
          .where(
            Filter.or(
              Filter('country', isEqualTo: userCountry),
              Filter('country', isEqualTo: 'global'),
            )
          );
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final publicBreed = QueenBreed.fromMap(doc.data());
        final localBreed = await getQueenBreedById(doc.id);
        final breedToSave = localBreed == null
            ? publicBreed.copyWith(isLocal: () => false)
            : (!localBreed.isLocal && publicBreed.updatedAt.isAfter(localBreed.updatedAt))
                ? publicBreed.copyWith(isLocal: () => false, isStarred: () => localBreed.isStarred)
                : null;
        if (breedToSave != null) {
          await saveQueenBreed(breedToSave);
        }
      }
      Logger.i('Synced ${snapshot.docs.length} public queen breeds', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync public breeds', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Gets a queen breed by its ID.
  Future<QueenBreed?> getQueenBreedById(String id) async {
    try {
      final data = _box.get(id);
      return data != null ? QueenBreed.fromMap(Map<String, dynamic>.from(data)) : null;
    } catch (e) {
      Logger.e('Failed to get queen breed by id: $id', tag: _tag, error: e);
      return null;
    }
  }

  /// Saves a queen breed locally, handling image storage.
  Future<void> saveQueenBreed(QueenBreed breed) async {
    try {
      String? imageName = breed.imageName;
      final appDir = await getApplicationDocumentsDirectory();
      final breedImagesDir = Directory('${appDir.path}/images/queen_breeds');
      if (imageName == null) {
        final files = breedImagesDir.existsSync()
            ? breedImagesDir.listSync().whereType<File>().where((f) => f.path.contains(breed.id)).toList()
            : [];
        for (final file in files) {
          try {
            await file.delete();
          } catch (_) {}
        }
      } else if (p.basename(imageName) != imageName) {
        if (!await breedImagesDir.exists()) {
          await breedImagesDir.create(recursive: true);
        }
        final fileName = '${breed.id}.jpg';
        final localFile = File('${breedImagesDir.path}/$fileName');
        if (await localFile.exists()) {
          await localFile.delete();
        }
        await File(breed.imageName!).copy(localFile.path);
        imageName = fileName;
      }
      await _box.put(breed.id, breed.copyWith(imageName: () => imageName).toMap());
      Logger.i('Saved queen breed: ${breed.name}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save queen breed: ${breed.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Saves a batch of queen breeds locally.
  Future<void> saveQueenBreedsBatch(List<QueenBreed> breeds) async {
    try {
      final Map<String, Map<String, dynamic>> batchData = {};
      for (final breed in breeds) {
        String? imageName = breed.imageName;
        final appDir = await getApplicationDocumentsDirectory();
        final breedImagesDir = Directory('${appDir.path}/images/queen_breeds');
        if (imageName == null) {
          final files = breedImagesDir.existsSync()
              ? breedImagesDir.listSync().whereType<File>().where((f) => f.path.contains(breed.id)).toList()
              : [];
          for (final file in files) {
            try {
              await file.delete();
            } catch (_) {}
          }
        } else if (p.basename(imageName) != imageName) {
          if (!await breedImagesDir.exists()) {
            await breedImagesDir.create(recursive: true);
          }
          final fileName = '${breed.id}.jpg';
          final localFile = File('${breedImagesDir.path}/$fileName');
          if (await localFile.exists()) {
            await localFile.delete();
          }
          await File(breed.imageName!).copy(localFile.path);
          imageName = fileName;
        }
        batchData[breed.id] = breed.copyWith(imageName: () => imageName).toMap();
      }
      await _box.putAll(batchData);
      Logger.i('Saved ${breeds.length} queen breeds in batch', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save queen breeds batch', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a queen breed to Firestore and Firebase Storage (only if local).
  Future<void> syncToFirestore(QueenBreed breed, String userId) async {
    try {
      if (!breed.isLocal) {
        Logger.i('Skipping sync - not a local breed: ${breed.id}', tag: _tag);
        return;
      }
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('queen_breeds');
      if (breed.imageName != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = '${appDir.path}/images/queen_breeds/${breed.imageName}';
        final file = File(localPath);
        if (await file.exists()) {
          final ref = storageRef.child(breed.imageName!);
          await ref.putFile(file);
        }
      } else {
        try {
            final all = await storageRef.listAll();
            for (final item in all.items) {
              if (item.name.contains(breed.id)) {
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
      final breedToSync = breed.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('queen_breeds')
          .doc(breed.id);
      await docRef.set(breedToSync.toMap(), SetOptions(merge: true));
      await saveQueenBreed(breedToSync);
      Logger.i('Synced queen breed to Firestore: ${breed.id}', tag: _tag);
    } catch (e) {
      final failedBreed = breed.copyWith(syncStatus: () => SyncStatus.failed);
      await saveQueenBreed(failedBreed);
      Logger.e('Failed to sync queen breed to Firestore: ${breed.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Saves a user-edited breed locally and marks it as local.
  Future<void> saveUserEditedBreed(QueenBreed breed) async {
    try {
      final editedBreed = breed.copyWith(
        isLocal: () => true,
        updatedAt: () => DateTime.now(),
      );
      await saveQueenBreed(editedBreed);
      Logger.i('Saved user-edited breed: ${breed.name}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save user-edited breed: ${breed.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs queen breeds from Firestore to local storage.
  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('queen_breeds');
      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final firestoreBreed = QueenBreed.fromMap(doc.data());
        final localBreed = await getQueenBreedById(doc.id);
        if (firestoreBreed.imageName != null && firestoreBreed.imageName!.isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance
                .ref()
                .child('users')
                .child(userId)
                .child('queen_breeds')
                .child(firestoreBreed.imageName!);
            final appDir = await getApplicationDocumentsDirectory();
            final breedImagesDir = Directory('${appDir.path}/images/queen_breeds');
            if (!await breedImagesDir.exists()) {
              await breedImagesDir.create(recursive: true);
            }
            final localFile = File('${breedImagesDir.path}/${firestoreBreed.imageName!}');
            await ref.writeToFile(localFile);
          } catch (e) {
            Logger.e('Failed to download image for queen breed ${firestoreBreed.id}', tag: _tag, error: e);
          }
        }
        if (localBreed == null ||
            firestoreBreed.updatedAt.isAfter(localBreed.updatedAt) ||
            (firestoreBreed.updatedAt.isAtSameMomentAs(localBreed.updatedAt) &&
             firestoreBreed.serverVersion > localBreed.serverVersion)) {
          final syncedBreed = firestoreBreed.copyWith(
            syncStatus: () => SyncStatus.synced,
            lastSyncedAt: () => DateTime.now(),
            serverVersion: () => firestoreBreed.serverVersion + 1,
          );
          await saveQueenBreed(syncedBreed);
        }
      }
      Logger.i('Synced ${snapshot.docs.length} queen breeds from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a batch of queen breeds to Firestore (only local breeds).
  Future<void> syncBatchToFirestore(List<QueenBreed> breeds, String userId) async {
    try {
      final batch = _firestore.batch();
      final breedsToUpdate = <QueenBreed>[];
      for (final breed in breeds) {
        if (!breed.isLocal) continue;
        final breedToSync = breed.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );
        final docRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('queen_breeds')
            .doc(breed.id);
        batch.set(docRef, breedToSync.toMap(), SetOptions(merge: true));
        breedsToUpdate.add(breedToSync);
      }
      if (breedsToUpdate.isNotEmpty) {
        await batch.commit();
        await saveQueenBreedsBatch(breedsToUpdate);
      }
      Logger.i('Synced ${breedsToUpdate.length} queen breeds to Firestore in batch', tag: _tag);
    } catch (e) {
      final failedBreeds = breeds.where((b) => b.isLocal).map((b) => b.copyWith(syncStatus: () => SyncStatus.failed)).toList();
      if (failedBreeds.isNotEmpty) {
        await saveQueenBreedsBatch(failedBreeds);
      }
      Logger.e('Failed to sync queen breeds batch to Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disposes the repository and closes the Hive box.
  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('QueenBreed repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose queen breed repository', tag: _tag, error: e);
    }
  }

  /// Loads initial queen breed data from assets for the given language.
  Future<void> loadInitialData(String language) async {
    try {
      final jsonString = await rootBundle.loadString('assets/initial/queen_breeds.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      final List<dynamic> breedData = data[language] ?? data['en'] ?? [];
      final now = DateTime.now();
      for (final breedJson in breedData) {
        final existing = await getQueenBreedById(breedJson['id']);
        if (existing == null) {
          final breedMap = Map<String, dynamic>.from(breedJson);
          breedMap['createdAt'] = now.toIso8601String();
          breedMap['updatedAt'] = now.toIso8601String();
          breedMap['deleted'] = false;
          breedMap['serverVersion'] = 0;
          breedMap['syncStatus'] = 'pending';
          final breed = QueenBreed.fromMap(breedMap);
          await saveQueenBreed(breed);
        }
      }
      Logger.i('Loaded ${breedData.length} initial queen breeds for language: $language', tag: _tag);
    } catch (e) {
      Logger.e('Failed to load initial queen breed data', tag: _tag, error: e);
    }
  }
}