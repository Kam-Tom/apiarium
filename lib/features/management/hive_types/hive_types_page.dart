import 'package:apiarium/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/management/hive_types/bloc/hive_types_bloc.dart';
import 'package:apiarium/features/management/hive_types/bloc/hive_types_event.dart';
import 'package:apiarium/features/management/hive_types/hive_types_view.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveTypesPage extends StatelessWidget {
  const HiveTypesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HiveTypesBloc(
        hiveService: getIt<HiveService>(),
      )..add(const LoadHiveTypes()),
      child: Scaffold(
        appBar: AppBar(
          title: Text('hive_types.title'.tr()),
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
        body: const HiveTypesView(),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  Widget _buildFAB() {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _handleAddHiveType(context),
        backgroundColor: Colors.amber,
        tooltip: 'common.add'.tr(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _handleAddHiveType(BuildContext context) async {
    final result = await context.push(AppRouter.editHiveType);
    if (result == true && context.mounted) {
      context.read<HiveTypesBloc>().add(const LoadHiveTypes());
    }
  }

  void _showFilterDialog(BuildContext context) {
    final bloc = context.read<HiveTypesBloc>();
    
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
                        'hive_types.filter.title'.tr(),
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
                    title: Text('hive_types.filter.starred_only'.tr()),
                    leading: const Icon(Icons.star),
                    onTap: () {
                      bloc.add(const FilterByStarred(true));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    title: Text('hive_types.filter.local_only'.tr()),
                    leading: const Icon(Icons.home),
                    onTap: () {
                      bloc.add(const FilterByLocal(true));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    title: Text('edit_hive_type.material_wood'.tr()),
                    leading: Icon(Icons.park, color: Colors.brown),
                    onTap: () {
                      bloc.add(const FilterByMaterial(HiveMaterial.wood));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    title: Text('edit_hive_type.material_plastic'.tr()),
                    leading: Icon(Icons.recycling, color: Colors.blue),
                    onTap: () {
                      bloc.add(const FilterByMaterial(HiveMaterial.plastic));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    title: Text('edit_hive_type.material_polystyrene'.tr()),
                    leading: Icon(Icons.science, color: Colors.green),
                    onTap: () {
                      bloc.add(const FilterByMaterial(HiveMaterial.polystyrene));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  ListTile(
                    title: Text('edit_hive_type.material_metal'.tr()),
                    leading: Icon(Icons.hardware, color: Colors.grey),
                    onTap: () {
                      bloc.add(const FilterByMaterial(HiveMaterial.metal));
                      Navigator.pop(dialogContext);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          bloc.add(const FilterByStarred(null));
                          bloc.add(const FilterByLocal(null));
                          bloc.add(const FilterByMaterial(null));
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