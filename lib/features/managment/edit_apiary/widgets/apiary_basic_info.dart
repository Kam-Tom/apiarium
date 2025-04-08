import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/edit_apiary_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';

class ApiaryBasicInfo extends StatefulWidget {
  const ApiaryBasicInfo({super.key});

  @override
  State<ApiaryBasicInfo> createState() => _ApiaryBasicInfoState();
}

class _ApiaryBasicInfoState extends State<ApiaryBasicInfo> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = context.read<EditApiaryBloc>().state.name;
    _descriptionController.text = context.read<EditApiaryBloc>().state.description;
  }

  @override
  Widget build(BuildContext context) {
    return EditApiaryCard(
      title: 'Basic Information'.tr(),
      icon: Icons.info_outline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildName(),
          const SizedBox(height: 16),
          _buildDescription(),
          const SizedBox(height: 16),
          _buildColorPicker(),
        ],
      ),
    );
  }

  Widget _buildName() {
    final nameError = context.select(
      (EditApiaryBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.name.trim().isEmpty
              ? 'Apiary name is required'.tr()
              : null,
    );

    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'Apiary Name'.tr(),
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
        context.read<EditApiaryBloc>().add(EditApiaryNameChanged(value.trim()));
      },
    );
  }

  Widget _buildDescription() {
    return TextFormField(
      controller: _descriptionController,
      decoration: InputDecoration(
        labelText: 'Description'.tr(),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      onChanged: (value) {
        context.read<EditApiaryBloc>().add(EditApiaryDescriptionChanged(value.trim()));
      },
    );
  }

  Widget _buildColorPicker() {
    final color = context.select((EditApiaryBloc bloc) => bloc.state.color);
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
          'Apiary Color'.tr(),
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
                      .read<EditApiaryBloc>()
                      .add(EditApiaryColorChanged(predefinedColor));
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
                context.read<EditApiaryBloc>().add(const EditApiaryColorChanged(null));
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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
