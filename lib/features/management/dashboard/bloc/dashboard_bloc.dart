import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/shared/shared.dart';
import '../models/activity_item.dart';
part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardService _dashboardService;
  final HistoryService _historyService;
  final InspectionService _inspectionService;

  static const int _itemsPerPage = 25;

  DashboardBloc({
    DashboardService? dashboardService,
    HistoryService? historyService,
    InspectionService? inspectionService,
  })  : _dashboardService = dashboardService ?? getIt<DashboardService>(),
        _historyService = historyService ?? getIt<HistoryService>(),
        _inspectionService = inspectionService ?? getIt<InspectionService>(),
        super(DashboardInitial()) {
    on<LoadDashboardData>(_onLoadDashboardData);
    on<RefreshDashboardData>(_onRefreshDashboardData);
    on<LoadMoreActivity>(_onLoadMoreActivity);
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    await _loadDashboardData(emit);
  }

  Future<void> _onRefreshDashboardData(
    RefreshDashboardData event,
    Emitter<DashboardState> emit,
  ) async {
    await _loadDashboardData(emit);
  }

  Future<void> _loadDashboardData(Emitter<DashboardState> emit) async {
    try {
      final results = await Future.wait([
        _dashboardService.getDashboardStats(),
        _dashboardService.getApiaryMapData(),
        _loadActivityData(page: 0),
      ]);

      emit(DashboardLoaded(
        stats: results[0] as DashboardStats,
        apiaryMapData: results[1] as List<ApiaryMapData>,
        recentActivity: results[2] as List<ActivityItem>,
        currentPage: 0,
      ));
    } catch (e, stack) {
      Logger.e('Failed to load dashboard data', error: e, stackTrace: stack);
      emit(DashboardError('Unable to load dashboard data at this time.'));
    }
  }

  Future<void> _onLoadMoreActivity(
    LoadMoreActivity event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DashboardLoaded || currentState.isLoadingMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.currentPage + 1;
      final moreActivity = await _loadActivityData(page: nextPage);

      if (moreActivity.isNotEmpty) {
        final updatedActivity = [...currentState.recentActivity, ...moreActivity];
        emit(currentState.copyWith(
          recentActivity: updatedActivity,
          currentPage: nextPage,
          isLoadingMore: false,
        ));
      } else {
        emit(currentState.copyWith(isLoadingMore: false));
      }
    } catch (e, stack) {
      Logger.e('Failed to load more activity', error: e, stackTrace: stack);
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  Future<List<ActivityItem>> _loadActivityData({required int page}) async {
    final offset = page * _itemsPerPage;

    try {
      final historyLogs = await _historyService.getAllHistoryLogs();
      final inspections = await _inspectionService.getAllInspections();

      final activityItems = <ActivityItem>[];

      // Take half of the items from history logs
      final historyToTake = historyLogs.skip(offset).take(_itemsPerPage ~/ 2);
      activityItems.addAll(historyToTake.map(ActivityItem.fromHistoryLog));

      // Take half from inspections (adjusted for potential different lengths)
      final inspectionsToTake = inspections.skip(offset ~/ 2).take(_itemsPerPage ~/ 2);
      activityItems.addAll(inspectionsToTake.map(ActivityItem.fromInspection));

      // Sort by timestamp (descending)
      activityItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return activityItems.take(_itemsPerPage).toList();
    } catch (e, stack) {
      Logger.e('Failed to load activity data', tag: 'DashboardBloc', error: e, stackTrace: stack);
      return [];
    }
  }
}