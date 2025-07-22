import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/dropdown/hive_type_dropdown_item.dart';
import 'package:apiarium/shared/widgets/dropdown/rounded_dropdown.dart';

class HiveBasicInfo extends StatefulWidget {
  const HiveBasicInfo({super.key});

  @override
  State<HiveBasicInfo> createState() => _HiveBasicInfoState();
}

class _HiveBasicInfoState extends State<HiveBasicInfo> {
  final _nameController = TextEditingController();
  bool _isDatePickerOpen = false;
  bool _showColorPicker = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<EditHiveBloc>().state;
    // If name is empty, set a default generated name (for consistency)
    if (state.name.isEmpty) {
      // This will be replaced by the generated name event if needed
      context.read<EditHiveBloc>().add(EditHiveGenerateName());
    }
    _nameController.text = state.name;
    _showColorPicker = state.color != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditHiveBloc, EditHiveState>(
      listenWhen: (prev, curr) => prev.name != curr.name,
      listener: (context, state) {
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
      },
      child: EditHiveCard(
        title: 'edit_hive.basic_information'.tr(),
        icon: Icons.info_outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add a section title above the name input for consistency
            Text(
              'edit_hive.name_title'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildName(),
            const SizedBox(height: 16),
            _buildHiveTypeDropdown(),
            const SizedBox(height: 16),
            Text(
              'edit_hive.acquisition_date_title'.tr(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildAcquisitionDate(),
            const SizedBox(height: 16),
            _buildColorToggle(),
            if (_showColorPicker) ...[
              const SizedBox(height: 8),
              _buildColorPicker(),
            ],
            const SizedBox(height: 16),
            _buildStatus(),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    final nameError = context.select(
      (EditHiveBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.name.trim().isEmpty
              ? 'edit_hive.name_required'.tr()
              : null,
    );
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'edit_hive.name_label'.tr(),
        border: const OutlineInputBorder(),
        errorText: nameError,
        suffixIcon: IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          tooltip: 'edit_hive.generate_name'.tr(),
          onPressed: () {
            context.read<EditHiveBloc>().add(EditHiveGenerateName());
          },
        ),
      ),
      onChanged: (value) {
        context.read<EditHiveBloc>().add(EditHiveNameChanged(value.trim()));
      },
    );
  }

  Widget _buildHiveTypeDropdown() {
    final availableHiveTypes = context.select((EditHiveBloc bloc) => bloc.state.availableHiveTypes);
    final selectedHiveType = context.select((EditHiveBloc bloc) => bloc.state.hiveType);

    final hasTypes = availableHiveTypes.isNotEmpty;
    final items = hasTypes
        ? availableHiveTypes
        : <HiveType?>[null];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_hive.hive_type'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        RoundedDropdown<HiveType>(
          value: hasTypes ? selectedHiveType : null,
          items: hasTypes ? availableHiveTypes : <HiveType>[],
          onChanged: hasTypes
              ? (value) {
                  if (value != null) {
                    context.read<EditHiveBloc>().add(EditHiveTypeChanged(value));
                  }
                }
              : (_) {}, // Provide a dummy function when disabled
          hintText: hasTypes ? 'edit_hive.hive_type_hint' : 'edit_hive.no_hive_types',
          itemBuilder: null,
          buttonItemBuilder: null,
        ),
      ],
    );
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
          context.read<EditHiveBloc>().add(EditHiveAcquisitionDateChanged(date));
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

  Widget _buildColorToggle() {
    final color = context.select((EditHiveBloc bloc) => bloc.state.color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Switch(
              value: _showColorPicker,
              onChanged: (val) {
                setState(() {
                  _showColorPicker = val;
                  if (!val) {
                    context.read<EditHiveBloc>().add(const EditHiveColorChanged(null));
                  }
                });
              },
            ),
            Text('edit_hive.add_color'.tr()),
          ],
        ),
        if (_showColorPicker && color == null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, top: 4.0),
            child: Text(
              'edit_hive.no_color_selected'.tr(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
      ],
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
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...predefinedColors.map((predefinedColor) {
          final isSelected = color?.value == predefinedColor.value;
          return GestureDetector(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              context.read<EditHiveBloc>().add(EditHiveColorChanged(predefinedColor));
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
              child: isSelected
                  ? Icon(
                      Icons.check,
                      color: predefinedColor == Colors.white || predefinedColor == Colors.yellow
                          ? Colors.black
                          : Colors.white,
                      size: 20,
                    )
                  : null,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatus() {
    final status = context.select((EditHiveBloc bloc) => bloc.state.status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_hive.status'.tr(),
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
          translate: true,
          itemBuilder: null,
          buttonItemBuilder: null,
        ),
      ],
    );
  }

  String _formatStatus(HiveStatus status) {
    switch (status) {
      case HiveStatus.active:
        return 'edit_hive.status_active'.tr();
      case HiveStatus.inactive:
        return 'edit_hive.status_inactive'.tr();
      case HiveStatus.archived:
        return 'edit_hive.status_archived'.tr();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}