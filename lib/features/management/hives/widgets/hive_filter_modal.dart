import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/management/hives/bloc/hives_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveFilterModal extends StatelessWidget {
  const HiveFilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HivesBloc, HivesState>(
      builder: (context, state) {
        final hivesBloc = context.read<HivesBloc>();
        final List<HiveType> availableHiveTypes = state.availableHiveTypes ?? [];
        final selectedHiveType = state.filter.hiveTypeId != null
            ? availableHiveTypes.where((t) => t.id == state.filter.hiveTypeId).firstOrNull
            : null;

        return Dialog(
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
                        '${'common.filter'.tr()} ${'hives'.tr()}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('hive_type'.tr(), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SearchableRoundedDropdown<HiveType?>(
                    value: selectedHiveType,
                    items: [null, ...availableHiveTypes],
                    hintText: 'common.any'.tr(),
                    minHeight: 56,
                    onChanged: (type) => hivesBloc.add(FilterByHiveTypeId(type?.id)),
                    searchMatchFn: (item, searchValue) {
                      if (item.value is! HiveType) return true;
                      final hiveType = item.value as HiveType;
                      final lowerSearch = searchValue.toLowerCase();
                      return hiveType.name.toLowerCase().contains(lowerSearch) ||
                          (hiveType.manufacturer?.toLowerCase().contains(lowerSearch) ?? false);
                    },
                    itemBuilder: (ctx, item, isSelected) => item == null
                        ? Text(
                            'common.any'.tr(),
                            style: TextStyle(
                              color: isSelected
                                  ? AppTheme.primaryColor
                                  : Theme.of(context).textTheme.bodyMedium?.color,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          )
                        : HiveTypeDropdownItem(hiveType: item, isSelected: isSelected),
                    buttonItemBuilder: (ctx, item) => item == null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('common.any'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:FontWeight.bold,
                      ))],
                          )
                        : HiveTypeDropdownItem(
                            hiveType: item,
                            isSelected: true,
                            colorizeSelected: false,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text('queen_status'.tr(), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  RoundedDropdown<String?>(
                    value: state.filter.queenStatus,
                    items: [
                      null,
                      'withQueen',
                      'noQueen',
                    ],
                    hintText: 'common.any'.tr(),
                    onChanged: (value) => hivesBloc.add(FilterByQueenStatus(value)),
                    itemBuilder: (ctx, value, isSelected) {
                      String text;
                      if (value == null) {
                        text = 'common.any'.tr();
                      } else if (value == 'withQueen') {
                        text = 'queen_status.withQueen'.tr();
                      } else if (value == 'noQueen') {
                        text = 'queen_status.noQueen'.tr();
                      } else {
                        text = value;
                      }
                      return Text(
                        text,
                        style: TextStyle(
                          color: isSelected ? AppTheme.primaryColor : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      );
                    },
                    buttonItemBuilder: (context, item) {
                      String text;
                      if (item == null) {
                        text = 'common.any'.tr();
                      } else if (item == 'withQueen') {
                        text = 'queen_status.withQueen'.tr();
                      } else if (item == 'noQueen') {
                        text = 'queen_status.noQueen'.tr();
                      } else {
                        text = item;
                      }
                      return Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        text,
                        style:  Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:FontWeight.bold,
                      ),
                      ),
                    );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text('hive_status'.tr(), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  RoundedDropdown<HiveStatus?>(
                    value: state.filter.hiveStatus,
                    items: [null, ...HiveStatus.values],
                    hintText: 'common.any'.tr(),
                    onChanged: (value) => hivesBloc.add(FilterByHiveStatus(value)),
                    translate: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          hivesBloc.add(const ResetFilters());
                        },
                        child: Text('common.reset'.tr()),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
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
        );
      },
    );
  }
}