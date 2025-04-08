import 'package:apiarium/features/managment/edit_queen/widgets/queen_breed_input_item.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_breed_list_item.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/add_queen_breed_dialog.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/edit_queen_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/dropdown/searchable_rounded_dropdown.dart';

class QueenBasicInfo extends StatefulWidget {
  const QueenBasicInfo({super.key});

  @override
  State<QueenBasicInfo> createState() => _QueenBasicInfoState();
}

class _QueenBasicInfoState extends State<QueenBasicInfo> {
  final _nameController = TextEditingController();
  bool _isDatePickerOpen = false;

  // Color codes for marking queens based on birth year
  static const List<Color> _markingColors = [
    Colors.white, // Years ending in 1, 6
    Colors.yellow, // Years ending in 2, 7
    Colors.red, // Years ending in 3, 8
    Colors.green, // Years ending in 4, 9
    Colors.blue, // Years ending in 0, 5
  ];

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<EditQueenBloc>().state.name;
  }

  @override
  Widget build(BuildContext context) {
    return EditQueenCard(
      title: 'Basic Information'.tr(),
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildName(),
          const SizedBox(height: 16),
          Text(
            'Queen Breed'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildBreed(),
          const SizedBox(height: 16),
          Text(
            'Birth Date'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildBirthDate(),
          const SizedBox(height: 16),
          Text(
            'Status'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildStatus(context),
          const SizedBox(height: 16),
          _buildMarkingOptions(),
        ],
      ),
    );
  }

  Widget _buildName() {
    final nameError = context.select(
      (EditQueenBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.name.trim().isEmpty
              ? 'Queen name is required'.tr()
              : null,
    );

    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Queen Name/Number'.tr(),
        border: const OutlineInputBorder(),
        errorText: nameError,
        errorBorder:
            nameError != null
                ? OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                  borderRadius: BorderRadius.circular(12),
                )
                : null,
      ),
      onChanged: (value) {
        context.read<EditQueenBloc>().add(EditQueenNameChanged(value.trim()));
      },
    );
  }

  Widget _buildBreed() {
    final availableBreeds = context.select(
      (EditQueenBloc bloc) => bloc.state.availableBreeds,
    );

    final selectedBreed = context.select(
      (EditQueenBloc bloc) => bloc.state.queenBreed,
    );

    final breedError = context.select(
      (EditQueenBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.queenBreed == null
              ? 'Queen breed is required'.tr()
              : null,
    );

    // Create a key that changes whenever the breed list or any breed's star status changes
    final dropdownKey = ValueKey(
      'breeds-${availableBreeds.length}-${DateTime.now().millisecondsSinceEpoch}',
    );

    return SearchableRoundedDropdown<QueenBreed>(
      key: dropdownKey,
      value: selectedBreed,
      items: availableBreeds,
      maxHeight: 300,
      minHeight: 56,
      hasError: breedError != null,
      errorText: breedError,
      onAddNewItem: () async {
        final result = await showDialog<QueenBreed>(
          context: context,
          builder: (context) => const AddQueenBreedDialog(),
        );

        if (result != null && mounted) {
          FocusManager.instance.primaryFocus?.unfocus();
          context.read<EditQueenBloc>().add(
            EditQueenCreateBreed(
              name: result.name,
              scientificName: result.scientificName,
              origin: result.origin,
              country: result.country,
              isStarred: result.isStarred,
            ),
          );
        }
      },
      itemBuilder: (context, item, isSelected) {
        return QueenBreedListItem(
          breed: item,
          isSelected: isSelected,
          onToggleStar: () {
            context.read<EditQueenBloc>().add(EditQueenToggleBreedStar(item));
          },
        );
      },
      buttonItemBuilder: (context, item) {
        return QueenBreedInputItem(
          breed: item,
        );
      },
      onChanged: (value) {
        if (value != null) {
          context.read<EditQueenBloc>().add(EditQueenBreedChanged(value));
        }
      },
    );
  }

  Widget _buildBirthDate() {
    final birthDate = context.select(
      (EditQueenBloc bloc) => bloc.state.birthDate,
    );
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final borderRadius =
        (inputTheme.border as OutlineInputBorder?)?.borderRadius ?? 
        BorderRadius.circular(12);
    final borderColor =
        _isDatePickerOpen
            ? Theme.of(context).colorScheme.primary
            : (inputTheme.border as OutlineInputBorder?)?.borderSide.color ?? 
                Colors.grey.shade300;

    return InkWell(
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        setState(() {
          _isDatePickerOpen = true;
        });

        final date = await showDatePicker(
          context: context,
          initialDate: birthDate,
          firstDate: DateTime(DateTime.now().year - 10),
          lastDate: DateTime.now(),
        );

        setState(() {
          _isDatePickerOpen = false;
        });

        if (date != null && mounted) {
          context.read<EditQueenBloc>().add(EditQueenBirthDateChanged(date));
        }
      },
      child: Container(
        padding:
            inputTheme.contentPadding ?? 
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: inputTheme.fillColor,
          borderRadius: borderRadius,
          border: Border.all(
            width: _isDatePickerOpen ? 2 : 1,
            color: borderColor,
          ),
        ),
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('yyyy-MM-dd').format(birthDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final status = context.select((EditQueenBloc bloc) => bloc.state.queenStatus);

    return RoundedDropdown<QueenStatus>(
      value: status,
      items: QueenStatus.values,
      onChanged: (value) {
        if (value != null) {
          context.read<EditQueenBloc>().add(EditQueenStatusChanged(value));
        }
      },
    );
  }

  Widget _buildMarkingOptions() {
    final marked = context.select((EditQueenBloc bloc) => bloc.state.marked);
    final markColor = context.select(
      (EditQueenBloc bloc) => bloc.state.markColor,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Checkbox(
              value: marked,
              onChanged: (bool? value) {
                if (value != null) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context.read<EditQueenBloc>().add(
                    EditQueenMarkedChanged(value),
                  );
                }
              },
            ),
            Text('Queen is marked'.tr()),
          ],
        ),
        if (marked) ...[
          const SizedBox(height: 8),
          Text('Mark Color'.tr(), style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children:
                _markingColors.map((color) {
                  final isSelected = markColor == color;
                  return GestureDetector(
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      context.read<EditQueenBloc>().add(
                        EditQueenMarkColorChanged(color),
                      );
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.grey,
                          width: isSelected ? 3 : 1,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
