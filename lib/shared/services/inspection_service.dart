import 'package:uuid/uuid.dart';
import '../shared.dart';

class InspectionService {
  static const String _tag = 'InspectionService';
  static const Uuid _uuid = Uuid();

  final InspectionRepository _inspectionRepository;
  final UserRepository _userRepository;
  final HistoryService _historyService;

  InspectionService({
    required InspectionRepository inspectionRepository,
    required UserRepository userRepository,
    required HistoryService historyService,
  }) : _inspectionRepository = inspectionRepository,
       _userRepository = userRepository,
       _historyService = historyService;

  Future<void> initialize() async {
    await _inspectionRepository.initialize();
    Logger.i('Inspection service initialized', tag: _tag);
  }

  Future<List<Inspection>> getAllInspections() async {
    return await _inspectionRepository.getAllInspections();
  }

  Future<Inspection?> getInspectionById(String id) async {
    return await _inspectionRepository.getInspectionById(id);
  }

  Future<List<Inspection>> getInspectionsByHiveId(String hiveId) async {
    return await _inspectionRepository.getInspectionsByHiveId(hiveId);
  }

  Future<List<Inspection>> getInspectionsByApiaryId(String apiaryId) async {
    return await _inspectionRepository.getInspectionsByApiaryId(apiaryId);
  }

  Future<List<Inspection>> getInspectionsByQueenId(String queenId) async {
    return await _inspectionRepository.getInspectionsByQueenId(queenId);
  }

  Future<List<Inspection>> getInspectionsByDateRange(DateTime start, DateTime end) async {
    return await _inspectionRepository.getInspectionsByDateRange(start, end);
  }

  List<Attribute> getAllAttributes() {
    return Attribute.values;
  }

