import 'package:apiarium/shared/shared.dart';
import 'package:uuid/uuid.dart';

/// Service class for managing reports, including automatic history logging
/// and grouping of related changes.
class ReportService {
  final ReportRepository _reportRepository;
  final HistoryLogRepository _historyLogRepository;
  final SyncService _syncService;
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();
  
  ReportService({
    ReportRepository? reportRepository,
    HistoryLogRepository? historyLogRepository,
    SyncService? syncService,
    HiveService? hiveService,
  }) : 
    _reportRepository = reportRepository ?? ReportRepository(),
    _historyLogRepository = historyLogRepository ?? HistoryLogRepository(),
    _syncService = syncService ?? SyncService(),
    _hiveService = hiveService ?? HiveService(
      hiveRepository: HiveRepository(),
      hiveTypeRepository: HiveTypeRepository(),
      historyLogRepository: HistoryLogRepository()
    );
  

  /// Create a new Group for related history logs.
  /// This is used to group related changes together for better tracking.
  String createGroupId() {
    return _uuid.v4();
  }

  Future<String> insertReport({
    required Report report,
    String? groupId,
  }) async {
    final reportId = await _reportRepository.insertReport(report);
    
    await _historyLogRepository.insertHistoryLog(
      HistoryLog(
        id: _uuid.v4(),
        entityId: reportId,
        entityType: EntityType.report,
        action: HistoryAction.create,
        timestamp: DateTime.now(),
        description: 'Report created',
        groupId: groupId,
      ),
    );

    // Update hive
    if (report.fields != null) {
      await _updateHive(
        hiveId: report.hiveId,
        fields: report.fields!,
      );
    }
    
    return reportId;
  }
  
  Future<void> updateReport({
    required Report report,
    String? groupId,
    bool shadowUpdate = false,
  }) async {
    final oldReport = await _reportRepository.getReport(id:report.id);
    if (oldReport == null) {
      throw Exception('Report not found for ID: ${report.id}');
    }
    final changes = oldReport.toFlatMap().differenceWith(report.toFlatMap());
    
    await _reportRepository.updateReport(report);
    
    if(!shadowUpdate) {
      await _historyLogRepository.insertHistoryLog(
        HistoryLog(
          id: _uuid.v4(),
          entityId: report.id,
          entityType: EntityType.report,
          action: HistoryAction.update,
          timestamp: DateTime.now(),
          description: 'Report updated',
          groupId: groupId,
          changes: changes
        ),
      );
    }

    // Update hive
    if (report.fields != null) {
      await _updateHive(
        hiveId: report.hiveId,
        fields: report.fields!,
      );
    }
  }

  Future<void> deleteReport({
    required Report report,
    String? groupId,
  }) async {
    await _reportRepository.deleteReport(report.id);
    
    await _historyLogRepository.insertHistoryLog(
      HistoryLog(
        id: _uuid.v4(),
        entityId: report.id,
        entityType: EntityType.report,
        action: HistoryAction.delete,
        timestamp: DateTime.now(),
        description: 'Report deleted',
        groupId: groupId,
      ),
    );
  }
  
  /// Get a report 
  Future<Report?> getReport({
    String? id,
    ReportType? type,
    String? hiveId,
    String? queenId,
    String? apiaryId,
  }) async {
    return _reportRepository.getReport(
      id: id,
      type: type,
      hiveId: hiveId,
      queenId: queenId,
      apiaryId: apiaryId,
    );
  }
  
  /// Gets all reports matching the specified criteria
  Future<List<Report>> getAllReports({
    ReportType? type,
    String? hiveId,
    String? queenId,
    String? apiaryId,
  }) async {
    return _reportRepository.getAllReports(
      type: type,
      hiveId: hiveId,
      queenId: queenId,
      apiaryId: apiaryId,
    );
  }

  /// Batch: Gets the most recent report fields for all hives in an apiary
  Future<Map<String, List<Field>>> getRecentFieldsForApiary({
    required String apiaryId,
    required ReportType type,
  }) async {
    return _reportRepository.getRecentFieldsForApiary(apiaryId: apiaryId, type: type);
  }
  
  /// Helper method to update a hive's frame and box counts based on report fields
  Future<void> _updateHive(
    {
      required String hiveId,
      required List<Field> fields,
    }
  ) async {
    final hive = await _hiveService.getHiveById(hiveId, includeApiary: true, includeQueen: true);
    if (hive == null) return;
    Hive updatedHive = hive.copyWith();
    bool hasChanges = false;
    
    final broodBoxNetField = fields.where(
      (field) => field.attributeId == 'framesMoved.broodBoxNet'
    ).firstOrNull;

    if(broodBoxNetField != null) {
      final value = broodBoxNetField.getValue<int>(defaultValue: 0) ?? 0;
      if (value != 0) {
        updatedHive = updatedHive.copyWith(
          currentBroodBoxCount: () => (updatedHive.currentBroodBoxCount ?? 0) + value,
        );
        hasChanges = true;
      }
    }
    
    final honeySuperBoxNetField = fields.where(
      (field) => field.attributeId == 'framesMoved.honeySuperBoxNet'
    ).firstOrNull;

    if(honeySuperBoxNetField != null) {
      final value = honeySuperBoxNetField.getValue<int>(defaultValue: 0) ?? 0;
      if (value != 0) {
        updatedHive = updatedHive.copyWith(
          currentHoneySuperBoxCount: () => (updatedHive.currentHoneySuperBoxCount ?? 0) + value,
        );
        hasChanges = true;
      }
    }
    
    final broodNetField = fields.where(
      (field) => field.attributeId == 'framesMoved.broodNet'
    ).firstOrNull;

    if(broodNetField != null) {
      final value = broodNetField.getValue<int>(defaultValue: 0) ?? 0;
      if (value != 0) {
        updatedHive = updatedHive.copyWith(
          currentBroodFrameCount: () => (updatedHive.currentBroodFrameCount ?? 0) + value,
        );
        hasChanges = true;
      }
    }
    
    final emptyBroodNetField = fields.where(
      (field) => field.attributeId == 'framesMoved.emptyBroodNet'
    ).firstOrNull;
    
    if(emptyBroodNetField != null) {
      final value = emptyBroodNetField.getValue<int>(defaultValue: 0) ?? 0;
      if (value != 0) {
        updatedHive = updatedHive.copyWith(
          currentBroodFrameCount: () => (updatedHive.currentBroodFrameCount ?? 0) + value,
        );
        hasChanges = true;
      }
    }

    final honeyNetField = fields.where(
      (field) => field.attributeId == 'framesMoved.honeyNet'
    ).firstOrNull;
    
    if(honeyNetField != null) {
      final value = honeyNetField.getValue<int>(defaultValue: 0) ?? 0;
      if (value != 0) {
        updatedHive = updatedHive.copyWith(
          currentFrameCount: () => (updatedHive.currentFrameCount ?? 0) + value,
        );
        hasChanges = true;
      }
    }

    final emptyNetField = fields.where(
      (field) => field.attributeId == 'framesMoved.emptyNet'
    ).firstOrNull;

    if(emptyNetField != null) {
      final value = emptyNetField.getValue<int>(defaultValue: 0) ?? 0;
      if (value != 0) {
        updatedHive = updatedHive.copyWith(
          currentFrameCount: () => (updatedHive.currentFrameCount ?? 0) + value,
        );
        hasChanges = true;
      }
    }
    
    if(!hasChanges) return;

    await _hiveService.updateHive(
      hive: updatedHive,
      skipHistoryLog: true,
    );
  }
}
