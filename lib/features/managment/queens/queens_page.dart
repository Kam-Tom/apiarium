import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_event.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_state.dart';
import 'package:apiarium/features/managment/queens/widgets/queen_filter_modal.dart';
import 'package:apiarium/features/managment/queens/widgets/queen_sort_modal.dart';
import 'package:apiarium/shared/repositories/queen_breed_repository.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'queens.dart';

class QueensPage extends StatelessWidget {
  const QueensPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QueensBloc(
        queenService: context.read<QueenService>(),
        apiaryService: context.read<ApiaryService>(),
      )..add(const LoadQueens()),
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: const Text('Queens'),
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
              // Add filter and sort actions
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'Filter',
              ),
              IconButton(
                icon: const Icon(Icons.sort),
                onPressed: () => _showSortDialog(context),
                tooltip: 'Sort',
              ),
            ],
          ),
          body: const QueensView(),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final allQueens = context.read<QueensBloc>().state.allQueens;
              if(allQueens.isNotEmpty) {
                // If queens exist, create a default queen using the bloc
                context.read<QueensBloc>().add(const AddQueen());
              } else {
                // If no queens exist, navigate to edit queen page
                await context.push(AppRouter.editQueen);
                if(context.mounted) {
                  context.read<QueensBloc>().add(const LoadQueens());
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
    final queensBloc = context.read<QueensBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: queensBloc,
        child: const QueenFilterModal(),
      ),
    );
  }

  void _showSortDialog(BuildContext context) {
    final queensBloc = context.read<QueensBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: queensBloc, 
        child: const QueenSortModal(),
      ),
    );
  }
}
