// import 'dart:ui';

// import 'package:apiarium/shared/shared.dart';
// import 'package:uuid/uuid.dart';

// /// Service class that handles business logic related to hives and hive types,
// /// including tracking changes through history logs and sync.
// class HiveService {
//   final HiveRepository _hiveRepository;
//   final HiveTypeRepository _hiveTypeRepository;
//   final HistoryLogRepository _historyLogRepository;
//   final Uuid _uuid = const Uuid();

//   HiveService({
//     required HiveRepository hiveRepository,
//     required HiveTypeRepository hiveTypeRepository,
//     required HistoryLogRepository historyLogRepository,
//   }) : 
//     _hiveRepository = hiveRepository,
//     _hiveTypeRepository = hiveTypeRepository,
//     _historyLogRepository = historyLogRepository;

//   // MARK: - Hive Query Operations

//   /// Retrieves all hives with optional related data.
//   /// 
//   /// Parameters:
//   /// - [includeApiary]: Whether to include apiary information
//   /// - [includeQueen]: Whether to include queen and breed information
//   Future<List<Hive>> getAllHives({
//     bool includeApiary = false,
//     bool includeQueen = false,
//   }) async {
//     return _hiveRepository.getAllHives(
//       includeApiary: includeApiary,
//       includeQueen: includeQueen,
//     );
//   }

//   /// Gets a hive by ID with optional related data.
//   /// 
//   /// Parameters:
//   /// - [id]: The ID of the hive to retrieve
//   /// - [includeApiary]: Whether to include apiary information
//   /// - [includeQueen]: Whether to include queen and breed information
//   Future<Hive?> getHiveById(
//     String id, {
//     bool includeApiary = false,
//     bool includeQueen = false,
//   }) async {
//     return _hiveRepository.getHiveById(
//       id,
//       includeApiary: includeApiary,
//       includeQueen: includeQueen,
//     );
//   }

//   /// Retrieves hives belonging to a specific apiary.
//   /// 
//   /// Parameters:
//   /// - [apiaryId]: The ID of the apiary to filter hives by
//   /// - [includeQueen]: Whether to include queen information
//   Future<List<Hive>> getByApiaryId(
//     String apiaryId, {
//     bool includeQueen = false,
//   }) async {
//     return _hiveRepository.getByApiaryId(apiaryId, includeQueen: includeQueen);
//   }

//   /// Retrieves all hives that don't belong to any apiary.
//   /// 
//   /// Parameters:
//   /// - [includeQueen]: Whether to include queen information
//   Future<List<Hive>> getHivesWithoutApiary({
//     bool includeQueen = false,
//   }) async {
//     return _hiveRepository.getHivesWithoutApiary(includeQueen: includeQueen);
//   }

//   /// Checks if there are hives in the database that can be used as templates.
//   Future<bool> canCreateDefaultHive() async {
//     return _hiveRepository.canCreateDefaultHive();
//   }

//   // MARK: - Hive CRUD Operations

//   /// Inserts a new hive into the database and logs the action.
//   /// 
//   /// Parameters:
//   /// - [hive]: The hive to insert
//   /// - [groupId]: Optional group ID for history logging
//   /// - [skipHistoryLog]: If true, no history log will be created
//   Future<Hive> insertHive(
//     Hive hive, {
//     String? groupId,
//     bool skipHistoryLog = false,
//   }) async {
//     final createdHive = await _hiveRepository.insertHive(hive);
    
//     if (!skipHistoryLog) {
//       await _logHiveAction(
//         hiveId: createdHive.id,
//         hiveName: createdHive.name,
//         action: HistoryAction.create,
//         description: 'Hive created: ${createdHive.name}',
//         groupId: groupId,
//       );
//     }
    
//     return createdHive;
//   }

