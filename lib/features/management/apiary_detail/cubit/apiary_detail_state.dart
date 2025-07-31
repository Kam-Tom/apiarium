import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

enum ApiaryDetailStatus { initial, loading, loaded, error }

class ApiaryDetailState extends Equatable {
  final ApiaryDetailStatus status;
  final Apiary? apiary;
  final List<Hive> hives;
  final List<HistoryLog> historyLogs;
  final String? errorMessage;

  const ApiaryDetailState({
    this.status = ApiaryDetailStatus.initial,
    this.apiary,
    this.hives = const [],
    this.historyLogs = const [],
    this.errorMessage,
  });

  ApiaryDetailState copyWith({
    ApiaryDetailStatus? status,
    Apiary? apiary,
    List<Hive>? hives,
    List<HistoryLog>? historyLogs,
    String? errorMessage,
  }) {
    return ApiaryDetailState(
      status: status ?? this.status,
      apiary: apiary ?? this.apiary,
      hives: hives ?? this.hives,
      historyLogs: historyLogs ?? this.historyLogs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, apiary, hives, historyLogs, errorMessage];
}
