import 'dart:io';
import 'package:hive_ce/hive.dart' as hive_ce;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../shared.dart';

class TransactionRepository {
  static const String _boxName = 'transactions';
  static const String _autocompleteBoxName = 'transaction_autocomplete';
  static const String _sourcesKey = 'sources';
  static const String _targetsKey = 'targets';
  static const String _tag = 'TransactionRepository';
  
  late hive_ce.Box<Map<dynamic, dynamic>> _box;
  late hive_ce.Box<List<dynamic>> _autocompleteBox;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<Map<dynamic, dynamic>>(_boxName);
      _autocompleteBox = await hive_ce.Hive.openBox<List<dynamic>>(_autocompleteBoxName);
      
      // Initialize with empty lists if they don't exist
      if (!_autocompleteBox.containsKey(_sourcesKey)) {
        await _autocompleteBox.put(_sourcesKey, <String>[]);
      }
      if (!_autocompleteBox.containsKey(_targetsKey)) {
        await _autocompleteBox.put(_targetsKey, <String>[]);
      }
      
      Logger.i('Transaction repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize transaction repository', tag: _tag, error: e);
      rethrow;
    }
  }

  // Autocomplete methods
  Future<List<String>> getSources() async {
    try {
      final sources = _autocompleteBox.get(_sourcesKey, defaultValue: <String>[]);
      return List<String>.from(sources ?? []);
    } catch (e) {
      Logger.e('Failed to get sources', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<String>> getTargets() async {
    try {
      final targets = _autocompleteBox.get(_targetsKey, defaultValue: <String>[]);
      return List<String>.from(targets ?? []);
    } catch (e) {
      Logger.e('Failed to get targets', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<String>> searchSources(String query) async {
    try {
      final sources = await getSources();
      if (query.trim().isEmpty) return sources;
      
      final lowercaseQuery = query.toLowerCase();
      return sources.where((source) => 
        source.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      Logger.e('Failed to search sources with query: $query', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<String>> searchTargets(String query) async {
    try {
      final targets = await getTargets();
      if (query.trim().isEmpty) return targets;
      
      final lowercaseQuery = query.toLowerCase();
      return targets.where((target) => 
        target.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      Logger.e('Failed to search targets with query: $query', tag: _tag, error: e);
      return [];
    }
  }

  Future<void> _addSource(String source) async {
    if (source.trim().isEmpty) return;
    
    try {
      final sources = await getSources();
      final trimmedSource = source.trim();
      
      if (!sources.any((s) => s.toLowerCase() == trimmedSource.toLowerCase())) {
        sources.add(trimmedSource);
        sources.sort();
        await _autocompleteBox.put(_sourcesKey, sources);
        Logger.d('Added new source: $trimmedSource', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to add source: $source', tag: _tag, error: e);
    }
  }

  Future<void> _addTarget(String target) async {
    if (target.trim().isEmpty) return;
    
    try {
      final targets = await getTargets();
      final trimmedTarget = target.trim();
      
      if (!targets.any((t) => t.toLowerCase() == trimmedTarget.toLowerCase())) {
        targets.add(trimmedTarget);
        targets.sort();
        await _autocompleteBox.put(_targetsKey, targets);
        Logger.d('Added new target: $trimmedTarget', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to add target: $target', tag: _tag, error: e);
    }
  }

  Future<List<StorageTransaction>> getAllTransactions({int limit = 100}) async {
    try {
      final transactions = <StorageTransaction>[];
      
      final values = _box.values.toList();
      values.sort((a, b) {
        final aDate = DateTime.parse(a['date']).millisecondsSinceEpoch;
        final bDate = DateTime.parse(b['date']).millisecondsSinceEpoch;
        return bDate.compareTo(aDate); // Most recent first
      });
      
      final limitedValues = values.take(limit).toList();
      
      for (final data in limitedValues) {
        final transaction = StorageTransaction.fromMap(Map<String, dynamic>.from(data));
        if (!transaction.deleted) {
          transactions.add(transaction);
        }
      }
      
      return transactions;
    } catch (e) {
      Logger.e('Failed to get transactions', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<StorageTransaction>> getTransactionsByApiary(String apiaryId) async {
    try {
      final transactions = <StorageTransaction>[];
      
      for (final data in _box.values) {
        final transaction = StorageTransaction.fromMap(Map<String, dynamic>.from(data));
        if (!transaction.deleted && transaction.apiaryId == apiaryId) {
          transactions.add(transaction);
        }
      }
      
      transactions.sort((a, b) => b.date.compareTo(a.date));
      return transactions;
    } catch (e) {
      Logger.e('Failed to get transactions for apiary: $apiaryId', tag: _tag, error: e);
      return [];
    }
  }

  Future<StorageTransaction?> getTransaction(String id) async {
    try {
      final data = _box.get(id);
      if (data != null) {
        final transaction = StorageTransaction.fromMap(Map<String, dynamic>.from(data));
        return transaction.deleted ? null : transaction;
      }
      return null;
    } catch (e) {
      Logger.e('Failed to get transaction: $id', tag: _tag, error: e);
      return null;
    }
  }

  Future<void> saveTransaction(StorageTransaction transaction) async {
    try {
      String? receiptImageName = transaction.receiptImageName;
      final appDir = await getApplicationDocumentsDirectory();
      final receiptsDir = Directory('${appDir.path}/images/receipts');

      if (receiptImageName == null) {
        // Remove all possible receipt images for this transaction (by id)
        final files = receiptsDir.existsSync()
            ? receiptsDir.listSync().whereType<File>().where((f) => f.path.contains(transaction.id)).toList()
            : [];
        for (final file in files) {
          try {
            await file.delete();
          } catch (_) {}
        }
      } else if (p.basename(receiptImageName) != receiptImageName) {
        // If receiptImageName is a path (not just a filename), copy it locally and set receiptImageName
        if (!await receiptsDir.exists()) {
          await receiptsDir.create(recursive: true);
        }
        final fileName = '${transaction.id}.jpg';
        final localFile = File('${receiptsDir.path}/$fileName');

        if (await localFile.exists()) {
          await localFile.delete();
        }

        await File(transaction.receiptImageName!).copy(localFile.path);
        receiptImageName = fileName;
      }

      await _box.put(transaction.id, transaction.copyWith(receiptImageName: () => receiptImageName).toMap());
      
      // Add source/target to autocomplete if they exist
      if (transaction.sourceOrTarget != null && transaction.sourceOrTarget!.trim().isNotEmpty) {
        switch (transaction.type) {
          case TransactionType.expense:
            await _addSource(transaction.sourceOrTarget!);
            break;
          case TransactionType.income:
          case TransactionType.use:
            await _addTarget(transaction.sourceOrTarget!);
            break;
        }
      }
      
      Logger.i('Saved transaction: ${transaction.item}', tag: _tag);
    } catch (e) {
      Logger.e('Failed to save transaction: ${transaction.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> deleteTransaction(String id) async {
    try {
      final existing = await getTransaction(id);
      if (existing != null) {
        final deletedTransaction = existing.copyWith(
          deleted: true,
          updatedAt: DateTime.now(),
          syncStatus: SyncStatus.pending,
        );
        await saveTransaction(deletedTransaction);
        Logger.i('Deleted transaction: ${existing.item}', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to delete transaction: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncToFirestore(StorageTransaction transaction, String userId) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users')
          .child(userId)
          .child('receipts');

      if (transaction.receiptImageName != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final localPath = '${appDir.path}/images/receipts/${transaction.receiptImageName}';
        final file = File(localPath);
        if (await file.exists()) {
          final ref = storageRef.child(transaction.receiptImageName!);
          await ref.putFile(file);
        }
      } else {
        // Delete receipt image from Firebase Storage if receiptImageName is null
        final all = await storageRef.listAll();
        for (final item in all.items) {
          if (item.name.contains(transaction.id)) {
            try {
              await item.delete();
            } catch (_) {}
          }
        }
      }

      // Update sync metadata BEFORE sending to Firestore
      final transactionToSync = transaction.copyWith(
        syncStatus: SyncStatus.synced,
        lastSyncedAt: DateTime.now(),
      );

      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id);

      await docRef.set(transactionToSync.toMap(), SetOptions(merge: true));

      // Save the updated version locally
      await saveTransaction(transactionToSync);

      Logger.i('Synced transaction to Firestore: ${transaction.id}', tag: _tag);
    } catch (e) {
      // Update sync status to failed
      final failedTransaction = transaction.copyWith(syncStatus: SyncStatus.failed);
      await saveTransaction(failedTransaction);

      Logger.e('Failed to sync transaction to Firestore: ${transaction.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncFromFirestore(String userId, {DateTime? lastSyncTime}) async {
    try {
      Query<Map<String, dynamic>> query = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions');

      if (lastSyncTime != null) {
        query = query.where(
          'lastSyncedAt', isGreaterThan: lastSyncTime.toIso8601String(),
        );
      }

      final snapshot = await query.get();

      for (final doc in snapshot.docs) {
        final firestoreTransaction = StorageTransaction.fromMap(doc.data());
        
        if (firestoreTransaction.receiptImageName != null && firestoreTransaction.receiptImageName!.isNotEmpty) {
          try {
            final ref = FirebaseStorage.instance
                .ref()
                .child('users')
                .child(userId)
                .child('receipts')
                .child(firestoreTransaction.receiptImageName!);
            final appDir = await getApplicationDocumentsDirectory();
            final receiptsDir = Directory('${appDir.path}/images/receipts');
            if (!await receiptsDir.exists()) {
              await receiptsDir.create(recursive: true);
            }
            final localFile = File('${receiptsDir.path}/${firestoreTransaction.receiptImageName!}');
            await ref.writeToFile(localFile);
          } catch (e) {
            Logger.e('Failed to download receipt for transaction ${firestoreTransaction.id}', tag: _tag, error: e);
          }
        }
        
        final syncedTransaction = firestoreTransaction.copyWith(
          syncStatus: SyncStatus.synced,
          lastSyncedAt: DateTime.now(),
        );
        
        await saveTransaction(syncedTransaction);
      }

      Logger.i('Synced ${snapshot.docs.length} transactions from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync transactions from Firestore', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> dispose() async {
    try {
      await _box.close();
      await _autocompleteBox.close();
      Logger.i('StorageTransaction repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose transaction repository', tag: _tag, error: e);
    }
  }
}
