import 'dart:ui';
import 'package:uuid/uuid.dart';
import '../shared.dart';

class ApiaryService {
  static const String _tag = 'ApiaryService';
  static const Uuid _uuid = Uuid();

  final ApiaryRepository _apiaryRepository;
  final HiveRepository _hiveRepository;
  final QueenRepository _queenRepository;
  final UserRepository _userRepository;
  final HistoryService _historyService;

  ApiaryService({
    required ApiaryRepository apiaryRepository,
    required HiveRepository hiveRepository,
    required QueenRepository queenRepository,
    required UserRepository userRepository,
    required HistoryService historyService,
  }) : _apiaryRepository = apiaryRepository,
       _hiveRepository = hiveRepository,
       _queenRepository = queenRepository,
       _userRepository = userRepository,
       _historyService = historyService;

  Future<void> initialize() async {
    await _apiaryRepository.initialize();
    Logger.i('Apiary service initialized', tag: _tag);
  }

  Future<List<Apiary>> getAllApiaries() async {
    return await _apiaryRepository.getAllApiaries();
  }

  Future<Apiary?> getApiaryById(String id) async {
    return await _apiaryRepository.getApiaryById(id);
  }

  Future<Apiary> createApiary({
    required String name,
    String? description,
    String? location,
    String? imageName,
    double? latitude,
    double? longitude,
    bool isMigratory = false,
    Color? color,
    ApiaryStatus status = ApiaryStatus.active,
    List<Hive>? hives = const [],
  }) async {
    try {
      final now = DateTime.now();
      final apiaryId = _uuid.v4();
      final position = await _getNextApiaryPosition();

      final apiary = Apiary(
        id: apiaryId,
        createdAt: now,
        updatedAt: now,
        name: name,
        description: description,
        location: location,
        position: position,
        imageName: imageName,
        latitude: latitude,
        longitude: longitude,
        isMigratory: isMigratory,
        color: color,
        status: status,
      );

      await _apiaryRepository.saveApiary(apiary);
      await _updateHives(apiary, hives: hives);

      Logger.i('Created apiary: ${apiary.name}', tag: _tag);
      
      // Log the creation with entity name
      await _historyService.logEntityCreate(
        entityId: apiary.id,
        entityType: 'apiary',
        entityName: apiary.name,
        entityData: apiary.toMap(),
      );
      
      await _syncApiary(apiary);
      
      return apiary;
    } catch (e) {
      Logger.e('Failed to create apiary: $name', tag: _tag, error: e);
      rethrow;
    }
  }
  
  Future<int> _getNextApiaryPosition() async {
    return (await _apiaryRepository.getAllApiaries()).length + 1;
  }
  