  Future<Inspection> createInspection({
    required String hiveId,
    required String hiveName,
    String? apiaryId,
    String? groupId,
    String? apiaryName,
    String? queenId,
    String? queenName,
    Map<String, dynamic>? data,
  }) async {
    try {
      final now = DateTime.now();

      final inspection = Inspection(
        id: _uuid.v4(),
        createdAt: now,
        updatedAt: now,
        hiveId: hiveId,
        hiveName: hiveName,
        apiaryId: apiaryId,
        groupId: groupId,
        apiaryName: apiaryName,
        queenId: queenId,
        queenName: queenName,
        data: data,
      );

      await _inspectionRepository.saveInspection(inspection);
      Logger.i('Created inspection for hive: $hiveName', tag: _tag);

      await _historyService.logEntityCreate(
        entityId: inspection.id,
        entityType: 'inspection',
        entityName: 'Inspection for $hiveName',
        entityData: inspection.toJson(),
      );

      await _syncInspection(inspection);

      return inspection;
    } catch (e) {
      Logger.e('Failed to create inspection for hive: $hiveName', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Inspection> updateInspection(Inspection inspection) async {
    try {
      final oldInspection = await _inspectionRepository.getInspectionById(inspection.id);
      if (oldInspection == null) {
        throw Exception('Inspection not found: ${inspection.id}');
      }

      final updatedInspection = inspection.copyWith(
        updatedAt: () => DateTime.now(),
      );

      await _inspectionRepository.saveInspection(updatedInspection);
      Logger.i('Updated inspection: ${updatedInspection.id}', tag: _tag);

      await _historyService.logEntityUpdate(
        entityId: updatedInspection.id,
        entityType: 'inspection',
        entityName: 'Inspection for ${updatedInspection.hiveName}',
        oldData: oldInspection.toJson(),
        newData: updatedInspection.toJson(),
      );

      await _syncInspection(updatedInspection);

      return updatedInspection;
    } catch (e) {
      Logger.e('Failed to update inspection: ${inspection.id}', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> deleteInspection(String id) async {
    try {
      final inspection = await getInspectionById(id);
      if (inspection != null) {
        final deletedInspection = inspection.copyWith(
          deleted: () => true,
          updatedAt: () => DateTime.now(),
        );

        await _inspectionRepository.saveInspection(deletedInspection);
        Logger.i('Deleted inspection: $id', tag: _tag);

        await _historyService.logEntityDelete(
          entityId: inspection.id,
          entityType: 'inspection',
          entityName: 'Inspection for ${inspection.hiveName}',
        );

        await _syncInspection(deletedInspection);
      }
    } catch (e) {
      Logger.e('Failed to delete inspection: $id', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<Map<String, int>> countAttributeValues({
    required Attribute attribute,
    List<String>? hiveIds,
    List<String>? apiaryIds,
    List<String>? queenIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final inspections = await _getFilteredInspections(
      hiveIds: hiveIds,
      apiaryIds: apiaryIds,
      queenIds: queenIds,
      startDate: startDate,
      endDate: endDate,
    );

    final counts = <String, int>{};

    for (final inspection in inspections) {
      final value = inspection.data?[attribute.name];
      if (value != null) {
        final valueStr = value.toString();
        counts[valueStr] = (counts[valueStr] ?? 0) + 1;
      }
    }

    return counts;
  }

  Future<double?> averageAttributeValue({
    required Attribute attribute,
    List<String>? hiveIds,
    List<String>? apiaryIds,
    List<String>? queenIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (attribute.type != FieldType.number) {
      throw ArgumentError('Average can only be calculated for number attributes');
    }

    final inspections = await _getFilteredInspections(
      hiveIds: hiveIds,
      apiaryIds: apiaryIds,
      queenIds: queenIds,
      startDate: startDate,
      endDate: endDate,
    );

    final values = <double>[];

    for (final inspection in inspections) {
      final value = inspection.data?[attribute.name];
      if (value != null && value is num) {
        values.add(value.toDouble());
      }
    }

    if (values.isEmpty) return null;

    return values.reduce((a, b) => a + b) / values.length;
  }

  Future<Map<String, double>> getAttributeStats({
    required Attribute attribute,
    List<String>? hiveIds,
    List<String>? apiaryIds,
    List<String>? queenIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (attribute.type != FieldType.number) {
      throw ArgumentError('Stats can only be calculated for number attributes');
    }

    final inspections = await _getFilteredInspections(
      hiveIds: hiveIds,
      apiaryIds: apiaryIds,
      queenIds: queenIds,
      startDate: startDate,
      endDate: endDate,
    );

    final values = <double>[];

    for (final inspection in inspections) {
      final value = inspection.data?[attribute.name];
      if (value != null && value is num) {
        values.add(value.toDouble());
      }
    }

    if (values.isEmpty) return {};

    values.sort();

    return {
      'count': values.length.toDouble(),
      'min': values.first,
      'max': values.last,
      'average': values.reduce((a, b) => a + b) / values.length,
      'median': values.length.isOdd
          ? values[values.length ~/ 2]
          : (values[values.length ~/ 2 - 1] + values[values.length ~/ 2]) / 2,
    };
  }

  Future<List<Inspection>> _getFilteredInspections({
    List<String>? hiveIds,
    List<String>? apiaryIds,
    List<String>? queenIds,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    var inspections = await getAllInspections();

    if (hiveIds != null && hiveIds.isNotEmpty) {
      inspections = inspections.where((i) => hiveIds.contains(i.hiveId)).toList();
    }

    if (apiaryIds != null && apiaryIds.isNotEmpty) {
      inspections = inspections.where((i) => apiaryIds.contains(i.apiaryId)).toList();
    }

    if (queenIds != null && queenIds.isNotEmpty) {
      inspections = inspections.where((i) => queenIds.contains(i.queenId)).toList();
    }

    if (startDate != null) {
      inspections = inspections.where((i) => i.createdAt.isAfter(startDate.subtract(const Duration(days: 1)))).toList();
    }

    if (endDate != null) {
      inspections = inspections.where((i) => i.createdAt.isBefore(endDate.add(const Duration(days: 1)))).toList();
    }

    return inspections;
  }

  Future<void> syncFromFirestore() async {
    if (!_userRepository.isPremium || _userRepository.currentUser == null) {
      Logger.w('Firestore sync skipped - not premium or not logged in', tag: _tag);
      return;
    }

    try {
      final userId = _userRepository.currentUser!.id;
      final lastSync = await _userRepository.getLastSyncTime();

      await _inspectionRepository.syncFromFirestore(userId, lastSyncTime: lastSync);

      Logger.i('Synced inspections from Firestore', tag: _tag);
    } catch (e) {
      Logger.e('Failed to sync from Firestore', tag: _tag, error: e);
    }
  }

  Future<void> _syncInspection(Inspection inspection) async {
    if (_userRepository.isPremium && _userRepository.currentUser != null) {
      try {
        final userId = _userRepository.currentUser!.id;
        await _inspectionRepository.syncToFirestore(inspection, userId);
      } catch (e) {
        Logger.e('Failed to sync inspection to Firestore', tag: _tag, error: e);
      }
    } else {
      Logger.d('Skipping inspection sync - not premium or not logged in', tag: _tag);
    }
  }

  Future<void> dispose() async {
    await _inspectionRepository.dispose();
    Logger.i('Inspection service disposed', tag: _tag);
  }

  Future<void> updateInspectionsBatch(List<Inspection> inspections) async {
    try {
      await _inspectionRepository.saveInspectionsBatch(inspections);
      Logger.i('Updated ${inspections.length} inspections in batch', tag: _tag);

      if (_userRepository.isPremium && _userRepository.currentUser != null) {
        final userId = _userRepository.currentUser!.id;
        await _inspectionRepository.syncBatchToFirestore(inspections, userId);
      }
    } catch (e) {
      Logger.e('Failed to update inspections batch', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<void> syncPendingToFirestore() async {
    if (!_userRepository.isPremium || _userRepository.currentUser == null) return;
    
    final inspections = await getAllInspections();
    final pending = inspections.where((i) => i.syncStatus == SyncStatus.pending).toList();
    
    for (final inspection in pending) {
      await _inspectionRepository.syncToFirestore(inspection, _userRepository.currentUser!.id);
    }
  }
}