import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../shared.dart';

class StorageRepository {
  static const String _boxName = 'storage_items';
  static const String _tag = 'StorageRepository';

  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Initializes the local Hive box for storage items.
  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      Logger.i('Storage repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize storage repository', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Returns all non-deleted storage items, sorted by group.
  Future<List<StorageItem>> getAllStorageItems() async {
    try {
      final items = <StorageItem>[];
      for (final data in _box.values) {
        final item = StorageItem.fromMap(Map<String, dynamic>.from(data));
        if (!item.deleted) {
          items.add(item);
        }
      }
      items.sort((a, b) => a.group.compareTo(b.group));
      return items;
    } catch (e) {
      Logger.e('Failed to get storage items', tag: _tag, error: e);
      return [];
    }
  }

  /// Gets a storage item by its ID.
  Future<StorageItem?> getStorageItem(String id) async {
    try {
      final data = _box.get(id);
      if (data != null) {
        final item = StorageItem.fromMap(Map<String, dynamic>.from(data));
        return item.deleted ? null : item;
      }
      return null;
    } catch (e) {
      Logger.e('Failed to get storage item: $id', tag: _tag, error: e);
      return null;
    }
  }

  /// Finds a storage item by group, item, and optional variant.
  Future<StorageItem?> findStorageItem({
    required String group,
    required String item,
    String? variant,
  }) async {
    try {
      for (final data in _box.values) {
        final storageItem = StorageItem.fromMap(Map<String, dynamic>.from(data));
        if (!storageItem.deleted &&
            storageItem.group == group &&
            storageItem.item == item &&
            storageItem.variant == variant) {
          return storageItem;
        }
      }
      return null;
    } catch (e) {
      Logger.e('Failed to find storage item: $group/$item/$variant', tag: _tag, error: e);
      return null;
    }
  }

  /// Saves a storage item locally.
  Future<void> saveStorageItem(StorageItem item) async {
    try {
      await _box.put(item.id, item.toMap());
      Logger.i('Saved storage item: ${item.item}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save storage item: ${item.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Marks a storage item as deleted.
  Future<void> deleteStorageItem(String id) async {
    try {
      final existing = await getStorageItem(id);
      if (existing != null) {
        final deletedItem = existing.copyWith(
          deleted: () => true,
          updatedAt: () => DateTime.now(),
          syncStatus: () => SyncStatus.pending,
        );
        await saveStorageItem(deletedItem);
        Logger.i('Deleted storage item: ${existing.item}', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to delete storage item: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs a single storage item to Firestore.
  Future<void> syncToFirestore(StorageItem item, String userId) async {
    try {
      final itemToSync = item.copyWith(
        syncStatus: () => SyncStatus.synced,
        lastSyncedAt: () => DateTime.now(),
      );
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('storage_items')
          .doc(item.id);
      await docRef.set(itemToSync.toMap(), SetOptions(merge: true));
      await saveStorageItem(itemToSync);
      Logger.i('Synced storage item to Firestore: ${item.id}', tag: _tag);
    } catch (e) {
      final failedItem = item.copyWith(syncStatus: () => SyncStatus.failed);
      await saveStorageItem(failedItem);
      Logger.e('Failed to sync storage item to Firestore: ${item.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Syncs storage items from Firestore to local storage.
  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('storage_items');
      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }
      final snapshot = await query.get();
      for (final doc in snapshot.docs) {
        final firestoreItem = StorageItem.fromMap(doc.data());
        final syncedItem = firestoreItem.copyWith(
          syncStatus: () => SyncStatus.synced,
          lastSyncedAt: () => DateTime.now(),
        );
        await saveStorageItem(syncedItem);
      }
      Logger.i('Synced ${snapshot.docs.length} storage items from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync storage items from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  /// Disposes the repository and closes the Hive box.
  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('Storage repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose storage repository', tag: _tag, error: e);
    }
  }
}