import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';
import '../shared.dart';

class QueenService {
  static const String _tag = 'QueenService';
  static const Uuid _uuid = Uuid();
  
  final QueenRepository _queenRepository;
  final QueenBreedRepository _breedRepository;
  final HiveRepository _hiveRepository;
  final UserRepository _userRepository;
  final HistoryService _historyService;
  
  QueenService({
    required QueenRepository queenRepository,
    required QueenBreedRepository breedRepository,
    required HiveRepository hiveRepository,
    required UserRepository userRepository,
    required HistoryService historyService,
  }) : _queenRepository = queenRepository,
       _breedRepository = breedRepository,
       _hiveRepository = hiveRepository,
       _userRepository = userRepository,
       _historyService = historyService;
  
  Future<void> initialize() async {
    await _queenRepository.initialize();
    await _breedRepository.initialize();
    Logger.i('Queen service initialized', tag: _tag);
  }

  Future<List<Queen>> getAllQueens() async {
    return await _queenRepository.getAllQueens();
  }

  Future<List<Queen>> getUnassignedQueens() async {
    final queens = await getAllQueens();
    return queens.where((q) => q.hiveId == null && q.status == QueenStatus.active).toList();
  }

  Future<List<Queen>> getAssignedQueens() async {
    final queens = await getAllQueens();
    return queens.where((q) => q.hiveId != null && q.status == QueenStatus.active).toList();
  }

  Future<Queen?> getQueenById(String id) async {
    return await _queenRepository.getQueenById(id);
  }

  Future<Queen?> getQueenByHiveId(String hiveId) async {
    final queens = await getAllQueens();
    return queens.cast<Queen?>().firstWhere(
      (q) => q?.hiveId == hiveId && q?.status == QueenStatus.active,
      orElse: () => null,
    );
  }

