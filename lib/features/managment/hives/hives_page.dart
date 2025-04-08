import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/hives/bloc/hives_bloc.dart';
import 'package:apiarium/features/managment/hives/hives_view.dart';
import 'package:apiarium/features/managment/hives/widgets/hive_filter_modal.dart';
import 'package:apiarium/features/managment/hives/widgets/hive_sort_modal.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class HivesPage extends StatelessWidget {
  const HivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HivesBloc(
        hiveRepository: context.read<HiveRepository>(),
        apiaryRepository: context.read<ApiaryRepository>(),
      )..add(const LoadHives()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Hives'),
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade800, Colors.amber.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () {
                  // Show filter options
                  _showFilterDialog(context);
                },
                tooltip: 'Filter',
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => _showSortDialog(context),
                tooltip: 'Sort',
              ),
            ],
          ),
          body: const HivesView(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final allHives = context.read<HivesBloc>().state.allHives;
              if(allHives.isNotEmpty) {
                context.read<HivesBloc>().add(const AddHive());
                return;
              }
              final result = await context.push(AppRouter.editHive);
              if (context.mounted) {
                if (result is Hive) {
                  // If we have a returned Hive object, we can use it directly if needed
                  context.read<HivesBloc>().add(const LoadHives());
                } else {
                  context.read<HivesBloc>().add(const LoadHives());
                }
              }
            },
            backgroundColor: Colors.amber,
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final hivesBloc = context.read<HivesBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: hivesBloc,
        child: const HiveFilterModal(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final hivesBloc = context.read<HivesBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: hivesBloc, 
        child: const HiveSortModal(),
      ),
    );
  }
}