//   /// Updates an existing hive in the database and logs the changes.
//   /// 
//   /// Parameters:
//   /// - [hive]: The hive with updated values
//   /// - [skipHistoryLog]: If true, no history log will be created
//   /// - [groupId]: Optional group ID for history logging
//   Future<Hive> updateHive({
//     required Hive hive,
//     bool skipHistoryLog = false,
//     String? groupId,
//   }) async {
//     final oldHive = await _hiveRepository.getHiveById(hive.id);
//     if (oldHive == null) {
//       throw Exception('Hive not found for update: ${hive.id}');
//     }
    
//     final updatedHive = await _hiveRepository.updateHive(hive);
//     final changes = oldHive.toMap().differenceWith(updatedHive.toMap());

//     if (!skipHistoryLog) {
//       await _logHiveAction(
//         hiveId: updatedHive.id,
//         hiveName: updatedHive.name,
//         action: HistoryAction.update,
//         description: 'Hive updated: ${updatedHive.name}',
//         groupId: groupId,
//         changes: changes,
//       );
//     }
    
//     return updatedHive;
//   }

//   /// Updates multiple hives in a batch operation and logs the action.
//   /// 
//   /// Parameters:
//   /// - [hives]: The list of hives to update
//   /// - [groupId]: Optional group ID for history logging
//   /// - [skipHistoryLog]: If true, no history log will be created
//   Future<List<Hive>> updateHivesBatch(
//     List<Hive> hives, {
//     String? groupId,
//     bool skipHistoryLog = false,
//   }) async {
//     final updatedHives = await _hiveRepository.updateHivesBatch(hives);
    
//     if (!skipHistoryLog) {
//       await _logHiveAction(
//         hiveId: 'batch',
//         hiveName: '',
//         action: HistoryAction.updateBatch,
//         description: 'Reorder hives',
//         groupId: groupId,
//       );
//     }
    
//     return updatedHives;
//   }

//   /// Creates a new hive with default or specified values and logs the action.
//   /// 
//   /// See [HiveRepository.createDefaultHive] for parameter details.
//   Future<Hive> createDefaultHive({
//     String? apiaryId,
//     String? queenId,
//     required String name,
//     HiveStatus? status,
//     Color? color,
//     String? hiveTypeId,
//     String? imageUrl,
//     int? currentFrameCount,
//     int? currentBroodFrameCount,
//     int? currentBroodBoxCount,
//     int? currentHoneySuperBoxCount,
//     DateTime? acquisitionDate,
//     String? groupId,
//     bool skipHistoryLog = false,
//   }) async {
//     final hive = await _hiveRepository.createDefaultHive(
//       apiaryId: apiaryId,
//       queenId: queenId,
//       name: name,
//       status: status,
//       color: color,
//       hiveTypeId: hiveTypeId,
//       imageUrl: imageUrl,
//       currentFrameCount: currentFrameCount,
//       currentBroodFrameCount: currentBroodFrameCount,
//       currentBroodBoxCount: currentBroodBoxCount,
//       currentHoneySuperBoxCount: currentHoneySuperBoxCount,
//       acquisitionDate: acquisitionDate,
//     );
    
//     if (!skipHistoryLog) {
//       await _logHiveAction(
//         hiveId: hive.id,
//         hiveName: hive.name,
//         action: HistoryAction.create,
//         description: 'Default hive created: ${hive.name}',
//         groupId: groupId,
//       );
//     }
    
//     return hive;
//   }

//   /// Deletes a hive (marks as deleted) and logs the action.
//   /// 
//   /// Parameters:
//   /// - [hiveId]: The ID of the hive to delete
//   /// - [groupId]: Optional group ID for history logging
//   /// - [skipHistoryLog]: If true, no history log will be created
//   Future<bool> deleteHive({
//     required String hiveId,
//     String? groupId,
//     bool skipHistoryLog = false,
//   }) async {
//     final hive = await _hiveRepository.getHiveById(hiveId);
//     if (hive == null) {
//       throw Exception('Hive not found for deletion: $hiveId');
//     }
    
//     final result = await _hiveRepository.deleteHive(hiveId);
    
