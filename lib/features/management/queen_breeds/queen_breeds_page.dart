import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/management/queen_breeds/bloc/queen_breeds_bloc.dart';
import 'package:apiarium/features/management/queen_breeds/bloc/queen_breeds_event.dart';
import 'package:apiarium/features/management/queen_breeds/queen_breeds_view.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

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
          title: Text('queen_breeds.title'.tr()),
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
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () => _showFilterDialog(context),
                  tooltip: 'common.filter'.tr(),
                );
              }
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
    final bloc = context.read<QueenBreedsBloc>();
    
    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: bloc,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.filter_list, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'queen_breeds.filter.title'.tr(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: Text('queen_breeds.filter.starred_only'.tr()),
                    leading: const Icon(Icons.star),
                    onTap: () {
                      bloc.add(const FilterBreedsByStarred(true));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    title: Text('queen_breeds.filter.local_only'.tr()),
                    leading: const Icon(Icons.home),
                    onTap: () {
                      bloc.add(const FilterBreedsByLocal(true));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          bloc.add(const FilterBreedsByStarred(null));
                          bloc.add(const FilterBreedsByLocal(null));
                        },
                        child: Text('common.reset'.tr()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('common.close'.tr()),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}