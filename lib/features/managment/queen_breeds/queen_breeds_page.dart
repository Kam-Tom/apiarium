import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/queen_breeds/bloc/queen_breeds_bloc.dart';
import 'package:apiarium/features/managment/queen_breeds/bloc/queen_breeds_event.dart';
import 'package:apiarium/features/managment/queen_breeds/queen_breeds_view.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:go_router/go_router.dart';

class QueenBreedsPage extends StatelessWidget {
  const QueenBreedsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => QueenBreedsBloc(
        queenService: getIt<QueenService>(),
      )..add(const LoadQueenBreeds()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Queen Breeds'),
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
              onPressed: () => _showFilterDialog(context),
              tooltip: 'Filter',
            ),
          ],
        ),
        body: const QueenBreedsView(),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _handleAddQueenBreed(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleAddQueenBreed(BuildContext context) async {
    final result = await context.push(AppRouter.editQueenBreed);
    if (result == true && context.mounted) {
      context.read<QueenBreedsBloc>().add(const LoadQueenBreeds());
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Breeds'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Show Starred Only'),
              leading: const Icon(Icons.star),
              onTap: () {
                // TODO: Implement starred filter
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Show Local Only'),
              leading: const Icon(Icons.home),
              onTap: () {
                // TODO: Implement local filter
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}