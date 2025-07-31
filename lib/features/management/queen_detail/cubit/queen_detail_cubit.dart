import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/shared/shared.dart';

part 'queen_detail_state.dart';

class QueenDetailCubit extends Cubit<QueenDetailState> {
  final QueenService _queenService;
  final HistoryService _historyService;
  final InspectionService _inspectionService;

  QueenDetailCubit({
    required QueenService queenService,
    required HistoryService historyService,
    required InspectionService inspectionService,
  }) : _queenService = queenService,
       _historyService = historyService,
       _inspectionService = inspectionService,
       super(const QueenDetailState());

  Future<void> loadQueenDetail(String queenId) async {
    try {
      emit(state.copyWith(status: QueenDetailStatus.loading));
      
      final results = await Future.wait([
        _queenService.getQueenById(queenId),
        _historyService.getHistoryLogsByEntityId(queenId),
        _inspectionService.getInspectionsByQueenId(queenId),
      ]);

      final queen = results[0] as Queen?;
      final historyLogs = results[1] as List<HistoryLog>;
      final inspections = results[2] as List<Inspection>;

      if (queen == null) {
        emit(state.copyWith(
          status: QueenDetailStatus.error,
          errorMessage: 'Queen not found',
        ));
        return;
      }

      // Load queen breed information
      QueenBreed? queenBreed;
      try {
        queenBreed = await _queenService.getAllQueenBreeds().then((breeds) => 
          breeds.cast<QueenBreed?>().firstWhere(
            (breed) => breed?.id == queen.breedId,
            orElse: () => null,
          )
        );
      } catch (e) {
        // Continue without breed info if it fails
      }

      emit(state.copyWith(
        status: QueenDetailStatus.loaded,
        queen: queen,
        queenBreed: queenBreed,
        historyLogs: historyLogs,
        inspections: inspections,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: QueenDetailStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> refresh(String queenId) async {
    await loadQueenDetail(queenId);
  }
}
