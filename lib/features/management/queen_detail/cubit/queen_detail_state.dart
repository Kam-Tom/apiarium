part of 'queen_detail_cubit.dart';

enum QueenDetailStatus { initial, loading, loaded, error }

class QueenDetailState extends Equatable {
  final QueenDetailStatus status;
  final Queen? queen;
  final QueenBreed? queenBreed;
  final List<HistoryLog> historyLogs;
  final List<Inspection> inspections;
  final String? errorMessage;

  const QueenDetailState({
    this.status = QueenDetailStatus.initial,
    this.queen,
    this.queenBreed,
    this.historyLogs = const [],
    this.inspections = const [],
    this.errorMessage,
  });

  QueenDetailState copyWith({
    QueenDetailStatus? status,
    Queen? queen,
    QueenBreed? queenBreed,
    List<HistoryLog>? historyLogs,
    List<Inspection>? inspections,
    String? errorMessage,
  }) {
    return QueenDetailState(
      status: status ?? this.status,
      queen: queen ?? this.queen,
      queenBreed: queenBreed ?? this.queenBreed,
      historyLogs: historyLogs ?? this.historyLogs,
      inspections: inspections ?? this.inspections,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, queen, queenBreed, historyLogs, inspections, errorMessage];
}
