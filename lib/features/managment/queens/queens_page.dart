import 'package:apiarium/core/core.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_event.dart';
import 'package:apiarium/shared/cubits/apiary_filter_cubit.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/apiary_filter_app_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'queens.dart';

class QueensPage extends StatelessWidget {
  const QueensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => QueensBloc(
            queenService: getIt<QueenService>(),
          )..add(const LoadQueens()),
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
            title: 'management.queens.title'.tr(),
            onFilterPressed: () => _showFilterDialog(context),
            onSortPressed: () => _showSortDialog(context),
            onApiaryChanged: (apiaryId) => context.read<QueensBloc>().add(FilterByApiary(apiaryId)),
          ),
          body: const QueensView(),
          floatingActionButton: _buildFAB(context),
        ),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _handleAddQueen(context),
      backgroundColor: Colors.amber,
      child: const Icon(Icons.add),
    );
  }

  Future<void> _handleAddQueen(BuildContext context) async {
    Queen? queen = await context.push(AppRouter.editQueen) as Queen?;
    if (context.mounted) {
      context.read<QueensBloc>().add(const LoadQueens());
      context.read<ApiaryFilterCubit>().selectApiary(queen?.apiaryId);
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<QueensBloc>(),
        child: const QueenFilterModal(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<QueensBloc>(), 
        child: const QueenSortModal(),
      ),
    );
  }
}