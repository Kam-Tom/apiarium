import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:flutter_reorderable_grid_view/widgets/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/hive_mini_card.dart';

class ApiaryHivesGrid extends StatefulWidget {
  const ApiaryHivesGrid({super.key});

  @override
  State<ApiaryHivesGrid> createState() => _ApiaryHivesGridState();
}

class _ApiaryHivesGridState extends State<ApiaryHivesGrid> {
  final _scrollController = ScrollController();
  final _gridViewKey = GlobalKey();
  Hive? _selectedHive;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hives = context.select((EditApiaryBloc bloc) => bloc.state.apiarySummaryHives);
    final addQueensWithHives = context.select((EditApiaryBloc bloc) => bloc.state.addQueensWithHives);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHivesHeader(addQueensWithHives),
        const SizedBox(height: 16),
        _buildHiveSelectors(context),
        const SizedBox(height: 16),
        hives.isEmpty
            ? _buildEmptyHivesMessage()
            : _buildHivesGrid(hives),
      ],
    );
  }

  Widget _buildHivesHeader(bool addQueensWithHives) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Hives'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Row(
          children: [
            Text(
              'Add queens with hives'.tr(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(width: 8),
            Switch(
              value: addQueensWithHives,
              activeColor: Colors.amber.shade700,
              onChanged: (value) {
                context.read<EditApiaryBloc>().add(
                  EditApiaryAddQueensWithHivesToggled(value),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHiveSelectors(BuildContext context) {
    final availableHives = context.select((EditApiaryBloc bloc) => bloc.state.availableHives);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Add existing hives:',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: RoundedDropdown<Hive>(
                value: _selectedHive,
                items: availableHives,
                minHeight: 48.0,
                onChanged: (hive) {
                  if (hive != null) {
                    context.read<EditApiaryBloc>().add(EditApiaryAddExistingHive(hive));
                    setState(() => _selectedHive = null);
                  }
                },
                itemBuilder: (context, hive, isSelected) => Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: hive.color ?? Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hive.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : null,
                        ),
                      ),
                    ),
                  ],
                ),
                buttonItemBuilder: (context, hive) => Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: hive.color ?? Colors.amber.shade100,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hive.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () => _handleAddHive(),
              icon: const Icon(Icons.add),
              label: const Text('New Hive'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyHivesMessage() {
    final addQueensWithHives = context.select((EditApiaryBloc bloc) => bloc.state.addQueensWithHives);

    return Container(
      height: 150,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hive_outlined,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No hives added yet',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _handleAddHive(),
            icon: const Icon(Icons.add_circle_outline),
            label: Text(
              addQueensWithHives ? 'Create hive with queen'.tr() : 'Create new hive'.tr(),
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  void _handleAddHive() {
    final addQueensWithHives = context.read<EditApiaryBloc>().state.addQueensWithHives;

    if (addQueensWithHives) {
      // Open create queen page first, then create hive
      _openCreateQueenPage(context);
    } else {
      // Open create hive page directly
      _openCreateHivePage(context);
    }
  }

  void _openCreateQueenPage(BuildContext context) async {
    final result = await context.push(AppRouter.editQueen, extra: {'hideLocation': true});

    if (result is Queen && context.mounted) {
      // After creating queen, open hive creation with the queen pre-selected
      _openCreateHivePageWithQueen(context, result.id);
    }
  }

  void _openCreateHivePageWithQueen(BuildContext context, String queenId) async {
    final result = await context.push(
      AppRouter.editHive,
      extra: {
        'hideLocation': true,
        'queenId': queenId,
      },
    );

    if (result is Hive && context.mounted) {
      context.read<EditApiaryBloc>().add(EditApiaryAddExistingHive(result));
    }
  }

  void _openCreateHivePage(BuildContext context) async {
    final result = await context.push(
      AppRouter.editHive,
      extra: {'hideLocation': true},
    );

    if (result is Hive && context.mounted) {
      context.read<EditApiaryBloc>().add(EditApiaryAddExistingHive(result));
    }
  }

  Widget _buildHivesGrid(List<Hive> hives) {
    final List<Widget> gridChildren = hives.map((hive) => HiveMiniCard(
      key: Key(hive.id),
      hive: hive,
    )).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current hives (drag to reorder):',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 250,
          child: ReorderableBuilder(
            scrollController: _scrollController,
            onReorder: (ReorderedListFunction reorderedListFunction) {
              final List<Hive> reorderedHives = List.from(hives);
              reorderedListFunction(reorderedHives);

              context.read<EditApiaryBloc>().add(EditApiaryReorderHives(reorderedHives));
            },
            builder: (children) {
              return GridView(
                key: _gridViewKey,
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 0.9,
                ),
                children: children,
              );
            },
            children: gridChildren,
          ),
        ),
      ],
    );
  }
}
