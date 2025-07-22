import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../shared.dart';

class HiveService {
  static const String _tag = 'HiveService';
  static const Uuid _uuid = Uuid();
  
  final HiveRepository _hiveRepository;
  final HiveTypeRepository _hiveTypeRepository;
  final ApiaryRepository _apiaryRepository;
  final QueenRepository _queenRepository;
  final UserRepository _userRepository;
  final HistoryService _historyService;
  
  HiveService({
    required HiveRepository hiveRepository,
    required HiveTypeRepository hiveTypeRepository,
    required ApiaryRepository apiaryRepository,
    required QueenRepository queenRepository,
    required UserRepository userRepository,
    required HistoryService historyService,
  }) : _hiveRepository = hiveRepository, 
       _hiveTypeRepository = hiveTypeRepository,
       _apiaryRepository = apiaryRepository,
       _queenRepository = queenRepository,
       _userRepository = userRepository,
       _historyService = historyService;
  
  Future<void> initialize() async {
    await _hiveRepository.initialize();
    await _hiveTypeRepository.initialize();
    Logger.i('Hive service initialized', tag: _tag);
  }

  Future<List<Hive>> getAllHives() async {
    return await _hiveRepository.getAllHives();
  }

  Future<List<Hive>> getHivesByApiaryId(String? apiaryId) async {
    final hives = await _hiveRepository.getAllHives();
    return hives.where((h) => h.apiaryId == apiaryId).toList();
  }

  Future<List<Hive>> getActiveHives() async {
    final hives = await getAllHives();
    return hives.where((h) => h.status == HiveStatus.active).toList();
  }

  Future<List<Hive>> getHivesWithQueens() async {
    final hives = await getAllHives();
    return hives.where((h) => h.hasQueen).toList();
  }

  Future<Hive?> getHiveById(String id) async {
    return await _hiveRepository.getHiveById(id);
  }

