import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/di/dependency_injection.dart';
import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_bloc.dart';
import 'package:apiarium/features/managment/hive_types/bloc/hive_types_event.dart';
import 'package:apiarium/features/managment/hive_types/hive_types_view.dart';
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
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
              tooltip: 'common.filter'.tr(),
            ),
          ],
        ),
        body: const HiveTypesView(),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Builder(
      builder: (context) => FloatingActionButton(
        onPressed: () => _handleAddHiveType(context),
        backgroundColor: Colors.amber,
        child: const Icon(Icons.add),
        tooltip: 'common.add'.tr(),
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('common.filter'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('hive_types.filter.starred_only'.tr()),
              leading: const Icon(Icons.star),
              onTap: () {
                context.read<HiveTypesBloc>().add(const FilterByStarred(true));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('hive_types.filter.local_only'.tr()),
              leading: const Icon(Icons.home),
              onTap: () {
                context.read<HiveTypesBloc>().add(const FilterByLocal(true));
                Navigator.pop(context);
              },
            ),
            const Divider(),
            ListTile(
              title: Text('edit_hive_type.material_wood'.tr()),
              leading: Icon(Icons.park, color: Colors.brown),
              onTap: () {
                context.read<HiveTypesBloc>().add(const FilterByMaterial(HiveMaterial.wood));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('edit_hive_type.material_plastic'.tr()),
              leading: Icon(Icons.recycling, color: Colors.blue),
              onTap: () {
                context.read<HiveTypesBloc>().add(const FilterByMaterial(HiveMaterial.plastic));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('edit_hive_type.material_polystyrene'.tr()),
              leading: Icon(Icons.science, color: Colors.green),
              onTap: () {
                context.read<HiveTypesBloc>().add(const FilterByMaterial(HiveMaterial.polystyrene));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('edit_hive_type.material_metal'.tr()),
              leading: Icon(Icons.hardware, color: Colors.grey),
              onTap: () {
                context.read<HiveTypesBloc>().add(const FilterByMaterial(HiveMaterial.metal));
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              context.read<HiveTypesBloc>().add(const FilterByStarred(null));
              context.read<HiveTypesBloc>().add(const FilterByLocal(null));
              context.read<HiveTypesBloc>().add(const FilterByMaterial(null));
              Navigator.pop(context);
            },
            child: Text('hive_types.filter.clear_all'.tr()),
          ),
        ],
      ),
    );
  }
}