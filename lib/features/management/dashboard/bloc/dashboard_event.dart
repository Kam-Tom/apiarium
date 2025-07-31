part of 'dashboard_bloc.dart';

abstract class DashboardEvent {}

class LoadDashboardData extends DashboardEvent {}

class RefreshDashboardData extends DashboardEvent {}

class LoadMoreActivity extends DashboardEvent {}

class ShowActivityDetails extends DashboardEvent {
  final String activityId;
  
  ShowActivityDetails(this.activityId);
}
