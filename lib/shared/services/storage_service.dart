import 'package:uuid/uuid.dart';
import '../shared.dart';

class StorageService {
  static const String _tag = 'StorageService';
  static const Uuid _uuid = Uuid();
  
  final StorageRepository _storageRepository;
  final TransactionRepository _transactionRepository;
  final HistoryService _historyService;
  final UserRepository _userRepository;
  
  StorageService({
    required StorageRepository storageRepository,
    required TransactionRepository transactionRepository,
    required HistoryService historyService,
    required UserRepository userRepository,
  }) : _storageRepository = storageRepository,
       _transactionRepository = transactionRepository,
       _historyService = historyService,
       _userRepository = userRepository;
  
  Future<void> initialize() async {
    await _storageRepository.initialize();
    await _transactionRepository.initialize();
    Logger.i('Storage service initialized', tag: _tag);
  }

  // Storage Item methods
  Future<List<StorageItem>> getAllStorageItems() async {
    return await _storageRepository.getAllStorageItems();
  }

  Future<StorageItem?> getStorageItem(String id) async {
    return await _storageRepository.getStorageItem(id);
  }

  Future<void> saveStorageItem(StorageItem item) async {
    final existing = await _storageRepository.getStorageItem(item.id);
    
    if (existing == null) {
      await _storageRepository.saveStorageItem(item);
      await _historyService.logEntityCreate(
        entityId: item.id,
        entityType: 'storageItem',
        entityName: '${item.group}/${item.item}${item.variant != null ? '/${item.variant}' : ''}',
        entityData: item.toMap(),
      );
    } else {
      await _storageRepository.saveStorageItem(item);
      await _historyService.logEntityUpdate(
        entityId: item.id,
        entityType: 'storageItem',
        entityName: '${item.group}/${item.item}${item.variant != null ? '/${item.variant}' : ''}',
        oldData: existing.toMap(),
        newData: item.toMap(),
      );
    }

    await _syncStorageItem(item);
  }

  Future<void> deleteStorageItem(String id) async {
    final existing = await _storageRepository.getStorageItem(id);
    if (existing != null) {
      await _storageRepository.deleteStorageItem(id);
      await _historyService.logEntityDelete(
        entityId: id,
        entityType: 'storageItem',
        entityName: '${existing.group}/${existing.item}${existing.variant != null ? '/${existing.variant}' : ''}',
      );
    }
  }

  // StorageTransaction methods with automatic storage updates
  Future<void> saveTransaction(StorageTransaction transaction) async {
    final existing = await _transactionRepository.getTransaction(transaction.id);
    
    // Save transaction first
    await _transactionRepository.saveTransaction(transaction);
    
    // Update storage if needed
    if (transaction.affectsStorage) {
      await _updateStorageFromTransaction(transaction, existing);
    }

    // Log to history
    if (existing == null) {
      await _historyService.logEntityCreate(
        entityId: transaction.id,
        entityType: 'transaction',
        entityName: '${transaction.item} (${transaction.type.name})',
        entityData: transaction.toMap(),
      );
    } else {
      await _historyService.logEntityUpdate(
        entityId: transaction.id,
        entityType: 'transaction',
        entityName: '${transaction.item} (${transaction.type.name})',
        oldData: existing.toMap(),
        newData: transaction.toMap(),
      );
    }

    await _syncTransaction(transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final existing = await _transactionRepository.getTransaction(id);
    if (existing != null) {
      // Reverse storage effects before deleting
      if (existing.affectsStorage) {
        await _reverseStorageFromTransaction(existing);
      }
      
      await _transactionRepository.deleteTransaction(id);
      await _historyService.logEntityDelete(
        entityId: id,
        entityType: 'transaction',
        entityName: '${existing.item} (${existing.type.name})',
      );
    }
  }

  Future<List<StorageTransaction>> getAllTransactions({int limit = 100}) async {
    return await _transactionRepository.getAllTransactions(limit: limit);
  }

  Future<List<StorageTransaction>> getTransactionsByApiary(String apiaryId) async {
    return await _transactionRepository.getTransactionsByApiary(apiaryId);
  }

  // Private helper methods
  Future<void> _updateStorageFromTransaction(StorageTransaction transaction, StorageTransaction? existing) async {
    // If updating existing transaction, reverse old effects first
    if (existing != null && existing.affectsStorage) {
      await _reverseStorageFromTransaction(existing);
    }

    // Apply new transaction effects
    final storageItem = await _storageRepository.findStorageItem(
      group: transaction.group,
      item: transaction.item,
      variant: transaction.variant,
    );

    double newAmount;
    if (storageItem != null) {
      newAmount = storageItem.currentAmount + _getStorageAmountChange(transaction);
    } else {
      // Create new storage item if it doesn't exist
      newAmount = _getStorageAmountChange(transaction);
      if (newAmount < 0) newAmount = 0; // Don't allow negative initial amounts
    }

    final updatedStorageItem = (storageItem ?? StorageItem(
      id: _uuid.v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      group: transaction.group,
      item: transaction.item,
      variant: transaction.variant,
      currentAmount: 0,
    )).copyWith(
      currentAmount: newAmount,
      updatedAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    await _storageRepository.saveStorageItem(updatedStorageItem);
    Logger.i('Updated storage: ${transaction.item} -> ${newAmount}', tag: _tag);
  }

  Future<void> _reverseStorageFromTransaction(StorageTransaction transaction) async {
    final storageItem = await _storageRepository.findStorageItem(
      group: transaction.group,
      item: transaction.item,
      variant: transaction.variant,
    );

    if (storageItem != null) {
      final newAmount = storageItem.currentAmount - _getStorageAmountChange(transaction);
      final updatedStorageItem = storageItem.copyWith(
        currentAmount: newAmount,
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await _storageRepository.saveStorageItem(updatedStorageItem);
      Logger.i('Reversed storage: ${transaction.item} -> ${newAmount}', tag: _tag);
    }
  }

  double _getStorageAmountChange(StorageTransaction transaction) {
    switch (transaction.type) {
      case TransactionType.expense:
        return transaction.amount; // Adding to storage (purchase)
      case TransactionType.income:
        return -transaction.amount; // Removing from storage (sale)
      case TransactionType.use:
        return -transaction.amount; // Removing from storage (consumption)
    }
  }

  Future<void> _syncStorageItem(StorageItem item) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _storageRepository.syncToFirestore(item, userId);
      } catch (e) {
        Logger.e('Failed to sync storage item to Firestore', tag: _tag, error: e);
      }
    }
  }

  Future<void> _syncTransaction(StorageTransaction transaction) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _transactionRepository.syncToFirestore(transaction, userId);
      } catch (e) {
        Logger.e('Failed to sync transaction to Firestore', tag: _tag, error: e);
      }
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
      
      await _storageRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      await _transactionRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      
      Logger.i('Synced storage data from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync storage data from Firestore', tag: _tag, error: e);
    }
  }

  Future<void> dispose() async {
    await _storageRepository.dispose();
    await _transactionRepository.dispose();
    Logger.i('Storage service disposed', tag: _tag);
  }
}