  Future<Hive> updateHive(Hive hive) async {
    try {
      final oldHive = await getHiveById(hive.id);
      if (oldHive == null) {
        throw Exception('Hive not found: ${hive.id}');
      }

      var updatedHive = hive.copyWith(
        updatedAt: () => DateTime.now(),
        apiaryLocation: () => null,
        apiaryName: () => null,
        queenBirthDate: () => null,
        queenMarked: () => null,
        queenMarkColor: () => null,
        queenName: () => null,
        breed: () => null,
        lastTimeQueenSeen: () => null,
      );

      if (oldHive.apiaryId != null && oldHive.apiaryId != updatedHive.apiaryId) {
        await _updateApiary(oldHive.apiaryId!, null);
      }
      if (updatedHive.apiaryId != null) {
        final apiary = await _updateApiary(updatedHive.apiaryId!, updatedHive);
        updatedHive = updatedHive.copyWith(
          apiaryName: () => apiary?.name,
          apiaryLocation: () => apiary?.location,
        );
      }
      if (oldHive.queenId != null && oldHive.queenId != updatedHive.queenId) {
        await _updateQueen(oldHive.queenId!, null);
      }
      if (updatedHive.queenId != null) {
        final queen = await _updateQueen(updatedHive.queenId!, updatedHive);
        updatedHive = updatedHive.copyWith(
          queenName: () => queen?.name,
          breed: () => queen?.breedName,
          queenBirthDate: () => queen?.birthDate,
          queenMarked: () => queen?.marked,
          queenMarkColor: () => queen?.markColor,
          lastTimeQueenSeen: () => queen?.lastTimeSeen,
        );
      }
      
      await _hiveRepository.saveHive(updatedHive);
      Logger.i('Updated hive: ${updatedHive.name}', tag: _tag);
      
      // Log the update with entity name
      await _historyService.logEntityUpdate(
        entityId: updatedHive.id,
        entityType: 'hive',
        entityName: updatedHive.name,
        oldData: oldHive.toMap(),
        newData: updatedHive.toMap(),
      );
      
      await _syncHive(updatedHive);

      return updatedHive;
    } catch (e) {
      Logger.e('Failed to update hive: ${hive.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Hive> createHive({
    required String name,
    String? apiaryId,
    required HiveStatus status,
    required DateTime acquisitionDate,
    required String hiveTypeId,
    int? broodFrameCount,
    int? honeyFrameCount,
    int? boxCount,
    int? superBoxCount,
    int? framesPerBox,
    int? maxBroodFrameCount,
    int? maxHoneyFrameCount,
    int? maxBoxCount,
    int? maxSuperBoxCount,
    List<String>? accessories,
    int? currentBroodFrameCount,
    int? currentHoneyFrameCount,
    int? currentBoxCount,
    int? currentSuperBoxCount,
    String? queenId,
    String? imageUrl,
    Color? color,
    double? cost,
  }) async {
    try {
      final now = DateTime.now();

      final hiveType = await _hiveTypeRepository.getHiveTypeById(hiveTypeId);
      if (hiveType == null) {
        throw Exception('Hive type not found: $hiveTypeId');
      }

      final order = await _getNextHivePosition(apiaryId);

      var hive = Hive(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        name: name,
        apiaryId: apiaryId,
        status: status,
        acquisitionDate: acquisitionDate,
        imageUrl: imageUrl,
        order: order,
        color: color,
        hiveTypeId: hiveTypeId,
        hiveType: hiveType.name,
        material: hiveType.material,
        hasFrames: hiveType.hasFrames,
        broodFrameCount: broodFrameCount ?? hiveType.broodFrameCount,
        honeyFrameCount: honeyFrameCount ?? hiveType.honeyFrameCount,
        boxCount: boxCount ?? hiveType.boxCount,
        superBoxCount: superBoxCount ?? hiveType.superBoxCount,
        framesPerBox: framesPerBox ?? hiveType.framesPerBox,
        maxBroodFrameCount: maxBroodFrameCount ?? hiveType.maxBroodFrameCount,
        maxHoneyFrameCount: maxHoneyFrameCount ?? hiveType.maxHoneyFrameCount,
        maxBoxCount: maxBoxCount ?? hiveType.maxBoxCount,
        maxSuperBoxCount: maxSuperBoxCount ?? hiveType.maxSuperBoxCount,
        accessories: accessories ?? hiveType.accessories,
        currentBroodFrameCount: currentBroodFrameCount,
        currentHoneyFrameCount: currentHoneyFrameCount,
        currentBoxCount: currentBoxCount,
        currentSuperBoxCount: currentSuperBoxCount,
        cost: cost,
      );

      if (apiaryId != null) {
        final apiary = await _updateApiary(apiaryId, hive);
        hive = hive.copyWith(
          apiaryName: () => apiary?.name,
          apiaryLocation: () => apiary?.location,
        );
      }
      
      if (queenId != null) {
        final queen = await _updateQueen(queenId, hive);
        hive = hive.copyWith(
          queenName: () => queen?.name,
          breed: () => queen?.breedName,
          queenBirthDate: () => queen?.birthDate,
          queenMarked: () => queen?.marked,
          queenMarkColor: () => queen?.markColor,
          lastTimeQueenSeen: () => queen?.lastTimeSeen,
        );
      }

      await _hiveRepository.saveHive(hive);
      Logger.i('Created hive: ${hive.name}', tag: _tag);
      
      // Log the creation with entity name
      await _historyService.logEntityCreate(
        entityId: hive.id,
        entityType: 'hive',
        entityName: hive.name,
        entityData: hive.toMap(),
      );
      
      await _syncHive(hive);

      return hive;
    } catch (e) {
      Logger.e('Failed to create hive: $name', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<int> _getNextHivePosition(String? apiaryId) async {
    if (apiaryId == null) {
      final hives = await _hiveRepository.getAllHives();
      return hives.where((h) => h.apiaryId == null).length + 1;
    }

    final apiary = await _apiaryRepository.getApiaryById(apiaryId);
    if (apiary == null) {
      throw Exception('Apiary not found: $apiaryId');
    }

    return apiary.hiveCount + 1;
  }
  
  Future<void> deleteHive(String id) async {
    try {
      final hive = await getHiveById(id);
      if (hive == null) return;

      var deletedHive = hive.copyWith(
        deleted: () => true,
        updatedAt: () => DateTime.now(),
        apiaryLocation: () => null,
        apiaryName: () => null,
        queenBirthDate: () => null,
        queenMarked: () => null,
        queenMarkColor: () => null,
        queenName: () => null,
        breed: () => null,
        lastTimeQueenSeen: () => null,
      );

      if (hive.queenId != null) {
        await _updateQueen(hive.queenId!, null);
        deletedHive = deletedHive.copyWith(queenId: () => null);
      }
      
      if (hive.apiaryId != null) {
        await _updateApiary(hive.apiaryId!, null);
        deletedHive = deletedHive.copyWith(apiaryId: () => null);
      }

      await _hiveRepository.saveHive(deletedHive);
      Logger.i('Deleted hive: $id', tag: _tag);
      
      // Log the deletion with entity name
      await _historyService.logEntityDelete(
        entityId: hive.id,
        entityType: 'hive',
        entityName: hive.name,
      );
      
      await _syncHive(deletedHive);
    } catch (e) {
      Logger.e('Failed to delete hive: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Apiary?> _updateApiary(String apiaryId, Hive? hive) async {
    final apiary = await _apiaryRepository.getApiaryById(apiaryId);
    if (apiary == null) {
      Logger.w('Apiary not found: $apiaryId', tag: _tag);
      return null;
    }

    final updatedApiary = apiary.copyWith(
      hiveCount: () => apiary.hiveCount + (hive != null ? 1 : -1),
      activeHiveCount: () => apiary.activeHiveCount + (hive == null ? -1 : (hive.status == HiveStatus.active ? 1 : 0)),
      updatedAt: () => DateTime.now(),
    );

    await _apiaryRepository.saveApiary(updatedApiary);
    await _syncApiary(updatedApiary);

    return updatedApiary;
  }

  Future<Queen?> _updateQueen(String queenId, Hive? hive) async {
    final queen = await _queenRepository.getQueenById(queenId);
    if (queen == null) {
      Logger.w('Queen not found: $queenId', tag: _tag);
      return null;
    }
    
    if (hive != null && hive.queenId != null && hive.queenId != queen.id) {
      throw Exception('Hive already has a queen: ${hive.queenName}');
    }

    final updatedQueen = queen.copyWith(
      hiveId: () => hive?.id,
      hiveName: () => hive?.name,
      apiaryId: () => hive?.apiaryId,
      apiaryName: () => hive?.apiaryName,
      apiaryLocation: () => hive?.apiaryLocation,
      updatedAt: () => DateTime.now(),
    );
    
    await _queenRepository.saveQueen(updatedQueen);
    await _syncQueen(updatedQueen);

    return updatedQueen;
  }

  // HiveType Operations
  Future<List<HiveType>> getAllHiveTypes() async {
    return await _hiveTypeRepository.getAllHiveTypes();
  }

  Future<HiveType?> getHiveTypeById(String id) async {
    return await _hiveTypeRepository.getHiveTypeById(id);
  }

  Future<HiveType> createHiveType({
    required String name,
    String? manufacturer,
    required HiveMaterial material,
    required bool hasFrames,
    int? broodFrameCount,
    int? honeyFrameCount,
    String? frameStandard,
    int? boxCount,
    int? superBoxCount,
    int? framesPerBox,
    int? maxBroodFrameCount,
    int? maxHoneyFrameCount,
    int? maxBoxCount,
    int? maxSuperBoxCount,
    List<String>? accessories,
    String? country,
    bool isLocal = true,
    double? cost,
    String? imageName,
    IconData? icon,
  }) async {
    try {
      final now = DateTime.now();
      
      final hiveType = HiveType(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        name: name,
        manufacturer: manufacturer,
        material: material,
        hasFrames: hasFrames,
        broodFrameCount: broodFrameCount,
        honeyFrameCount: honeyFrameCount,
        frameStandard: frameStandard,
        boxCount: boxCount,
        superBoxCount: superBoxCount,
        framesPerBox: framesPerBox,
        maxBroodFrameCount: maxBroodFrameCount,
        maxHoneyFrameCount: maxHoneyFrameCount,
        maxBoxCount: maxBoxCount,
        maxSuperBoxCount: maxSuperBoxCount,
        accessories: accessories,
        country: country,
        isLocal: isLocal,
        cost: cost,
        imageName: imageName,
        icon: icon ?? Icons.home,
      );

      await _hiveTypeRepository.saveHiveType(hiveType);
      Logger.i('Created hive type: ${hiveType.name}', tag: _tag);
      
      // Log the creation with entity name
      await _historyService.logEntityCreate(
        entityId: hiveType.id,
        entityType: 'hiveType',
        entityName: hiveType.name,
        entityData: hiveType.toMap(),
      );
      
      await _syncHiveType(hiveType);
      
      return hiveType;
    } catch (e) {
      Logger.e('Failed to create hive type: $name', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<HiveType> updateHiveType(HiveType hiveType) async {
    try {
      final oldHiveType = await getHiveTypeById(hiveType.id);
      if (oldHiveType == null) {
        throw Exception('Hive type not found: ${hiveType.id}');
      }

      final updatedHiveType = hiveType.copyWith(updatedAt: () => DateTime.now());
      await _hiveTypeRepository.saveHiveType(updatedHiveType);
      Logger.i('Updated hive type: ${updatedHiveType.name}', tag: _tag);
      
      // Log the update with entity name
      await _historyService.logEntityUpdate(
        entityId: updatedHiveType.id,
        entityType: 'hiveType',
        entityName: updatedHiveType.name,
        oldData: oldHiveType.toMap(),
        newData: updatedHiveType.toMap(),
      );
      
      await _syncHiveType(updatedHiveType);
      
      return updatedHiveType;
    } catch (e) {
      Logger.e('Failed to update hive type: ${hiveType.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> deleteHiveType(String id) async {
    try {
      final hiveType = await getHiveTypeById(id);
      if (hiveType != null) {
        final deletedHiveType = hiveType.copyWith(
          deleted: () => true,
          updatedAt: () => DateTime.now(),
        );
        await _hiveTypeRepository.saveHiveType(deletedHiveType);
        Logger.i('Deleted hive type: $id', tag: _tag);
        
        // Log the deletion with entity name
        await _historyService.logEntityDelete(
          entityId: hiveType.id,
          entityType: 'hiveType',
          entityName: hiveType.name,
        );
        
        await _syncHiveType(deletedHiveType);
      }
    } catch (e) {
      Logger.e('Failed to delete hive type: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> toggleHiveTypeStar(String id) async {
    try {
      final hiveType = await getHiveTypeById(id);
      if (hiveType != null) {
        final updatedHiveType = hiveType.copyWith(
          isStarred: () => !hiveType.isStarred,
          updatedAt: () => DateTime.now(),
        );
        await _hiveTypeRepository.saveHiveType(updatedHiveType);
        await _syncHiveType(updatedHiveType);
      }
    } catch (e) {
      Logger.e('Failed to toggle hive type star: $id', tag: _tag, error: e);
      rethrow;
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
      
      await _hiveRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      await _hiveTypeRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      
      Logger.i('Synced hives and hive types from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
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

  Future<void> _syncHiveType(HiveType hiveType) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _hiveTypeRepository.syncToFirestore(hiveType, userId);
      } catch (e) {
        Logger.e('Failed to sync hive type to Firestore', tag: _tag, error: e);
      }
    } else {
      Logger.d('Skipping hive type sync - not premium or not logged in', tag: _tag);
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

  Future<void> dispose() async {
    await _hiveRepository.dispose();
    await _hiveTypeRepository.dispose();
    Logger.i('Hive service disposed', tag: _tag);
  }

  Future<void> updateHivesBatch(List<Hive> hives, {bool deepUpdate = false}) async {
    try {
      await _hiveRepository.saveHivesBatch(hives);
      Logger.i('Updated ${hives.length} hives in batch', tag: _tag);
      
      if (deepUpdate) {
        final queensToUpdate = <Queen>[];
        final apiariesToUpdate = <Apiary>[];
        
        for (final hive in hives) {
          if (hive.queenId != null) {
            final queen = await _queenRepository.getQueenById(hive.queenId!);
            if (queen != null) {
              final updatedQueen = queen.copyWith(
                hiveName: () => hive.name,
                apiaryId: () => hive.apiaryId,
                apiaryName: () => hive.apiaryName,
                apiaryLocation: () => hive.apiaryLocation,
                updatedAt: () => DateTime.now(),
              );
              queensToUpdate.add(updatedQueen);
            }
          }
          
          if (hive.apiaryId != null) {
            final apiary = await _apiaryRepository.getApiaryById(hive.apiaryId!);
            if (apiary != null) {
              final allHives = await _hiveRepository.getAllHives();
              final apiaryHives = allHives.where((h) => h.apiaryId == hive.apiaryId).toList();
              final activeCount = apiaryHives.where((h) => h.status == HiveStatus.active).length;
              
              final updatedApiary = apiary.copyWith(
                hiveCount: () => apiaryHives.length,
                activeHiveCount: () => activeCount,
                updatedAt: () => DateTime.now(),
              );
              apiariesToUpdate.add(updatedApiary);
            }
          }
        }
        
        if (queensToUpdate.isNotEmpty) {
          await _queenRepository.saveQueensBatch(queensToUpdate);
          if (_userRepository.isPremium && _userRepository.currentUser != null) {
            final userId = _userRepository.currentUser!.id;
            await _queenRepository.syncBatchToFirestore(queensToUpdate, userId);
          }
        }
        if (apiariesToUpdate.isNotEmpty) {
          await _apiaryRepository.saveApiariesBatch(apiariesToUpdate);
          if (_userRepository.isPremium && _userRepository.currentUser != null) {
            final userId = _userRepository.currentUser!.id;
            await _apiaryRepository.syncBatchToFirestore(apiariesToUpdate, userId);
          }
        }
      }
      
      if (_userRepository.isPremium && _userRepository.currentUser != null) {
        final userId = _userRepository.currentUser!.id;
        await _hiveRepository.syncBatchToFirestore(hives, userId);
      }
    } catch (e) {
      Logger.e('Failed to update hives batch', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> updateHiveTypesBatch(List<HiveType> hiveTypes, {bool deepUpdate = false}) async {
    try {
      await _hiveTypeRepository.saveHiveTypesBatch(hiveTypes);
      Logger.i('Updated ${hiveTypes.length} hive types in batch', tag: _tag);
      
      if (deepUpdate) {
        final hivesToUpdate = <Hive>[];
        
        for (final hiveType in hiveTypes) {
          final hives = await _hiveRepository.getAllHives();
          final relatedHives = hives.where((h) => h.hiveTypeId == hiveType.id).toList();
          
          for (final hive in relatedHives) {
            final updatedHive = hive.copyWith(
              hiveType: () => hiveType.name,
              manufacturer: () => hiveType.manufacturer,
              material: () => hiveType.material,
              hasFrames: () => hiveType.hasFrames,
              updatedAt: () => DateTime.now(),
            );
            hivesToUpdate.add(updatedHive);
          }
        }
        
        if (hivesToUpdate.isNotEmpty) {
          await _hiveRepository.saveHivesBatch(hivesToUpdate);
          if (_userRepository.isPremium && _userRepository.currentUser != null) {
            final userId = _userRepository.currentUser!.id;
            await _hiveRepository.syncBatchToFirestore(hivesToUpdate, userId);
          }
        }
      }
      
      if (_userRepository.isPremium && _userRepository.currentUser != null) {
        final userId = _userRepository.currentUser!.id;
        await _hiveTypeRepository.syncBatchToFirestore(hiveTypes, userId);
      }
    } catch (e) {
      Logger.e('Failed to update hive types batch', tag: _tag, error: e);
      rethrow;
    }
  }
}