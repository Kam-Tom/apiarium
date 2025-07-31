import 'dart:io';

import 'package:apiarium/features/management/edit_hive_type/bloc/edit_hive_type_bloc.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class EditHiveTypeView extends StatefulWidget {
  const EditHiveTypeView({super.key});

  @override
  State<EditHiveTypeView> createState() => _EditHiveTypeViewState();
}

class _EditHiveTypeViewState extends State<EditHiveTypeView> {
  final _nameController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _costController = TextEditingController();
  final _frameStandardController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final state = context.read<EditHiveTypeBloc>().state;
    _nameController.text = state.name;
    _manufacturerController.text = state.manufacturer ?? '';
    _costController.text = state.cost?.toString() ?? '';
    _frameStandardController.text = state.frameStandard ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditHiveTypeBloc, EditHiveTypeState>(
      listenWhen: (previous, current) =>
        (current.status == EditHiveTypeStatus.success && previous.status != current.status) ||
        (current.status == EditHiveTypeStatus.failure && previous.status != current.status) ||
        (current.showValidationErrors && !previous.showValidationErrors),
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state.status == EditHiveTypeStatus.initial ||
            state.status == EditHiveTypeStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: Colors.grey.shade50,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(state),
                const SizedBox(height: 16),
                _buildBasicInfoCard(state),
                const SizedBox(height: 16),
                if (state.hasFrames) ...[
                  _buildFrameInfoCard(state),
                  const SizedBox(height: 16),
                  _buildCapacityCard(state),
                  const SizedBox(height: 16),
                ],
                _buildAccessoriesCard(state),
                const SizedBox(height: 16),
                _buildCostCard(state),
                const SizedBox(height: 32),
                SubmitButton(
                  text: 'edit_hive_type.save'.tr(),
                  isSubmitting: state.status == EditHiveTypeStatus.submitting,
                  onPressed: () => context.read<EditHiveTypeBloc>().add(const EditHiveTypeSubmitted()),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(EditHiveTypeState state) {
    return FormCard(
      title: state.name.isEmpty ? 'edit_hive_type.title'.tr() : state.name,
      // Replace icon with HiveIcons
      icon: null, // Remove the old icon
      iconWidget: HiveIcons(
        icon: HiveIconType.beehive1,
        size: 32,
        color: Colors.amber.shade700,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildHeaderImage(state),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.name.isEmpty ? 'edit_hive_type.title'.tr() : state.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (state.manufacturer != null && state.manufacturer!.isNotEmpty)
                      Text(
                        state.manufacturer!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    const SizedBox(height: 8),
                    _buildBadges(state),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<EditHiveTypeBloc>().add(const EditHiveTypeToggleStarred());
                },
                icon: Icon(
                  state.isStarred ? Icons.star : Icons.star_border,
                  color: state.isStarred ? Colors.amber : Colors.grey,
                  size: 28,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage(EditHiveTypeState state) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.amber.shade50,
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: state.imageName != null && state.imageName!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(state.imageName!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Replace Icon with HiveIcons
                  return HiveIcons(
                    icon: state.iconType,
                    size: 40,
                    color: _getMaterialColor(state.material),
                  );
                },
              ),
            )
          : HiveIcons(
              icon: state.iconType,
              size: 40,
              color: _getMaterialColor(state.material),
            ),
    );
  }

  Widget _buildBadges(EditHiveTypeState state) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: [
        if (state.isStarred)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.amber.shade700, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Starred',
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        if (state.isLocal)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Local',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getMaterialColor(state.material).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getMaterialName(state.material),
            style: TextStyle(
              color: _getMaterialColor(state.material),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard(EditHiveTypeState state) {
    return FormCard(
      title: 'edit_hive_type.basic_information'.tr(),
      icon: Icons.info_outline,
      iconColor: Colors.blue.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_hive_type.name'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'edit_hive_type.name'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.showValidationErrors && state.name.trim().isEmpty 
                      ? Colors.red 
                      : Colors.grey.shade300,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.showValidationErrors && state.name.trim().isEmpty 
                      ? Colors.red 
                      : Colors.grey.shade300,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: state.showValidationErrors && state.name.trim().isEmpty 
                      ? Colors.red 
                      : Theme.of(context).primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              errorText: state.showValidationErrors && state.name.trim().isEmpty 
                  ? 'edit_hive_type.name_required'.tr() 
                  : null,
            ),
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(EditHiveTypeNameChanged(value));
            },
          ),
          const SizedBox(height: 16),
          Text(
            'edit_hive_type.manufacturer'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _manufacturerController,
            decoration: InputDecoration(
              labelText: 'edit_hive_type.manufacturer'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            ),
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeManufacturerChanged(value.isEmpty ? null : value),
              );
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'edit_hive_type.material'.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              RoundedDropdown<HiveMaterial>(
                value: state.material,
                items: HiveMaterial.values,
                onChanged: (value) {
                  if (value != null) {
                    context.read<EditHiveTypeBloc>().add(EditHiveTypeMaterialChanged(value));
                  }
                },
                itemBuilder: (context, material, isSelected) => Text(_getMaterialName(material)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildImageSection(state),
          const SizedBox(height: 16),
          _buildIconSection(state),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: state.hasFrames,
                onChanged: (value) {
                  if (value != null) {
                    context.read<EditHiveTypeBloc>().add(EditHiveTypeHasFramesChanged(value));
                  }
                },
              ),
              Text('edit_hive_type.has_frames'.tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconSection(EditHiveTypeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_hive_type.icon'.tr(),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        RoundedDropdown<HiveIconType>(
          value: state.iconType,
          items: HiveIconType.values,
          onChanged: (value) {
            if (value != null) {
              context.read<EditHiveTypeBloc>().add(EditHiveTypeIconChanged(value));
            }
          },
          itemBuilder: (context, iconType, isSelected) => Row(
            children: [
              HiveIcons(icon: iconType, size: 20),
              const SizedBox(width: 8),
              Text('${HiveIconType.values.indexOf(iconType)}'),
            ],
          ),
          buttonItemBuilder: (context, iconType) => Row(
            children: [
              HiveIcons(icon: iconType, size: 20),
              const SizedBox(width: 8),
              Text('${HiveIconType.values.indexOf(iconType)}'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrameInfoCard(EditHiveTypeState state) {
    return FormCard(
      title: 'edit_hive_type.frame_information'.tr(),
      icon: Icons.grid_view,
      iconColor: Colors.orange.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_hive_type.frame_standard'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _frameStandardController,
            decoration: InputDecoration(
              labelText: 'edit_hive_type.frame_standard'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              helperText: 'edit_hive_type.frame_standard_help'.tr(),
            ),
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeFrameStandardChanged(value.isEmpty ? null : value),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'edit_hive_type.frames_per_box'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          NumericInputField(
            labelText: '',
            helperText: 'edit_hive_type.frames_per_box_help'.tr(),
            value: (state.framesPerBox ?? 0).toDouble(),
            min: 0,
            max: 50,
            allowDecimal: false,
            allowNegative: false,
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(EditHiveTypeFramesPerBoxChanged(value == 0 ? null : value.round()));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityCard(EditHiveTypeState state) {
    return FormCard(
      title: 'edit_hive_type.capacity_information'.tr(),
      icon: Icons.layers,
      iconColor: Colors.green.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_hive_type.brood_frames'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          NumericInputField(
            labelText: '',
            value: (state.broodFrameCount ?? 0).toDouble(),
            min: 0,
            max: 100,
            allowDecimal: false,
            allowNegative: false,
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeBroodFrameCountChanged(value.round()),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            'edit_hive_type.honey_frames'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          NumericInputField(
            labelText: '',
            value: (state.honeyFrameCount ?? 0).toDouble(),
            min: 0,
            max: 100,
            allowDecimal: false,
            allowNegative: false,
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeHoneyFrameCountChanged(value.round()),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'edit_hive_type.brood_boxes'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    NumericInputField(
                      labelText: '',
                      value: (state.boxCount ?? 0).toDouble(),
                      min: 0,
                      max: 20,
                      allowDecimal: false,
                      allowNegative: false,
                      onChanged: (value) {
                        context.read<EditHiveTypeBloc>().add(EditHiveTypeBoxCountChanged(value.round()));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'edit_hive_type.super_boxes'.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    NumericInputField(
                      labelText: '',
                      value: (state.superBoxCount ?? 0).toDouble(),
                      min: 0,
                      max: 20,
                      allowDecimal: false,
                      allowNegative: false,
                      onChanged: (value) {
                        context.read<EditHiveTypeBloc>().add(EditHiveTypeSuperBoxCountChanged(value.round()));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCostCard(EditHiveTypeState state) {
    return FormCard(
      title: 'edit_hive_type.cost_information'.tr(),
      icon: Icons.attach_money,
      iconColor: Colors.purple.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'edit_hive_type.cost'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          NumericInputField(
            labelText: '',
            value: state.cost ?? 0.0,
            min: 0.0,
            max: 99999.99,
            allowDecimal: true,
            allowNegative: false,
            decimalPlaces: 2,
            step: 1,
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(EditHiveTypeCostChanged(value));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(EditHiveTypeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_hive_type.hive_type_image'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (state.imageName != null) ...[
          _buildImagePreview(state.imageName!),
          const SizedBox(height: 8),
        ],
        _buildImageButtons(state.imageName),
      ],
    );
  }

  Widget _buildImagePreview(String imageUrl) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(imageUrl),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error, size: 50),
        ),
      ),
    );
  }

  Widget _buildImageButtons(String? imageUrl) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: Text('edit_hive_type.gallery'.tr()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text('edit_hive_type.camera'.tr()),
          ),
        ),
        if (imageUrl != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              context.read<EditHiveTypeBloc>().add(const EditHiveTypeImageDeleted());
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'edit_hive_type.remove_image'.tr(),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        context.read<EditHiveTypeBloc>().add(EditHiveTypeImageChanged(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('edit_hive_type.failed_pick_image'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildAccessoriesCard(EditHiveTypeState state) {
    // Group accessories by category
    final physicalAccessories = HiveAccessory.values.where((a) => a.category == 'accessories.physical'.tr()).toList();
    final iotAccessories = HiveAccessory.values.where((a) => a.category == 'accessories.iot_devices'.tr()).toList();

    return FormCard(
      title: 'edit_hive_type.accessories'.tr(),
      icon: Icons.extension,
      iconColor: Colors.teal.shade700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Physical Accessories Section
          Text(
            'accessories.physical'.tr(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 8),
          MultiSelectDropdown<HiveAccessory>(
            items: physicalAccessories,
            selectedItems: state.accessories?.where((a) => physicalAccessories.contains(a)).toList() ?? [],
            onChanged: (selectedPhysical) {
              final selectedIoT = state.accessories?.where((a) => iotAccessories.contains(a)).toList() ?? [];
              final allSelected = [...selectedPhysical, ...selectedIoT];
              context.read<EditHiveTypeBloc>().add(EditHiveTypeAccessoriesChanged(allSelected));
            },
            itemLabelBuilder: (accessory) => accessory.displayName,
            hintText: 'Select physical accessories...',
            maxHeight: 200,
          ),
          const SizedBox(height: 16),
          // IoT Devices Section
          Text(
            'accessories.iot_devices'.tr(),
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.teal.shade700,
            ),
          ),
          const SizedBox(height: 8),
          MultiSelectDropdown<HiveAccessory>(
            items: iotAccessories,
            selectedItems: state.accessories?.where((a) => iotAccessories.contains(a)).toList() ?? [],
            onChanged: (selectedIoT) {
              final selectedPhysical = state.accessories?.where((a) => physicalAccessories.contains(a)).toList() ?? [];
              final allSelected = [...selectedPhysical, ...selectedIoT];
              context.read<EditHiveTypeBloc>().add(EditHiveTypeAccessoriesChanged(allSelected));
            },
            itemLabelBuilder: (accessory) => accessory.displayName,
            hintText: 'edit_hive_type.select_iot_accessories'.tr(),
            maxHeight: 200,
          ),
        ],
      ),
    );
  }

  Color _getMaterialColor(HiveMaterial material) {
    switch (material) {
      case HiveMaterial.wood:
        return Colors.brown;
      case HiveMaterial.plastic:
        return Colors.blue;
      case HiveMaterial.polystyrene:
        return Colors.green;
      case HiveMaterial.metal:
        return Colors.grey;
      case HiveMaterial.other:
        return Colors.orange;
    }
  }

  String _getMaterialName(HiveMaterial material) {
    switch (material) {
      case HiveMaterial.wood:
        return 'edit_hive_type.material_wood'.tr();
      case HiveMaterial.plastic:
        return 'edit_hive_type.material_plastic'.tr();
      case HiveMaterial.polystyrene:
        return 'edit_hive_type.material_polystyrene'.tr();
      case HiveMaterial.metal:
        return 'edit_hive_type.material_metal'.tr();
      case HiveMaterial.other:
        return 'edit_hive_type.material_other'.tr();
    }
  }

  void _handleStateChanges(BuildContext context, EditHiveTypeState state) {
    if (state.status == EditHiveTypeStatus.success) {
      ToastUtils.showSuccess(context, 'edit_hive_type.saved_success'.tr());
      Navigator.of(context).pop(true);
      return;
    }

    if (state.status == EditHiveTypeStatus.failure && state.errorMessage != null) {
      ToastUtils.showError(context, state.errorMessage!);
      return;
    }

    if (state.showValidationErrors && !state.isValid) {
      ScrollUtils.scrollToTop(_scrollController);
      ToastUtils.showError(context, 'edit_hive_type.validation_errors'.tr());
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _manufacturerController.dispose();
    _costController.dispose();
    _frameStandardController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}