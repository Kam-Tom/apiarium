import 'package:apiarium/shared/domain/domain.dart';
import 'package:apiarium/shared/services/services.dart';
import 'package:apiarium/shared/utils/logger.dart';

class SyncService {
  static const String _tag = 'SyncService';
  
  final QueenService _queenService;
  final HiveService _hiveService;
  final ApiaryService _apiaryService;
  final UserRepository _userRepository;
  
  SyncService({
    required QueenService queenService,
    required HiveService hiveService,
    required ApiaryService apiaryService,
    required UserRepository userRepository,
  }) : _queenService = queenService,
       _hiveService = hiveService,
       _apiaryService = apiaryService,
       _userRepository = userRepository;
  
  Future<void> syncAll() async {
    if (!_userRepository.isPremium || _userRepository.currentUser == null) {
      Logger.w('Sync skipped - not premium or not logged in', tag: _tag);
      return;
    }
    
    try {
      // 1. First sync from Firestore to get latest data
      await _apiaryService.syncFromFirestore();
      await _hiveService.syncFromFirestore();
      await _queenService.syncFromFirestore();
      
      // 2. Validate references to fix any integrity issues
      await validateAllReferences();
      
      // 3. Sync local changes back to Firestore
      // (This would need implementation in services to sync pending items)
      
      // 4. Update last sync time
      await _userRepository.setLastSyncTime();
      
      Logger.i('Full sync completed successfully', tag: _tag);
    } catch (e) {
      Logger.e('Failed to complete full sync', tag: _tag, error: e);
    }
  }
  
  Future<void> validateAllReferences() async {
    try {
      // Collect all valid IDs
      final apiaryIds = (await _apiaryService.getAllApiaries())
        .where((a) => !a.deleted)
        .map((a) => a.id)
        .toSet();
        
      final hiveIds = (await _hiveService.getAllHives())
        .where((h) => !h.deleted)
        .map((h) => h.id)
        .toSet();
      
      // Validate queens
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
      
      // Validate hives
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