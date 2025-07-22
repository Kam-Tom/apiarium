import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_bloc.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_event.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_state.dart';
import 'package:apiarium/features/managment/hive_types/widgets/improved_hive_type_card.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveTypesView extends StatelessWidget {
  const HiveTypesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade100,
      child: Column(
        children: [
          // Hive type count and filter info
          _buildInfoBanner(context),
          // Hive types list
          Expanded(
            child: _buildHiveTypesList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return BlocBuilder<HiveTypesBloc, HiveTypesState>(
      builder: (context, state) {
        if (state.filteredHiveTypes.isEmpty || state.status != HiveTypesStatus.loaded) {
          return const SizedBox.shrink();
        }
        
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          color: Colors.grey.shade100,
          child: Row(
            children: [
              Text(
                'hive_types.count'.tr(namedArgs: {
                  'count': '${state.filteredHiveTypes.length}',
                  'type': state.filteredHiveTypes.length == 1 
                    ? 'hive_types.singular'.tr() 
                    : 'hive_types.plural'.tr()
                }),
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (_hasActiveFilters(state))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: AppTheme.primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'hive_types.filtered'.tr(),
                        style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  bool _hasActiveFilters(HiveTypesState state) {
    final filter = state.filter;
    return filter.starredOnly == true || 
           filter.localOnly == true || 
           filter.material != null;
  }

  Widget _buildHiveTypesList(BuildContext context) {
    return BlocConsumer<HiveTypesBloc, HiveTypesState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.status == HiveTypesStatus.initial) {
          context.read<HiveTypesBloc>().add(const LoadHiveTypes());
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == HiveTypesStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.status == HiveTypesStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.errorMessage ?? 'common.error_occurred'.tr()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<HiveTypesBloc>().add(const LoadHiveTypes()),
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          );
        }
        
        if (state.filteredHiveTypes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.home_work,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  _hasActiveFilters(state) 
                    ? 'hive_types.no_matches'.tr()
                    : 'hive_types.empty'.tr(),
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (_hasActiveFilters(state)) ...[
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HiveTypesBloc>().add(const FilterByStarred(null));
                      context.read<HiveTypesBloc>().add(const FilterByLocal(null));
                      context.read<HiveTypesBloc>().add(const FilterByMaterial(null));
                    },
                    child: Text('hive_types.clear_filters'.tr()),
                  ),
                ],
              ],
            ),
          );
        }
        
        return RefreshIndicator(
          onRefresh: () async {
            context.read<HiveTypesBloc>().add(const LoadHiveTypes());
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: state.filteredHiveTypes.length,
            itemBuilder: (context, index) {
              final hiveType = state.filteredHiveTypes[index];
              return ImprovedHiveTypeCard(
                hiveType: hiveType,
                onDelete: () {
                  context.read<HiveTypesBloc>().add(DeleteHiveType(hiveType.id));
                },
              );
            },
          ),
        );
      },
    );
  }
}