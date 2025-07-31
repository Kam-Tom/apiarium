part of 'dashboard_bloc.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final DashboardStats stats;
  final List<ApiaryMapData> apiaryMapData;
  final List<ActivityItem> recentActivity;
  final bool isLoadingMore;
  final int currentPage;

  DashboardLoaded({
    required this.stats,
    required this.apiaryMapData,
    required this.recentActivity,
    this.isLoadingMore = false,
    this.currentPage = 0,
  });

  DashboardLoaded copyWith({
    DashboardStats? stats,
    List<ApiaryMapData>? apiaryMapData,
    List<ActivityItem>? recentActivity,
    bool? isLoadingMore,
    int? currentPage,
  }) {
    return DashboardLoaded(
      stats: stats ?? this.stats,
      apiaryMapData: apiaryMapData ?? this.apiaryMapData,
      recentActivity: recentActivity ?? this.recentActivity,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class DashboardError extends DashboardState {
  final String message;
  
  DashboardError(this.message);
}
