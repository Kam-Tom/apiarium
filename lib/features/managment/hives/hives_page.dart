import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/hives/bloc/hives_bloc.dart';
import 'package:apiarium/features/managment/hives/hives_view.dart';
import 'package:apiarium/features/managment/hives/widgets/hive_filter_modal.dart';
import 'package:apiarium/features/managment/hives/widgets/hive_sort_modal.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/apiary_filter_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:apiarium/shared/cubits/apiary_filter_cubit.dart';

class HivesPage extends StatelessWidget {
  const HivesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => HivesBloc(
            hiveService: getIt<HiveService>(),
            apiaryService: getIt<ApiaryService>(),
          )..add(const LoadHives()),
        ),
        BlocProvider(
          create: (context) => ApiaryFilterCubit(
            getIt<ApiaryService>()
          )..loadApiaries(),
        ),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          appBar: ApiaryFilterAppBar(
            title: 'hives'.tr(),
            onFilterPressed: () => _showFilterDialog(context),
            onSortPressed: () => _showSortDialog(context),
            onApiaryChanged: (apiaryId) => context.read<HivesBloc>().add(FilterByApiaryId(apiaryId)),
          ),
          body: const HivesView(),
          floatingActionButton: _buildFAB(context),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleAddHive(context),
      backgroundColor: Colors.amber,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _handleAddHive(BuildContext context) async {
    await context.push(AppRouter.editHive);
    if (context.mounted) {
      context.read<HivesBloc>().add(const LoadHives());
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HivesBloc>(),
        child: const HiveFilterModal(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<HivesBloc>(),
        child: const HiveSortModal(),
      ),
    );
  }
}