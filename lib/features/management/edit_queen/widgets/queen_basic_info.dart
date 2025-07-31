import 'package:apiarium/features/management/edit_queen/bloc/edit_queen_bloc.dart';
import 'package:apiarium/features/management/edit_queen/widgets/edit_queen_card.dart';
import 'package:apiarium/shared/domain/enums/queen_status.dart';
import 'package:apiarium/shared/domain/models/queen_breed.dart';
import 'package:apiarium/shared/widgets/dropdown/queen_breed_dropdown_item.dart';
import 'package:apiarium/shared/widgets/dropdown/rounded_dropdown.dart';
import 'package:apiarium/shared/widgets/dropdown/searchable_rounded_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class QueenBasicInfo extends StatefulWidget {
  const QueenBasicInfo({super.key});

  @override
  State<QueenBasicInfo> createState() => _QueenBasicInfoState();
}

class _QueenBasicInfoState extends State<QueenBasicInfo> {
  final _nameController = TextEditingController();
  bool _isDatePickerOpen = false;

  static const List<Color> _markingColors = [
    Colors.white,
    Colors.yellow,
    Colors.red,
    Colors.green,
    Colors.blue,
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<EditQueenBloc>().state;
    // If name is empty, set a default generated name (for consistency)
    if (state.name.isEmpty) {
      context.read<EditQueenBloc>().add(const EditQueenGenerateName());
    }
    _nameController.text = state.name;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditQueenBloc, EditQueenState>(
      listenWhen: (previous, current) => previous.name != current.name,
      listener: (context, state) {
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
      },
      child: EditQueenCard(
        title: 'edit_queen.title'.tr(),
        icon: Icons.info_outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add a section title above the name input for consistency
            Text(
              'edit_queen.name_label'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildName(),
            const SizedBox(height: 16),
            Text(
              'edit_queen.breed'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildBreed(),
            const SizedBox(height: 16),
            Text(
              'edit_queen.birth_date'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildBirthDate(),
            const SizedBox(height: 16),
            _buildStatus(context),
            const SizedBox(height: 16),
            _buildMarkingOptions(),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'edit_queen.name_label'.tr(),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        suffixIcon: IconButton(
          onPressed: () {
            context.read<EditQueenBloc>().add(const EditQueenGenerateName());
          },
          icon: Icon(
            Icons.refresh,
            color: Colors.grey.shade600,
          ),
          tooltip: 'edit_queen.generate_name'.tr(),
        ),
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
    return SearchableRoundedDropdown<QueenBreed>(
      value: selectedBreed,
      items: availableBreeds,
      minHeight: 56,
      hintText: 'edit_queen.breed_hint'.tr(),
      searchHintText: 'edit_queen.breed_search_hint'.tr(),
      onChanged: (value) {
        if (value != null) {
          context.read<EditQueenBloc>().add(EditQueenBreedChanged(value));
        }
      },
      searchMatchFn: (item, searchValue) {
        final breed = item.value as QueenBreed;
        final lowerSearch = searchValue.toLowerCase();
        return breed.name.toLowerCase().contains(lowerSearch) ||
               (breed.scientificName?.toLowerCase().contains(lowerSearch) ?? false) ||
               (breed.origin?.toLowerCase().contains(lowerSearch) ?? false);
      },
      itemBuilder: (ctx, item, isSelected) =>
        QueenBreedDropdownItem(breed: item, isSelected: isSelected),
      buttonItemBuilder: (ctx, item) =>
        QueenBreedDropdownItem(
          breed: item,
          isSelected: true,
          colorizeSelected: false,
        ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_queen.status'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        RoundedDropdown<QueenStatus>(
          value: status,
          items: QueenStatus.values,
          onChanged: (value) {
            if (value != null) {
              context.read<EditQueenBloc>().add(EditQueenStatusChanged(value));
            }
          },
          translate: true,
          itemBuilder: null,
          buttonItemBuilder: null,
        ),
      ],
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
            Text('edit_queen.marked'.tr()),
          ],
        ),
        if (marked) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text('edit_queen.mark_color'.tr(), style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Icon(
                Icons.info_outline,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'edit_queen.mark_color_auto'.tr(),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            children: _markingColors.map((color) {
              final isSelected = markColor?.toARGB32() == color.toARGB32();
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
                  child: isSelected && color == markColor
                      ? Icon(
                          Icons.check,
                          color: color == Colors.white || color == Colors.yellow
                              ? Colors.black
                              : Colors.white,
                          size: 20,
                        )
                      : null,
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