  Future<Queen> createQueen({
    required String name,
    required DateTime birthDate,
    required String breedId,
    required QueenSource source,
    bool marked = false,
    Color? markColor,
    String? origin,
    QueenStatus status = QueenStatus.active,
    String? hiveId,
    double? cost,
  }) async {
    try {
      final now = DateTime.now();
      final breed = await _breedRepository.getQueenBreedById(breedId);
      
      if (breed == null) {
        throw Exception('Queen breed not found: $breedId');
      }

      var queen = Queen(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        name: name,
        birthDate: birthDate,
        source: source,
        marked: marked,
        markColor: markColor,
        status: status,
        origin: origin,
        cost: cost ?? breed.cost,
        breedId: breedId,
        breedName: breed.name,
        breedScientificName: breed.scientificName,
        breedOrigin: breed.origin,
      );

      // Update hive if queen is assigned to one
      if (hiveId != null) {
        final hive = await _updateHive(hiveId, queen);
        queen = queen.copyWith(
          hiveId: () => hive?.id,
          hiveName: () => hive?.name,
          apiaryId: () => hive?.apiaryId,
          apiaryName: () => hive?.apiaryName,
          apiaryLocation: () => hive?.apiaryLocation,
        );
      }

      await _queenRepository.saveQueen(queen);
      Logger.i('Created queen: ${queen.name}', tag: _tag);
      
      // Log the creation with entity name
      await _historyService.logEntityCreate(
        entityId: queen.id,
        entityType: 'queen',
        entityName: queen.name,
        entityData: queen.toMap(),
      );
      
      await _syncQueen(queen);
      
      return queen;
    } catch (e) {
      Logger.e('Failed to create queen: $name', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Queen> updateQueen(Queen queen) async {
    try {
      final oldQueen = await _queenRepository.getQueenById(queen.id);
      if (oldQueen == null) {
        throw Exception('Queen not found: ${queen.id}');
      }

      var updatedQueen = queen.copyWith(
        updatedAt: () => DateTime.now(),
        hiveName: () => null,
        apiaryName: () => null,
        apiaryLocation: () => null,
      );

      if (oldQueen.hiveId != null && oldQueen.hiveId != updatedQueen.hiveId) {
        await _updateHive(oldQueen.hiveId!, null); 
      }
      
      if (updatedQueen.hiveId != null) {
        final hive = await _updateHive(updatedQueen.hiveId!, updatedQueen); 
        updatedQueen = updatedQueen.copyWith(
          hiveId: () => hive?.id,
          hiveName: () => hive?.name,
          apiaryId: () => hive?.apiaryId,
          apiaryName: () => hive?.apiaryName,
          apiaryLocation: () => hive?.apiaryLocation,
        );
      }

      await _queenRepository.saveQueen(updatedQueen);
      Logger.i('Updated queen: ${updatedQueen.name}', tag: _tag);
      
      // Log the update with entity name
      await _historyService.logEntityUpdate(
        entityId: updatedQueen.id,
        entityType: 'queen',
        entityName: updatedQueen.name,
        oldData: oldQueen.toMap(),
        newData: updatedQueen.toMap(),
      );
      
      await _syncQueen(updatedQueen);
      
      return updatedQueen;
    } catch (e) {
      Logger.e('Failed to update queen: ${queen.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> deleteQueen(String id) async {
    try {
      final queen = await getQueenById(id);
      if (queen != null) {

        Queen deletedQueen = queen.copyWith(
          deleted: () => true,
          updatedAt: () => DateTime.now(),
          hiveName: () => null,
          apiaryId: () => null,
          apiaryName: () => null,
          apiaryLocation: () => null,
        );

        if (queen.hiveId != null) {
          await _updateHive(queen.hiveId!, null);
          deletedQueen = deletedQueen.copyWith(
            hiveId: () => null,
          );
        }
        
        await _queenRepository.saveQueen(deletedQueen);
        Logger.i('Deleted queen: $id', tag: _tag);
        
        // Log the deletion with entity name
        await _historyService.logEntityDelete(
          entityId: queen.id,
          entityType: 'queen',
          entityName: queen.name,
        );
        
        await _syncQueen(deletedQueen);
      }
    } catch (e) {
      Logger.e('Failed to delete queen: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Hive?> _updateHive(String hiveId, Queen? queen) async {
    final hive = await _hiveRepository.getHiveById(hiveId);
    if (hive == null) {
      throw Exception('Hive not found: $hiveId');
    }

    if (queen != null && hive.queenId != null && hive.queenId != queen.id) {
      throw Exception('Hive already has a queen: ${hive.queenName}');
    }

    final updatedHive = hive.copyWith(
      queenId: () => queen?.id,
      queenName: () => queen?.name,
      queenMarked: () => queen?.marked,
      queenMarkColor: () => queen?.markColor,
      breed: () => queen?.breedName,
      queenBirthDate: () => queen?.birthDate,
      lastTimeQueenSeen: () => queen?.lastTimeSeen,
      updatedAt: () => DateTime.now(),
    );

    await _hiveRepository.saveHive(updatedHive);
    await _syncHive(updatedHive);

    return updatedHive;
  }

  // Queen Breed Operations
  Future<List<QueenBreed>> getAllQueenBreeds() async {
    return await _breedRepository.getAllQueenBreeds();
  }

  Future<QueenBreed> createQueenBreed({
    required String name,
    String? scientificName,
    String? origin,
    String? country,
    bool isStarred = true,
    bool isLocal = true,
    int? honeyProductionRating,
    int? springDevelopmentRating,
    int? gentlenessRating,
    int? swarmingTendencyRating,
    int? winterHardinessRating,
    int? diseaseResistanceRating,
    int? heatToleranceRating,
    String? characteristics,
    String? imageName,
    double? cost,
  }) async {
    try {
      final now = DateTime.now();
      final breed = QueenBreed(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        name: name,
        scientificName: scientificName,
        origin: origin,
        country: country,
        isStarred: isStarred,
        isLocal: isLocal,
        honeyProductionRating: honeyProductionRating,
        springDevelopmentRating: springDevelopmentRating,
        gentlenessRating: gentlenessRating,
        swarmingTendencyRating: swarmingTendencyRating,
        winterHardinessRating: winterHardinessRating,
        diseaseResistanceRating: diseaseResistanceRating,
        heatToleranceRating: heatToleranceRating,
        characteristics: characteristics,
        imageName: imageName,
        cost: cost,
      );

      await _breedRepository.saveQueenBreed(breed);
      Logger.i('Created queen breed: ${breed.name}', tag: _tag);
      
      // Log the creation with entity name
      await _historyService.logEntityCreate(
        entityId: breed.id,
        entityType: 'queenBreed',
        entityName: breed.name,
        entityData: breed.toMap(),
      );
      
      await _syncBreed(breed);
      
      return breed;
    } catch (e) {
      Logger.e('Failed to create queen breed: $name', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<QueenBreed> updateQueenBreed(QueenBreed breed) async {
    try {
      final oldBreed = await _breedRepository.getQueenBreedById(breed.id);
      
      if (!breed.isLocal) {
        await _breedRepository.saveUserEditedBreed(breed);
      } else {
        final updatedBreed = breed.copyWith(updatedAt: () => DateTime.now());
        await _breedRepository.saveQueenBreed(updatedBreed);
      }
      
      Logger.i('Updated queen breed: ${breed.name}', tag: _tag);
      
      // Log the update if we have the old breed
      if (oldBreed != null) {
        await _historyService.logEntityUpdate(
          entityId: breed.id,
          entityType: 'queenBreed',
          entityName: breed.name,
          oldData: oldBreed.toMap(),
          newData: breed.toMap(),
        );
      }
      
      await _syncBreed(breed);
      
      return breed;
    } catch (e) {
      Logger.e('Failed to update queen breed: ${breed.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> toggleBreedStar(String breedId) async {
    try {
      final breed = await _breedRepository.getQueenBreedById(breedId);
      if (breed != null) {
        final updatedBreed = breed.copyWith(
          isStarred: () => !breed.isStarred,
          updatedAt: () => DateTime.now(),
        );
        
        if (!breed.isLocal) {
          await _breedRepository.saveUserEditedBreed(updatedBreed);
        } else {
          await _breedRepository.saveQueenBreed(updatedBreed);
        }
        
        await _syncBreed(updatedBreed);
      }
    } catch (e) {
      Logger.e('Failed to toggle breed star: $breedId', tag: _tag, error: e);
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
      final userCountry = _userRepository.currentUser!.country ?? 'global';
      final lastSync = await _userRepository.getLastSyncTime();
      
      await _queenRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      await _breedRepository.syncFromFirestore(userId, lastSyncTime: lastSync);
      await _breedRepository.syncPublicBreeds(userCountry);
      
      Logger.i('Synced queens and breeds from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
    }
  }
  Future<void> _syncQueen(Queen queen) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      // Fire and forget - don't await
      _queenRepository.syncToFirestore(queen, _userRepository.currentUser!.id).catchError((e) {
        Logger.e('Failed to sync queen to Firestore', tag: _tag, error: e);
      });
    } else {
      Logger.d('Skipping queen sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> _syncHive(Hive hive) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      // Fire and forget - don't await
      _hiveRepository.syncToFirestore(hive, _userRepository.currentUser!.id).catchError((e) {
        Logger.e('Failed to sync hive to Firestore', tag: _tag, error: e);
      });
    } else {
      Logger.d('Skipping hive sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> _syncBreed(QueenBreed breed) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      // Fire and forget - don't await
      _breedRepository.syncToFirestore(breed, _userRepository.currentUser!.id).catchError((e) {
        Logger.e('Failed to sync breed to Firestore', tag: _tag, error: e);
      });
    } else {
      Logger.d('Skipping breed sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> dispose() async {
    await _queenRepository.dispose();
    await _breedRepository.dispose();
    Logger.i('Queen service disposed', tag: _tag);
  }

  Future<void> updateQueensBatch(List<Queen> queens, {bool deepUpdate = false}) async {
    try {
      await _queenRepository.saveQueensBatch(queens);
      Logger.i('Updated ${queens.length} queens in batch', tag: _tag);
      
      if (deepUpdate) {
        final hivesToUpdate = <Hive>[];
        
        for (final queen in queens) {
          if (queen.hiveId != null) {
            final hive = await _hiveRepository.getHiveById(queen.hiveId!);
            if (hive != null) {
              final updatedHive = hive.copyWith(
                queenId: () => queen.id,
                queenName: () => queen.name,
                queenMarked: () => queen.marked,
                queenMarkColor: () => queen.markColor,
                breed: () => queen.breedName,
                queenBirthDate: () => queen.birthDate,
                lastTimeQueenSeen: () => queen.lastTimeSeen,
                updatedAt: () => DateTime.now(),
              );
              hivesToUpdate.add(updatedHive);
            }
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
        await _queenRepository.syncBatchToFirestore(queens, userId);
      }
    } catch (e) {
      Logger.e('Failed to update queens batch', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> updateQueenBreedsBatch(List<QueenBreed> breeds, {bool deepUpdate = false}) async {
    try {
      await _breedRepository.saveQueenBreedsBatch(breeds);
      Logger.i('Updated ${breeds.length} queen breeds in batch', tag: _tag);
      
      if (deepUpdate) {
        final queensToUpdate = <Queen>[];
        
        for (final breed in breeds) {
          final queens = await _queenRepository.getAllQueens();
          final relatedQueens = queens.where((q) => q.breedId == breed.id).toList();
          
          for (final queen in relatedQueens) {
            final updatedQueen = queen.copyWith(
              breedName: () => breed.name,
              breedScientificName: () => breed.scientificName,
              breedOrigin: () => breed.origin,
              updatedAt: () => DateTime.now(),
            );
            queensToUpdate.add(updatedQueen);
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
        await _breedRepository.syncBatchToFirestore(breeds, userId);
      }
    } catch (e) {
      Logger.e('Failed to update queen breeds batch', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncPendingToFirestore() async {
    if (!_userRepository.isPremium || _userRepository.currentUser == null) return;
    
    final userId = _userRepository.currentUser!.id;
    
    final queens = await getAllQueens();
    final pendingQueens = queens.where((q) => q.syncStatus == SyncStatus.pending).toList();
    for (final queen in pendingQueens) {
      await _queenRepository.syncToFirestore(queen, userId);
    }
    
    final breeds = await getAllQueenBreeds();
    final pendingBreeds = breeds.where((b) => b.syncStatus == SyncStatus.pending).toList();
    for (final breed in pendingBreeds) {
      await _breedRepository.syncToFirestore(breed, userId);
    }
  }
}