  Future<Apiary> updateApiary(Apiary apiary) async {
    try {
      final oldApiary = await getApiaryById(apiary.id);
      if (oldApiary == null) {
        throw Exception('Apiary not found: ${apiary.id}');
      }

      final updatedApiary = apiary.copyWith(updatedAt: () => DateTime.now());
      await _apiaryRepository.saveApiary(updatedApiary);
      await _updateHives(updatedApiary);

      Logger.i('Updated apiary: ${updatedApiary.name}', tag: _tag);
      
      // Log the update with entity name
      await _historyService.logEntityUpdate(
        entityId: updatedApiary.id,
        entityType: 'apiary',
        entityName: updatedApiary.name,
        oldData: oldApiary.toMap(),
        newData: updatedApiary.toMap(),
      );
      
      await _syncApiary(updatedApiary);
      
      return updatedApiary;
    } catch (e) {
      Logger.e('Failed to update apiary: ${apiary.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> deleteApiary(String id) async {
    try {
      final apiary = await getApiaryById(id);
      if (apiary == null) return;

      final hives = await _hiveRepository.getAllHives()
          .then((hives) => hives.where((h) => h.apiaryId == apiary.id).toList());
      
      if (hives.isNotEmpty) {
        throw Exception('Cannot delete apiary with existing hives. Move or delete hives first.');
      }

      final deletedApiary = apiary.copyWith(
        deleted: () => true,
        updatedAt: () => DateTime.now(),
      );
      
      await _apiaryRepository.saveApiary(deletedApiary);
      await _syncApiary(deletedApiary);
      
      Logger.i('Deleted apiary: $id', tag: _tag);
      
      await _historyService.logEntityDelete(
        entityId: apiary.id,
        entityType: 'apiary',
        entityName: apiary.name,
      );
    } catch (e) {
      Logger.e('Failed to delete apiary: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> _updateHives(Apiary apiary, {List<Hive>? hives}) async {
    final hiveList = hives ?? await _hiveRepository.getAllHives()
        .then((hives) => hives.where((h) => h.apiaryId == apiary.id).toList()) ?? [];
    
    for (final hive in hiveList) {
      await _updateHive(apiary, hive);
    }
  }

  Future<void> _updateHive(Apiary apiary, Hive hive) async {
    final updatedHive = hive.copyWith(
      apiaryName: () => apiary.name,
      apiaryLocation: () => apiary.location,
      updatedAt: () => DateTime.now(),
    );
    
    await _hiveRepository.saveHive(updatedHive);
    await _syncHive(updatedHive);

    if (updatedHive.queenId != null) {
      final queen = await _queenRepository.getQueenById(updatedHive.queenId!);
      if (queen != null) {
        final updatedQueen = queen.copyWith(
          apiaryName: () => apiary.name,
          apiaryLocation: () => apiary.location,
          updatedAt: () => DateTime.now(),
        );
        await _queenRepository.saveQueen(updatedQueen);
        await _syncQueen(updatedQueen);
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
      
      await _apiaryRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      
      Logger.i('Synced apiaries from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
    }
  }

  Future<void> _syncApiary(Apiary apiary) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _apiaryRepository.syncToFirestore(apiary, userId);
      } catch (e) {
        Logger.e('Failed to sync apiary to Firestore', tag: _tag, error: e);
      }
    } else {
      Logger.d('Skipping apiary sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> _syncHive(Hive hive) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _hiveRepository.syncToFirestore(hive, userId);
      } catch (e) {
        Logger.e('Failed to sync hive to Firestore', tag: _tag, error: e);
      }
    } else {
      Logger.d('Skipping hive sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> _syncQueen(Queen queen) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _queenRepository.syncToFirestore(queen, userId);
      } catch (e) {
        Logger.e('Failed to sync queen to Firestore', tag: _tag, error: e);
      }
    } else {
      Logger.d('Skipping queen sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> dispose() async {
    await _apiaryRepository.dispose();
    Logger.i('Apiary service disposed', tag: _tag);
  }

  Future<void> updateApiariesBatch(List<Apiary> apiaries, {bool deepUpdate = false}) async {
    try {
      await _apiaryRepository.saveApiariesBatch(apiaries);
      Logger.i('Updated ${apiaries.length} apiaries in batch', tag: _tag);
      
      if (deepUpdate) {
        final hivesToUpdate = <Hive>[];
        final queensToUpdate = <Queen>[];
        
        for (final apiary in apiaries) {
          final hives = await _hiveRepository.getAllHives();
          final apiaryHives = hives.where((h) => h.apiaryId == apiary.id).toList();
          
          for (final hive in apiaryHives) {
            final updatedHive = hive.copyWith(
              apiaryName: () => apiary.name,
              apiaryLocation: () => apiary.location,
              updatedAt: () => DateTime.now(),
            );
            hivesToUpdate.add(updatedHive);
          }
          
          final queens = await _queenRepository.getAllQueens();
          final apiaryQueens = queens.where((q) => q.apiaryId == apiary.id).toList();
          
          for (final queen in apiaryQueens) {
            final updatedQueen = queen.copyWith(
              apiaryName: () => apiary.name,
              apiaryLocation: () => apiary.location,
              updatedAt: () => DateTime.now(),
            );
            queensToUpdate.add(updatedQueen);
          }
        }
        
        if (hivesToUpdate.isNotEmpty) {
          await _hiveRepository.saveHivesBatch(hivesToUpdate);
          if (_userRepository.isPremium && _userRepository.currentUser != null) {
            final userId = _userRepository.currentUser!.id;
            await _hiveRepository.syncBatchToFirestore(hivesToUpdate, userId);
          }
        }
        if (queensToUpdate.isNotEmpty) {
          await _queenRepository.saveQueensBatch(queensToUpdate);
          if (_userRepository.isPremium && _userRepository.currentUser != null) {
            final userId = _userRepository.currentUser!.id;
            await _queenRepository.syncBatchToFirestore(queensToUpdate, userId);
          }
        }
      }
      
      if (_userRepository.isPremium && _userRepository.currentUser != null) {
        final userId = _userRepository.currentUser!.id;
        await _apiaryRepository.syncBatchToFirestore(apiaries, userId);
      }
    } catch (e) {
      Logger.e('Failed to update apiaries batch', tag: _tag, error: e);
      rethrow;
    }
  }
}