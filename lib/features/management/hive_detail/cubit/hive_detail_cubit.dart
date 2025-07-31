import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'hive_detail_state.dart';

class HiveDetailCubit extends Cubit<HiveDetailState> {
  final HiveService hiveService;
  final HistoryService historyService;
  final InspectionService inspectionService;

  HiveDetailCubit({
    required this.hiveService,
    required this.historyService,
    required this.inspectionService,
  }) : super(const HiveDetailState());

  Future<void> loadHiveDetail(String hiveId) async {
    try {
      emit(state.copyWith(status: HiveDetailStatus.loading));
      
      final results = await Future.wait([
        hiveService.getHiveById(hiveId),
        historyService.getHistoryLogsByEntityId(hiveId),
        inspectionService.getInspectionsByHiveId(hiveId),
      ]);

      final hive = results[0] as Hive?;
      final historyLogs = results[1] as List<HistoryLog>;
      final inspections = results[2] as List<Inspection>;

      if (hive == null) {
        emit(state.copyWith(
          status: HiveDetailStatus.error,
          errorMessage: 'Hive not found',
        ));
        return;
      }

      // Load hive type information
      HiveType? hiveType;
      try {
        hiveType = await hiveService.getHiveTypeById(hive.hiveTypeId);
      } catch (e) {
        // Continue without hive type info if it fails
      }

      emit(state.copyWith(
        status: HiveDetailStatus.loaded,
        hive: hive,
        hiveType: hiveType,
        historyLogs: historyLogs,
        inspections: inspections,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HiveDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh(String hiveId) async {
    await loadHiveDetail(hiveId);
  }
}
