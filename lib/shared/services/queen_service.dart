import 'package:apiarium/shared/shared.dart';
import 'package:uuid/uuid.dart';

/// Service class that handles business logic related to queens and queen breeds,
/// including tracking changes through history logs.
class QueenService {
  final QueenRepository _queenRepository;
  final QueenBreedRepository _queenBreedRepository;
  final HistoryLogRepository _historyLogRepository;
  final Uuid _uuid = const Uuid();

  QueenService({
    required QueenRepository queenRepository,
    required QueenBreedRepository queenBreedRepository,
    required HistoryLogRepository historyLogRepository,
  })  : _queenRepository = queenRepository,
        _queenBreedRepository = queenBreedRepository,
        _historyLogRepository = historyLogRepository;

  /// Creates a unique group ID for grouping related history log entries
  String createGroupId() => _uuid.v4();

  // MARK: - Queen Query Operations

  /// Retrieves all queens with optional related data.
  /// 
  /// Parameters:
  /// - [includeApiary]: Whether to include apiary information
  /// - [includeHive]: Whether to include hive information
  Future<List<Queen>> getAllQueens({
    bool includeApiary = false,
    bool includeHive = false,
  }) async {
    return _queenRepository.getAllQueens(
      includeApiary: includeApiary,
      includeHive: includeHive,
    );
  }

  /// Gets a queen by ID with optional related data.
  /// 
  /// Parameters:
  /// - [id]: The ID of the queen to retrieve
  /// - [includeApiary]: Whether to include apiary information
  /// - [includeHive]: Whether to include hive information
  Future<Queen?> getQueenById(
    String id, {
    bool includeApiary = false,
    bool includeHive = false,
  }) async {
    return _queenRepository.getQueenById(
      id,
      includeApiary: includeApiary,
      includeHive: includeHive,
    );
  }

  /// Retrieves queens that aren't assigned to any hive.
  Future<List<Queen>> getUnassignedQueens() async {
    return _queenRepository.getUnassignedQueens();
  }

  /// Gets the total count of queens in the database.
  Future<int> getQueensCount() async {
    return _queenRepository.getQueensCount();
  }

  /// Gets the count of queens filtered by apiary.
  /// 
  /// Parameters:
  /// - [apiaryId]: Optional apiary ID to filter by
  Future<int> getQueensCountByApiary(String? apiaryId) async {
    return _queenRepository.getQueensCountByApiary(apiaryId);
  }

  /// Checks if there are queens that can be used as templates.
  Future<bool> canCreateDefaultQueen() async {
    return _queenRepository.canCreateDefaultQueen();
  }

  // MARK: - Queen CRUD Operations

  /// Inserts a new queen into the database and logs the action.
  /// 
  /// Parameters:
  /// - [queen]: The queen to insert
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<Queen> insertQueen(
    Queen queen, {
    String? groupId,
    bool skipHistoryLog = false,
  }) async {
    final createdQueen = await _queenRepository.insertQueen(queen);
    
    if (!skipHistoryLog) {
      await _logQueenAction(
        queenId: createdQueen.id,
        queenName: createdQueen.name,
        action: HistoryAction.create,
        description: 'Queen created: ${createdQueen.name}',
        groupId: groupId,
      );
    }
    
    return createdQueen;
  }

  /// Updates an existing queen in the database and logs the changes.
  /// 
  /// Parameters:
  /// - [queen]: The queen with updated values
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<Queen> updateQueen({
    required Queen queen,
    String? groupId,
    bool skipHistoryLog = false,
  }) async {
    final oldQueen = await _queenRepository.getQueenById(queen.id);
    if (oldQueen == null) {
      throw Exception('Queen not found for update: ${queen.id}');
    }
    
    final updatedQueen = await _queenRepository.updateQueen(queen);
    
    if (!skipHistoryLog) {
      final changes = oldQueen.toMap().differenceWith(updatedQueen.toMap());
      if (changes.isNotEmpty) {
        await _logQueenAction(
          queenId: updatedQueen.id,
          queenName: updatedQueen.name,
          action: HistoryAction.update,
          description: 'Queen updated: ${updatedQueen.name}',
          groupId: groupId,
          changes: changes,
        );
      }
    }
    
    return updatedQueen;
  }

  /// Deletes a queen (marks as deleted) and logs the action.
  /// 
  /// Parameters:
  /// - [queenId]: The ID of the queen to delete
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<bool> deleteQueen({
    required String queenId,
    String? groupId,
    bool skipHistoryLog = false,
  }) async {
    final queen = await _queenRepository.getQueenById(queenId);
    if (queen == null) {
      throw Exception('Queen not found for deletion: $queenId');
    }
    
    final result = await _queenRepository.deleteQueen(queenId);
    
    if (result && !skipHistoryLog) {
      await _logQueenAction(
        queenId: queenId,
        queenName: queen.name,
        action: HistoryAction.delete,
        description: 'Queen deleted: ${queen.name}',
        groupId: groupId,
      );
    }
    
    return result;
  }

