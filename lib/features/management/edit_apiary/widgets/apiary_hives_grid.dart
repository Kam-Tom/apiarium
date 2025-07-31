import 'package:apiarium/core/router/app_router.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/hive_mini_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/management/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:go_router/go_router.dart';

class ApiaryHivesGrid extends StatefulWidget {
  const ApiaryHivesGrid({super.key});

  @override
  State<ApiaryHivesGrid> createState() => _ApiaryHivesGridState();
}

class _ApiaryHivesGridState extends State<ApiaryHivesGrid> {
  final _scrollController = ScrollController();
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
          'hives'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Row(
          children: [
            Text(
              'edit_apiary.add_queens_with_hives'.tr(),
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
          'edit_apiary.add_existing_hives'.tr(),
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
              label: Text('edit_apiary.new_hive'.tr()),
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
            'edit_apiary.no_hives_added'.tr(),
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _handleAddHive(),
            icon: const Icon(Icons.add_circle_outline),
            label: Text(
              addQueensWithHives
                  ? 'edit_apiary.create_hive_with_queen'.tr()
                  : 'edit_apiary.create_new_hive'.tr(),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_apiary.current_hives'.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 8),
        Container(
          height: MediaQuery.of(context).size.height * 0.4,
          constraints: BoxConstraints(
            minHeight: 100,
            maxHeight: MediaQuery.of(context).size.height * 0.4,
          ),
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            padding: const EdgeInsets.all(8.0),
            itemCount: hives.length,
            onReorder: (oldIndex, newIndex) {
              if (oldIndex < newIndex) {
                newIndex -= 1;
              }
              final reorderedHives = List<Hive>.from(hives);
              final movedHive = reorderedHives.removeAt(oldIndex);
              reorderedHives.insert(newIndex, movedHive);

              final updatedHives = reorderedHives.asMap().entries.map((entry) {
                final index = entry.key;
                final hive = entry.value;
                return hive.copyWith(order: () => index + 1);
              }).toList();

              context.read<EditApiaryBloc>().add(
                EditApiaryReorderHives(updatedHives),
              );
            },
            itemBuilder: (context, index) {
              final hive = hives[index];
              return Container(
                key: Key(hive.id),
                height: 135,
                margin: const EdgeInsets.only(bottom: 6),
                child: HiveMiniCard(hive: hive),
              );
            },
          ),
        ),
      ],
    );
  }
}