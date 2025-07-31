import 'package:apiarium/shared/shared.dart';

class SyncService {
  static const String _tag = 'SyncService';
  
  final QueenService _queenService;
  final HiveService _hiveService;
  final ApiaryService _apiaryService;
  final HistoryService _historyService;
  final InspectionService _inspectionService;
  final StorageService _storageService;
  final UserRepository _userRepository;
  
  bool _isSyncing = false;
  DateTime? _lastUploadSync;
  
  SyncService({
    required QueenService queenService,
    required HiveService hiveService,
    required ApiaryService apiaryService,
    required HistoryService historyService,
    required InspectionService inspectionService,
    required StorageService storageService,
    required UserRepository userRepository,
  }) : _queenService = queenService,
       _hiveService = hiveService,
       _apiaryService = apiaryService,
       _historyService = historyService,
       _inspectionService = inspectionService,
       _storageService = storageService,
       _userRepository = userRepository;
  
  bool get isSyncing => _isSyncing;
  
  Future<void> syncAll() async {
    if (_isSyncing || _userRepository.currentUser == null) return;
    
    _isSyncing = true;
    
    try {
      final lastSync = await _userRepository.getLastSyncTime();
      final now = DateTime.now();

      if (lastSync != null && now.difference(lastSync).inMinutes < 5) {
        return;
      }
      
      await _userRepository.syncUserProfile();
      
      if (_userRepository.isPremium) {
        // Order matters: sync parent entities before children
        await _apiaryService.syncFromFirestore();    // 1. Apiaries first
        await _queenService.syncFromFirestore();     // 2. Queens (breeds come with this)  
        await _hiveService.syncFromFirestore();      // 3. Hives (reference apiaries + queens)
        await _inspectionService.syncFromFirestore(); // 4. Inspections (reference hives)
        await _storageService.syncFromFirestore();   // 5. Storage (independent)
        await _historyService.syncFromFirestore();   // 6. History (references everything)
        
        await validateAllReferences();
      }
      
      await _userRepository.setLastSyncTime();
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> syncToFirestore() async {
    if (_isSyncing || _userRepository.currentUser == null || !_userRepository.isPremium) return;
    
    final now = DateTime.now();
    if (_lastUploadSync != null && now.difference(_lastUploadSync!).inMinutes < 5) {
      Logger.d('Upload sync skipped - synced recently', tag: _tag);
      return;
    }
    
    _isSyncing = true;
    
    try {
      // Order matters: sync parent entities before children
      await _apiaryService.syncPendingToFirestore();    // 1. Apiaries first
      await _queenService.syncPendingToFirestore();     // 2. Queens + breeds
      await _hiveService.syncPendingToFirestore();      // 3. Hives (reference apiaries + queens)
      await _inspectionService.syncPendingToFirestore(); // 4. Inspections (reference hives)  
      await _storageService.syncPendingToFirestore();   // 5. Storage (independent)
      await _historyService.syncPendingToFirestore();   // 6. History (references everything)
      
      _lastUploadSync = now;
      Logger.i('Upload sync completed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync to Firestore', tag: _tag, error: e);
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> syncBidirectional() async {
    if (_isSyncing || _userRepository.currentUser == null || !_userRepository.isPremium) return;
    
    try {
      await syncToFirestore();
      await syncAll();
    } catch (e) {
      Logger.e('Failed bidirectional sync', tag: _tag, error: e);
    }
  }

  Future<void> validateAllReferences() async {
    try {
      final apiaryIds = (await _apiaryService.getAllApiaries())
        .where((a) => !a.deleted)
        .map((a) => a.id)
        .toSet();
        
      final hiveIds = (await _hiveService.getAllHives())
        .where((h) => !h.deleted)
        .map((h) => h.id)
        .toSet();
      
      final queens = await _queenService.getAllQueens();
      int fixedQueenCount = 0;
      
      for (final queen in queens) {
        bool needsUpdate = false;
        Queen updatedQueen = queen;
        
        if (queen.hiveId != null && !hiveIds.contains(queen.hiveId)) {
          updatedQueen = updatedQueen.copyWith(
            hiveId: () => null,
            hiveName: () => null,
          );
          needsUpdate = true;
        }
        
        if (queen.apiaryId != null && !apiaryIds.contains(queen.apiaryId)) {
          updatedQueen = updatedQueen.copyWith(
            apiaryId: () => null,
            apiaryName: () => null,
            apiaryLocation: () => null,
          );
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          await _queenService.updateQueen(updatedQueen);
          fixedQueenCount++;
        }
      }
      
      final hives = await _hiveService.getAllHives();
      int fixedHiveCount = 0;
      
      for (final hive in hives) {
        bool needsUpdate = false;
        Hive updatedHive = hive;
        
        if (hive.apiaryId != null && !apiaryIds.contains(hive.apiaryId)) {
          updatedHive = updatedHive.copyWith(
            apiaryId: () => null,
            apiaryName: () => null,
            apiaryLocation: () => null,
          );
          needsUpdate = true;
        }
        
        if (hive.queenId != null && !queens.any((q) => q.id == hive.queenId && !q.deleted)) {
          updatedHive = updatedHive.copyWith(
            queenId: () => null,
            queenName: () => null,
            queenMarked: () => null,
            queenMarkColor: () => null,
            breed: () => null,
            queenBirthDate: () => null,
          );
          needsUpdate = true;
        }
        
        if (needsUpdate) {
          await _hiveService.updateHive(updatedHive);
          fixedHiveCount++;
        }
      }
      
      Logger.i('Reference validation complete: fixed $fixedQueenCount queens and $fixedHiveCount hives', tag: _tag);
    } catch (e) {
      Logger.e('Failed to validate references', tag: _tag, error: e);
    }
  }
}