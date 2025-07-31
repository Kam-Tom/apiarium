import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

enum HiveDetailStatus { initial, loading, loaded, error }

class HiveDetailState extends Equatable {
  final HiveDetailStatus status;
  final Hive? hive;
  final HiveType? hiveType;
  final List<HistoryLog> historyLogs;
  final List<Inspection> inspections;
  final String? errorMessage;

  const HiveDetailState({
    this.status = HiveDetailStatus.initial,
    this.hive,
    this.hiveType,
    this.historyLogs = const [],
    this.inspections = const [],
    this.errorMessage,
  });

  HiveDetailState copyWith({
    HiveDetailStatus? status,
    Hive? hive,
    HiveType? hiveType,
    List<HistoryLog>? historyLogs,
    List<Inspection>? inspections,
    String? errorMessage,
  }) {
    return HiveDetailState(
      status: status ?? this.status,
      hive: hive ?? this.hive,
      hiveType: hiveType ?? this.hiveType,
      historyLogs: historyLogs ?? this.historyLogs,
      inspections: inspections ?? this.inspections,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, hive, hiveType, historyLogs, inspections, errorMessage];
}
