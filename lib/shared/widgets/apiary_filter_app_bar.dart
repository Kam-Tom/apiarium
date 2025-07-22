import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/cubits/apiary_filter_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ApiaryFilterAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onFilterPressed;
  final VoidCallback onSortPressed;
  final Function(String?) onApiaryChanged;

  const ApiaryFilterAppBar({
    super.key,
    required this.title,
    required this.onFilterPressed,
    required this.onSortPressed,
    required this.onApiaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiaryFilterCubit, ApiaryFilterState>(
      builder: (context, apiaryState) {
        return AppBar(
          title: Text(title),
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
              onPressed: onFilterPressed,
              tooltip: 'common.filter'.tr(),
            ),
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: onSortPressed,
              tooltip: 'common.sort'.tr(),
            ),
          ],
          bottom: apiaryState.availableApiaries.isNotEmpty
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(56),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.white70),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RoundedDropdown<String?>(
                            value: apiaryState.selectedApiaryId ?? 'all',
                            items: [
                              'all',
                              'none',
                              ...apiaryState.availableApiaries.map((a) => a.id)
                            ],
                            hintText: 'apiary.filter.select'.tr(),
                            onChanged: (value) => _handleApiaryFilterChange(context, value),
                            itemBuilder: (context, value, isSelected) =>
                                _buildDropdownItem(value, isSelected, apiaryState.availableApiaries, context),
                            buttonItemBuilder: (context, value) =>
                                _buildButtonItem(value, apiaryState.availableApiaries, context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  void _handleApiaryFilterChange(BuildContext context, String? value) {
    String? apiaryId = switch (value) {
      'all' => null,
      'none' => 'none',
      _ => value,
    };

    context.read<ApiaryFilterCubit>().selectApiary(apiaryId);
    onApiaryChanged(apiaryId);
  }

  Widget _buildDropdownItem(
    String? value,
    bool isSelected,
    List<Apiary> availableApiaries,
    BuildContext context, {
    bool colorizeSelected = true,
  }) {
    return Text(
      _getDisplayText(value, availableApiaries),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isSelected && colorizeSelected ? Theme.of(context).colorScheme.primary : null,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
    );
  }

  Widget _buildButtonItem(
    String? value,
    List<Apiary> availableApiaries,
    BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _getDisplayText(value, availableApiaries),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  String _getDisplayText(String? value, List<Apiary> availableApiaries) {
    return switch (value) {
      'all' => 'apiary.filter.all'.tr(),
      'none' => 'apiary.filter.none'.tr(),
      _ => availableApiaries.firstWhere((a) => a.id == value).name,
    };
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 56);
}
