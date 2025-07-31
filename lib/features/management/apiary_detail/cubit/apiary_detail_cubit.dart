import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'apiary_detail_state.dart';

class ApiaryDetailCubit extends Cubit<ApiaryDetailState> {
  final ApiaryService apiaryService;
  final HiveService hiveService;
  final HistoryService historyService;

  ApiaryDetailCubit({
    required this.apiaryService,
    required this.hiveService,
    required this.historyService,
  }) : super(const ApiaryDetailState());

  Future<void> loadApiaryDetail(String apiaryId) async {
    try {
      emit(state.copyWith(status: ApiaryDetailStatus.loading));
      
      final results = await Future.wait([
        apiaryService.getApiaryById(apiaryId),
        hiveService.getHivesByApiaryId(apiaryId),
        historyService.getHistoryLogsByEntityId(apiaryId),
      ]);

      final apiary = results[0] as Apiary?;
      final hives = results[1] as List<Hive>;
      final historyLogs = results[2] as List<HistoryLog>;

      if (apiary == null) {
        emit(state.copyWith(
          status: ApiaryDetailStatus.error,
          errorMessage: 'Apiary not found',
        ));
        return;
      }

      emit(state.copyWith(
        status: ApiaryDetailStatus.loaded,
        apiary: apiary,
        hives: hives,
        historyLogs: historyLogs,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ApiaryDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh(String apiaryId) async {
    await loadApiaryDetail(apiaryId);
  }
}
