import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/add_hive_type_modal.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_type_input_item.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_type_list_item.dart';
import 'package:apiarium/shared/widgets/dropdown/searchable_rounded_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/shared.dart';

class HiveBasicInfo extends StatefulWidget {
  const HiveBasicInfo({super.key});

  @override
  State<HiveBasicInfo> createState() => _HiveBasicInfoState();
}

class _HiveBasicInfoState extends State<HiveBasicInfo> {
  final _nameController = TextEditingController();
  bool _isDatePickerOpen = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<EditHiveBloc>().state.name;
  }

  @override
  Widget build(BuildContext context) {
    return EditHiveCard(
      title: 'Basic Information'.tr(),
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildName(),
          const SizedBox(height: 16),
          Text(
            'Hive Type'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildHiveType(),
          const SizedBox(height: 16),
          Text(
            'Acquisition Date'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          _buildAcquisitionDate(),
          const SizedBox(height: 16),
          _buildColorPicker(),
          const SizedBox(height: 16),
          _buildStatus(),
        ],
      ),
    );
  }

  Widget _buildName() {
    final nameError = context.select(
      (EditHiveBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.name.trim().isEmpty
              ? 'Hive name is required'.tr()
              : null,
    );

    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Hive Name/Number'.tr(),
        border: const OutlineInputBorder(),
        errorText: nameError,
        errorBorder: nameError != null
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
      ),
      onChanged: (value) {
        context.read<EditHiveBloc>().add(EditHiveNameChanged(value.trim()));
      },
    );
  }

  Widget _buildHiveType() {
    final hiveTypes = context.select((EditHiveBloc bloc) => bloc.state.availableHiveTypes);
    final selectedHiveType = context.select((EditHiveBloc bloc) => bloc.state.hiveType);

    final typeError = context.select(
      (EditHiveBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.hiveType == null
              ? 'Hive type is required'.tr()
              : null,
    );

    // Create a key that changes whenever the hive type list or any type's star status changes
    final dropdownKey = ValueKey(
      'breeds-${hiveTypes.length}-${DateTime.now().millisecondsSinceEpoch}',
    );


    return SearchableRoundedDropdown<HiveType>(
      key: dropdownKey,
      value: selectedHiveType,
      items: hiveTypes,
      hasError: typeError != null,
      errorText: typeError,
      maxHeight: 300,
      onChanged: (value) {
        if (value != null) {
          context.read<EditHiveBloc>().add(EditHiveTypeChanged(value));
        }
      },
      onAddNewItem: () {
        _showAddHiveTypeModal();
      },
      itemBuilder: (context, item, isSelected) => HiveTypeListItem(
        type: item, 
        isSelected: isSelected, 
        onToggleStar: () {
          context.read<EditHiveBloc>().add(EditHiveToggleStarHiveType(item));
        }
      ),
      buttonItemBuilder: (context, item) => HiveTypeInputItem(
        type: item, 
      ),
    );
  }
  
  void _showAddHiveTypeModal() async {
    final hiveType = await showDialog<HiveType>(
      context: context,
      builder: (context) => const AddHiveTypeModal(),
    );

    if (hiveType != null && mounted) {
      FocusManager.instance.primaryFocus?.unfocus();
      context.read<EditHiveBloc>().add(EditHiveAddNewHiveType(hiveType));
    }
  }

  Widget _buildAcquisitionDate() {
    final acquisitionDate = context.select(
      (EditHiveBloc bloc) => bloc.state.acquisitionDate,
    );
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final borderRadius =
        (inputTheme.border as OutlineInputBorder?)?.borderRadius ?? 
            BorderRadius.circular(12);
    final borderColor = _isDatePickerOpen
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
          initialDate: acquisitionDate,
          firstDate: DateTime(DateTime.now().year - 10),
          lastDate: DateTime.now(),
        );

        setState(() {
          _isDatePickerOpen = false;
        });

        if (date != null && mounted) {
          context
              .read<EditHiveBloc>()
              .add(EditHiveAcquisitionDateChanged(date));
        }
      },
      child: Container(
        padding: inputTheme.contentPadding ?? 
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
              DateFormat('yyyy-MM-dd').format(acquisitionDate),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    final color = context.select((EditHiveBloc bloc) => bloc.state.color);
    final predefinedColors = [
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.red,
      Colors.purple,
      Colors.orange,
      Colors.white,
      Colors.brown,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hive Color'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...predefinedColors.map((predefinedColor) {
              final isSelected = color?.value == predefinedColor.value;
              return GestureDetector(
                onTap: () {
                  FocusManager.instance.primaryFocus?.unfocus();
                  context
                      .read<EditHiveBloc>()
                      .add(EditHiveColorChanged(predefinedColor));
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: predefinedColor,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey,
                      width: isSelected ? 3 : 1,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (predefinedColor == Colors.white)
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                    ],
                  ),
                ),
              );
            }),
            // No color option
            GestureDetector(
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                context.read<EditHiveBloc>().add(const EditHiveColorChanged(null));
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: color == null ? Colors.black : Colors.grey,
                    width: color == null ? 3 : 1,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.not_interested, size: 24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatus() {
    final status = context.select((EditHiveBloc bloc) => bloc.state.status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        RoundedDropdown<HiveStatus>(
          value: status,
          items: HiveStatus.values,
          onChanged: (value) {
            if (value != null) {
              context.read<EditHiveBloc>().add(EditHiveStatusChanged(value));
            }
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