  /// Creates a new queen with default or specified values and logs the action.
  /// 
  /// See [QueenRepository.createDefaultQueen] for parameter details.
  Future<Queen> createDefaultQueen({
    String? breedId,
    String name = 'New Queen',
    DateTime? birthDate,
    QueenSource? source,
    bool? marked,
    String? markColorHex,
    QueenStatus? status,
    String? origin,
    String? groupId,
    bool skipHistoryLog = false,
  }) async {
    final queen = await _queenRepository.createDefaultQueen(
      breedId: breedId,
      name: name,
      birthDate: birthDate,
      source: source,
      marked: marked,
      markColorHex: markColorHex,
      status: status,
      origin: origin,
    );
    
    if (!skipHistoryLog) {
      await _logQueenAction(
        queenId: queen.id,
        queenName: queen.name,
        action: HistoryAction.create,
        description: 'Default queen created: ${queen.name}',
        groupId: groupId,
      );
    }
    
    return queen;
  }

  // MARK: - Queen Breed Operations

  /// Gets all queen breeds.
  Future<List<QueenBreed>> getAllBreeds() async {
    return _queenBreedRepository.getAllBreeds();
  }

  /// Gets a queen breed by ID.
  /// 
  /// Parameters:
  /// - [id]: The ID of the queen breed to retrieve
  Future<QueenBreed?> getBreedById(String id) async {
    return _queenBreedRepository.getBreedById(id);
  }

  /// Inserts a new queen breed and logs the action.
  /// 
  /// Parameters:
  /// - [breed]: The queen breed to insert
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<QueenBreed> insertBreed({
    required QueenBreed breed,
    String? groupId,
    bool skipHistoryLog = false,
  }) async {
    final createdBreed = await _queenBreedRepository.insertBreed(breed);
    
    if (!skipHistoryLog) {
      await _logBreedAction(
        breedId: createdBreed.id,
        breedName: createdBreed.name,
        action: HistoryAction.create,
        description: 'Queen breed created: ${createdBreed.name}',
        groupId: groupId,
      );
    }
    
    return createdBreed;
  }

  /// Updates a queen breed and logs the changes.
  /// 
  /// Parameters:
  /// - [breed]: The queen breed with updated values
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<QueenBreed> updateBreed({
    required QueenBreed breed,
    String? groupId,
    bool skipHistoryLog = false,
  }) async {
    final oldBreed = await _queenBreedRepository.getBreedById(breed.id);
    if (oldBreed == null) {
      throw Exception('Queen breed not found for update: ${breed.id}');
    }
    
    final updatedBreed = await _queenBreedRepository.updateBreed(breed);
    
    if (!skipHistoryLog) {
      final changes = oldBreed.toMap().differenceWith(updatedBreed.toMap());
      if (changes.isNotEmpty) {
        await _logBreedAction(
          breedId: updatedBreed.id,
          breedName: updatedBreed.name,
          action: HistoryAction.update,
          description: 'Queen breed updated: ${updatedBreed.name}',
          groupId: groupId,
          changes: changes,
        );
      }
    }
    
    return updatedBreed;
  }

  // MARK: - Private Helper Methods

  /// Helper method to log queen-related actions to history.
  Future<void> _logQueenAction({
    required String queenId,
    required String queenName,
    required HistoryAction action,
    required String description,
    String? groupId,
    Map<String, dynamic>? changes,
  }) async {
    await _historyLogRepository.insertHistoryLog(
      HistoryLog(
        id: _uuid.v4(),
        entityId: queenId,
        entityType: EntityType.queen,
        action: action,
        timestamp: DateTime.now(),
        description: description,
        groupId: groupId,
        changes: changes,
      ),
    );
  }

  /// Helper method to log queen breed-related actions to history.
  Future<void> _logBreedAction({
    required String breedId,
    required String breedName,
    required HistoryAction action,
    required String description,
    String? groupId,
    Map<String, dynamic>? changes,
  }) async {
    await _historyLogRepository.insertHistoryLog(
      HistoryLog(
        id: _uuid.v4(),
        entityId: breedId,
        entityType: EntityType.queenBreed,
        action: action,
        timestamp: DateTime.now(),
        description: description,
        groupId: groupId,
        changes: changes,
      ),
    );
  }
}
