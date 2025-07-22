import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_bloc.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_event.dart';
import 'package:apiarium/features/managment/queens/bloc/queens_state.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/dropdown/queen_breed_dropdown_item.dart';
import 'package:apiarium/shared/widgets/dropdown/searchable_rounded_dropdown.dart';

class QueenFilterModal extends StatelessWidget {
  const QueenFilterModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: BlocBuilder<QueensBloc, QueensState>(
          builder: (context, state) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildFilters(context, state),
              const SizedBox(height: 20),
              _buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Icon(Icons.filter_list, color: AppTheme.primaryColor),
        const SizedBox(width: 8),
        Text(
          'Filter Queens',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(BuildContext context, QueensState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterSection(
          context,
          title: 'Status',
          child: _buildStatusFilter(context, state),
        ),
        const SizedBox(height: 16),
        _buildFilterSection(
          context,
          title: 'Breed',
          child: _buildBreedFilter(context, state),
        ),
      ],
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildStatusFilter(BuildContext context, QueensState state) {
    final statusOptions = [null, ...QueenStatus.values];

    return RoundedDropdown<QueenStatus?>(
      value: state.filter.status,
      items: statusOptions,
      hintText: 'common.any'.tr(),
      onChanged: (status) =>
          context.read<QueensBloc>().add(FilterByStatus(status)),
      translate: true,
    );
  }

  Widget _buildBreedFilter(BuildContext context, QueensState state) {
    final breeds = [null, ...state.availableBreeds];
    final selectedBreed = state.filter.breedId != null
        ? state.availableBreeds
              .where((b) => b.id == state.filter.breedId)
              .firstOrNull
        : null;

    return SearchableRoundedDropdown<QueenBreed?>(
      value: selectedBreed,
      items: breeds,
      hintText: 'common.any'.tr(),
      minHeight: 56,
      onChanged: (breed) =>
          context.read<QueensBloc>().add(FilterByBreed(breed?.id)),
      searchMatchFn: (item, searchValue) {
        if(item.value is! QueenBreed) return true;
        final breed = item.value as QueenBreed;
        final lowerSearch = searchValue.toLowerCase();
        return breed.name.toLowerCase().contains(lowerSearch) ||
            (breed.scientificName?.toLowerCase().contains(lowerSearch) ??
                false) ||
            (breed.origin?.toLowerCase().contains(lowerSearch) ?? false);
      },

      itemBuilder: (ctx, item, isSelected) => item == null
          ? Text(
              'common.any'.tr(),
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontStyle: FontStyle.normal,
              ),
            )
          : QueenBreedDropdownItem(breed: item, isSelected: isSelected),
      buttonItemBuilder: (ctx, item) => item == null
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('common.any'.tr())],
            )
          : QueenBreedDropdownItem(
              breed: item,
              isSelected: true,
              colorizeSelected: false,
            ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => context.read<QueensBloc>().add(ResetFilters()),
          child: Text('common.reset'.tr()),
        ),
        const SizedBox(width: 12),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text('common.close'.tr()),
        ),
      ],
    );
  }
}
