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

  Future<void> removeFromStorage({
    required String group,
    required String item,
    String? variant,
    double amount = 1.0,
    String? reason,
    String? apiaryId,
  }) async {
    try {
      final transaction = StorageTransaction(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
        group: group,
        item: item,
        variant: variant,
        amount: amount,
        type: TransactionType.remove,
        sourceOrTarget: reason,
        date: DateTime.now(),
        apiaryId: apiaryId,
        affectsStorage: true,
      );
      await saveTransaction(transaction);
      Logger.i('Removed from storage: $group/$item${variant != null ? '/$variant' : ''} (amount: $amount)', tag: _tag);
    } catch (e) {
      Logger.e('Failed to remove from storage: $group/$item', tag: _tag, error: e);
    }
  }

  Future<void> saveTransaction(StorageTransaction transaction) async {
    final existing = await _transactionRepository.getTransaction(transaction.id);
    await _transactionRepository.saveTransaction(transaction);
    if (transaction.affectsStorage) {
      await _updateStorageFromTransaction(transaction, existing);
    }
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
      if (existing.affectsStorage) {
        await _reverseStorageFromTransaction(existing);
      }
      await _transactionRepository.deleteTransaction(id);
      await _historyService.logEntityDelete(
        entityId: id,
        entityType: 'transaction',
        entityName: '${existing.item} (${existing.type.name})',
      );
      await _syncTransaction(existing);
    }
  }

  Future<List<StorageTransaction>> getAllTransactions({int limit = 100}) async {
    return await _transactionRepository.getAllTransactions(limit: limit);
  }

  Future<List<StorageTransaction>> getTransactionsByApiary(String apiaryId) async {
    return await _transactionRepository.getTransactionsByApiary(apiaryId);
  }

  Future<void> _updateStorageFromTransaction(StorageTransaction transaction, StorageTransaction? existing) async {
    if (existing != null && existing.affectsStorage) {
      await _reverseStorageFromTransaction(existing);
    }
    StorageItem? storageItem = await _storageRepository.findStorageItem(
      group: transaction.group,
      item: transaction.item,
      variant: transaction.variant,
    );
    double newAmount;
    if (storageItem != null) {
      newAmount = storageItem.currentAmount + _getStorageAmountChange(transaction);
    } else {
      newAmount = _getStorageAmountChange(transaction);
      if (newAmount < 0) newAmount = 0;
      storageItem = StorageItem(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        group: transaction.group,
        item: transaction.item,
        variant: transaction.variant,
        currentAmount: 0,
      );
    }
    final updatedStorageItem = storageItem.copyWith(
      currentAmount: () => newAmount,
      updatedAt: () => DateTime.now(),
      syncStatus: () => SyncStatus.pending,
    );
    await _storageRepository.saveStorageItem(updatedStorageItem);
    await _syncStorageItem(updatedStorageItem);
    if (transaction.storageItemId != updatedStorageItem.id) {
      final updatedTransaction = transaction.copyWith(
        storageItemId: () => updatedStorageItem.id,
        updatedAt: () => DateTime.now(),
        syncStatus: () => SyncStatus.pending,
      );
      await _transactionRepository.saveTransaction(updatedTransaction);
    }
    Logger.i('Updated storage: ${transaction.item} -> $newAmount', tag: _tag);
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
        currentAmount: () => newAmount,
        updatedAt: () => DateTime.now(),
        syncStatus: () => SyncStatus.pending,
      );
      await _storageRepository.saveStorageItem(updatedStorageItem);
      Logger.i('Reversed storage: ${transaction.item} -> $newAmount', tag: _tag);
    }
  }

  double _getStorageAmountChange(StorageTransaction transaction) {
    switch (transaction.type) {
      case TransactionType.expense:
        return transaction.amount;
      case TransactionType.income:
        return -transaction.amount;
      case TransactionType.use:
        return -transaction.amount;
      case TransactionType.remove:
        return -transaction.amount;
    }
  }

  Future<void> _syncStorageItem(StorageItem item) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      _storageRepository.syncToFirestore(item, _userRepository.currentUser!.id).catchError((e) {
        Logger.e('Failed to sync storage item to Firestore', tag: _tag, error: e);
      });
    } else {
      Logger.d('Skipping storage item sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> _syncTransaction(StorageTransaction transaction) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      _transactionRepository.syncToFirestore(transaction, _userRepository.currentUser!.id).catchError((e) {
        Logger.e('Failed to sync transaction to Firestore', tag: _tag, error: e);
      });
    } else {
      Logger.d('Skipping transaction sync - not premium or not logged in', tag: _tag);
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

  Future<void> syncPendingToFirestore() async {
    if (!_userRepository.isPremium || _userRepository.currentUser == null) return;
    
    final userId = _userRepository.currentUser!.id;
    
    final storageItems = await getAllStorageItems();
    final pendingItems = storageItems.where((s) => s.syncStatus == SyncStatus.pending).toList();
    for (final item in pendingItems) {
      await _storageRepository.syncToFirestore(item, userId);
    }
    
    final transactions = await getAllTransactions();
    final pendingTransactions = transactions.where((t) => t.syncStatus == SyncStatus.pending).toList();
    for (final transaction in pendingTransactions) {
      await _transactionRepository.syncToFirestore(transaction, userId);
    }
  }

  Future<void> dispose() async {
    await _storageRepository.dispose();
    await _transactionRepository.dispose();
    Logger.i('Storage service disposed', tag: _tag);
  }
}