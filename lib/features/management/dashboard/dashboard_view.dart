import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/shared/services/dashboard_service.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'widgets/apiary_map_widget.dart';
import 'widgets/dashboard_section.dart';
import 'widgets/navigation_section.dart';
import 'widgets/recent_activity_section.dart';
import 'bloc/dashboard_bloc.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {
            if (state is DashboardLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              );
            }
            
            if (state is DashboardError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red.shade400),
                    const SizedBox(height: 16),
                    Text(
                      'dashboard.error_loading_data'.tr(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: TextStyle(color: Colors.grey.shade600),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<DashboardBloc>().add(LoadDashboardData()),
                      child: Text('dashboard.retry'.tr()),
                    ),
                  ],
                ),
              );
            }
            
            if (state is DashboardLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<DashboardBloc>().add(RefreshDashboardData());
                },
                color: Colors.amber,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Map section first
                        _buildMapSection(state.apiaryMapData),
                        const SizedBox(height: 24),
                        
                        // Dashboard navigation
                        const NavigationSection(),
                        const SizedBox(height: 24),
                        
                        // Statistics Dashboard
                        DashboardSection(stats: state.stats),
                        const SizedBox(height: 24),
                        
                        // Recent activity
                        RecentActivitySection(
                          activities: state.recentActivity,
                          isLoadingMore: state.isLoadingMore,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildMapSection(List<ApiaryMapData> apiaryMapData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'dashboard.apiary_locations'.tr(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            if (apiaryMapData.isNotEmpty)
              TextButton.icon(
                onPressed: () {
                  // Navigate to full map view
                },
                icon: const Icon(Icons.fullscreen, size: 16),
                label: Text('dashboard.full_map'.tr()),
                style: TextButton.styleFrom(foregroundColor: Colors.amber.shade700),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ApiaryMapWidget(
          apiaries: apiaryMapData,
          onApiaryTap: (apiaryId) => context.push('${AppRouter.apiaries}/$apiaryId'),
        ),
      ],
    );
  }
}