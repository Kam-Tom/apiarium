import 'package:apiarium/shared/shared.dart';
import 'package:uuid/uuid.dart';

/// Service class that handles business logic related to apiaries,
/// including tracking changes through history logs.
class ApiaryService {
  final ApiaryRepository _apiaryRepository;
  final HistoryLogRepository _historyLogRepository;
  final Uuid _uuid = const Uuid();
  
  ApiaryService({
    required ApiaryRepository apiaryRepository,
    required HistoryLogRepository historyLogRepository,
  }) : 
    _apiaryRepository = apiaryRepository,
    _historyLogRepository = historyLogRepository;
  
  /// Creates a unique group ID for grouping related history log entries
  String createGroupId() => _uuid.v4();

  // MARK: - Apiary Query Operations

  /// Retrieves all apiaries with optional related data.
  /// 
  /// Parameters:
  /// - [includeHives]: Whether to include hives for each apiary
  /// - [includeQueen]: Whether to include queen information for each hive
  Future<List<Apiary>> getAllApiaries({
    bool includeHives = false,
    bool includeQueen = false
  }) async {
    return _apiaryRepository.getApiaries(
      includeHives: includeHives,
      includeQueen: includeQueen
    );
  }
  
  /// Gets an apiary by ID with optional related data.
  /// 
  /// Parameters:
  /// - [id]: The ID of the apiary to retrieve
  /// - [includeHives]: Whether to include hives for the apiary
  /// - [includeQueen]: Whether to include queen information for each hive
  Future<Apiary?> getApiaryById(
    String id, {
    bool includeHives = false,
    bool includeQueen = false
  }) async {
    return _apiaryRepository.getApiary(
      id,
      includeHives: includeHives,
      includeQueen: includeQueen
    );
  }

  // MARK: - Apiary CRUD Operations
  
  /// Inserts a new apiary into the database and logs the action.
  /// 
  /// Parameters:
  /// - [apiary]: The apiary to insert
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<Apiary> insertApiary(
    Apiary apiary, {
    String? groupId,
    bool skipHistoryLog = false
  }) async {
    final createdApiary = await _apiaryRepository.insertApiary(apiary);
    
    if (!skipHistoryLog) {
      await _logApiaryAction(
        apiaryId: createdApiary.id,
        apiaryName: createdApiary.name,
        action: HistoryAction.create,
        description: 'Apiary created: ${createdApiary.name}',
        groupId: groupId,
      );
    }
    
    return createdApiary;
  }
  
  /// Updates an existing apiary in the database and logs the changes.
  /// 
  /// Parameters:
  /// - [apiary]: The apiary with updated values
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<Apiary> updateApiary({
    required Apiary apiary,
    String? groupId,
    bool skipHistoryLog = false
  }) async {
    final oldApiary = await _apiaryRepository.getApiaryById(apiary.id);
    if (oldApiary == null) {
      throw Exception('Apiary not found for update: ${apiary.id}');
    }
    
    final updatedApiary = await _apiaryRepository.updateApiary(apiary);
    
    if (!skipHistoryLog) {
      final changes = oldApiary.toMap().differenceWith(updatedApiary.toMap());
      if (changes.isNotEmpty) {
        await _logApiaryAction(
          apiaryId: updatedApiary.id,
          apiaryName: updatedApiary.name,
          action: HistoryAction.update,
          description: 'Apiary updated: ${updatedApiary.name}',
          groupId: groupId,
          changes: changes,
        );
      }
    }
    
    return updatedApiary;
  }
  
  /// Updates multiple apiaries in a batch operation and logs the action.
  /// 
  /// Parameters:
  /// - [apiaries]: The list of apiaries to update
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<List<Apiary>> updateApiariesBatch(
    List<Apiary> apiaries, {
    String? groupId,
    bool skipHistoryLog = false
  }) async {
    final updatedApiaries = await _apiaryRepository.updateApiariesBatch(apiaries);
    
    if (!skipHistoryLog) {
      await _logApiaryAction(
        apiaryId: 'batch',
        apiaryName: '',
        action: HistoryAction.updateBatch,
        description: 'Reorder apiaries',
        groupId: groupId,
      );
    }
    
    return updatedApiaries;
  }
  
  /// Deletes an apiary (marks as deleted) and logs the action.
  /// 
  /// Parameters:
  /// - [apiaryId]: The ID of the apiary to delete
  /// - [groupId]: Optional group ID for history logging
  /// - [skipHistoryLog]: If true, no history log will be created
  Future<bool> deleteApiary({
    required String apiaryId,
    String? groupId,
    bool skipHistoryLog = false
  }) async {
    final apiary = await _apiaryRepository.getApiaryById(apiaryId);
    if (apiary == null) {
      throw Exception('Apiary not found for deletion: $apiaryId');
    }
    
    final result = await _apiaryRepository.deleteApiary(apiaryId);
    
    if (result && !skipHistoryLog) {
      await _logApiaryAction(
        apiaryId: apiaryId,
        apiaryName: apiary.name,
        action: HistoryAction.delete,
        description: 'Apiary deleted: ${apiary.name}',
        groupId: groupId,
      );
    }
    
    return result;
  }

  /// Gets an apiary with its hives by ID.
  ///
  /// This is a convenience method specifically for the edit flow.
  /// 
  /// Parameters:
  /// - [id]: The ID of the apiary to retrieve
  /// - [includeQueen]: Whether to include queen information for hives
  Future<Apiary?> getApiaryWithHives(String id, {bool includeQueen = false}) async {
    return _apiaryRepository.getApiaryWithHives(id, includeQueen: includeQueen);
  }

  // MARK: - Private Helper Methods

  /// Helper method to log apiary-related actions to history.
  Future<void> _logApiaryAction({
    required String apiaryId,
    required String apiaryName,
    required HistoryAction action,
    required String description,
    String? groupId,
    Map<String, dynamic>? changes,
  }) async {
    await _historyLogRepository.insertHistoryLog(
      HistoryLog(
        id: _uuid.v4(),
        entityId: apiaryId,
        entityType: EntityType.apiary,
        action: action,
        timestamp: DateTime.now(),
        description: description,
        groupId: groupId,
        changes: changes,
      ),
    );
  }
}