//     if (result && !skipHistoryLog) {
//       await _logHiveAction(
//         hiveId: hiveId,
//         hiveName: hive.name,
//         action: HistoryAction.delete,
//         description: 'Hive deleted: ${hive.name}',
//         groupId: groupId,
//       );
//     }
    
//     return result;
//   }

//   // MARK: - Hive Type Operations

//   /// Gets all hive types.
//   Future<List<HiveType>> getAllTypes() async {
//     return _hiveTypeRepository.getAllTypes();
//   }

//   /// Gets a hive type by ID.
//   /// 
//   /// Parameters:
//   /// - [id]: The ID of the hive type to retrieve
//   Future<HiveType?> getTypeById(String id) async {
//     return _hiveTypeRepository.getTypeById(id);
//   }

//   /// Inserts a new hive type and logs the action.
//   /// 
//   /// Parameters:
//   /// - [type]: The hive type to insert
//   /// - [groupId]: Optional group ID for history logging
//   /// - [skipHistoryLog]: If true, no history log will be created
//   Future<HiveType> insertType({
//     required HiveType type,
//     String? groupId,
//     bool skipHistoryLog = false,
//   }) async {
//     final createdType = await _hiveTypeRepository.insertType(type);
    
//     if (!skipHistoryLog) {
//       await _logHiveTypeAction(
//         typeId: createdType.id,
//         typeName: createdType.name,
//         action: HistoryAction.create,
//         description: 'Hive type created: ${createdType.name}',
//         groupId: groupId,
//       );
//     }
    
//     return createdType;
//   }

//   /// Updates a hive type and logs the changes.
//   /// 
//   /// Parameters:
//   /// - [type]: The hive type with updated values
//   /// - [groupId]: Optional group ID for history logging
//   /// - [skipHistoryLog]: If true, no history log will be created
//   Future<HiveType> updateType({
//     required HiveType type, 
//     String? groupId,
//     bool skipHistoryLog = false,
//   }) async {
//     final oldType = await _hiveTypeRepository.getTypeById(type.id);
//     final updatedType = await _hiveTypeRepository.updateType(type);
    
//     if (oldType != null && !skipHistoryLog) {
//       final changes = oldType.toMap().differenceWith(updatedType.toMap());
//       if (changes.isNotEmpty) {
//         await _logHiveTypeAction(
//           typeId: updatedType.id,
//           typeName: updatedType.name,
//           action: HistoryAction.update,
//           description: 'Hive type updated: ${updatedType.name}',
//           groupId: groupId,
//           changes: changes,
//         );
//       }
//     }
    
//     return updatedType;
//   }

//   // MARK: - Private Helper Methods

//   /// Helper method to log hive-related actions to history.
//   Future<void> _logHiveAction({
//     required String hiveId,
//     required String hiveName,
//     required HistoryAction action,
//     required String description,
//     String? groupId,
//     Map<String, dynamic>? changes,
//   }) async {
//     await _historyLogRepository.insertHistoryLog(
//       HistoryLog(
//         id: _uuid.v4(),
//         entityId: hiveId,
//         entityType: EntityType.hive,
//         action: action,
//         timestamp: DateTime.now(),
//         description: description,
//         groupId: groupId,
//         changes: changes,
//       ),
//     );
//   }

//   /// Helper method to log hive type-related actions to history.
//   Future<void> _logHiveTypeAction({
//     required String typeId,
//     required String typeName,
//     required HistoryAction action,
//     required String description,
//     String? groupId,
//     Map<String, dynamic>? changes,
//   }) async {
//     await _historyLogRepository.insertHistoryLog(
//       HistoryLog(
//         id: _uuid.v4(),
//         entityId: typeId,
//         entityType: EntityType.hiveType,
//         action: action,
//         timestamp: DateTime.now(),
//         description: description,
//         groupId: groupId,
        changes: changes,
//       ),
//     );
//   }
// }
