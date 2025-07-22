



import 'dart:io';

import 'package:apiarium/features/managment/edit_hive_type/bloc/edit_hive_type_bloc.dart';
import 'package:apiarium/shared/domain/enums/hive_material.dart';
import 'package:apiarium/shared/domain/models/hive_type.dart';
import 'package:apiarium/shared/utils/scroll_utils.dart';
import 'package:apiarium/shared/utils/toast_utils.dart';
import 'package:apiarium/shared/widgets/dropdown/rounded_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/widgets/form_card.dart';
import '../../../shared/widgets/numeric_input_field.dart';
import '../../../shared/widgets/submit_button.dart';

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
      icon: Icons.home_work,
      iconColor: Colors.amber.shade700,
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
                  return Icon(
                    state.icon,
                    size: 40,
                    color: _getMaterialColor(state.material),
                  );
                },
              ),
            )
          : Icon(
              state.icon,
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
          TextFormField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'edit_hive_type.name'.tr(),
              border: const OutlineInputBorder(),
              errorText: state.showValidationErrors && state.name.trim().isEmpty 
                  ? 'edit_hive_type.name_required'.tr() 
                  : null,
            ),
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(EditHiveTypeNameChanged(value));
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _manufacturerController,
            decoration: InputDecoration(
              labelText: 'edit_hive_type.manufacturer'.tr(),
              border: const OutlineInputBorder(),
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
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
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
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        RoundedDropdown<IconData>(
          value: state.icon,
          items: HiveType.availableIcons,
          onChanged: (value) {
            if (value != null) {
              context.read<EditHiveTypeBloc>().add(EditHiveTypeIconChanged(value));
            }
          },
          itemBuilder: (context, icon, isSelected) => Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text('Icon ${HiveType.availableIcons.indexOf(icon) + 1}'),
            ],
          ),
          buttonItemBuilder: (context, icon) => Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text('Icon ${HiveType.availableIcons.indexOf(icon) + 1}'),
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
          TextFormField(
            controller: _frameStandardController,
            decoration: InputDecoration(
              labelText: 'edit_hive_type.frame_standard'.tr(),
              border: const OutlineInputBorder(),
              helperText: 'edit_hive_type.frame_standard_help'.tr(),
            ),
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeFrameStandardChanged(value.isEmpty ? null : value),
              );
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'edit_hive_type.frames_per_box'.tr() + ' *',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: state.showValidationErrors && 
                         (state.framesPerBox == null || state.framesPerBox! <= 0)
                      ? Colors.red
                      : null,
                ),
              ),
              const SizedBox(height: 4),
              NumericInputField(
                labelText: '',
                helperText: state.showValidationErrors && 
                           (state.framesPerBox == null || state.framesPerBox! <= 0)
                    ? 'edit_hive_type.frames_per_box_required'.tr()
                    : 'edit_hive_type.frames_per_box_help'.tr(),
                value: state.framesPerBox ?? 0,
                min: 1,
                max: 50,
                onChanged: (value) {
                  context.read<EditHiveTypeBloc>().add(EditHiveTypeFramesPerBoxChanged(value));
                },
                isError: state.showValidationErrors && 
                        (state.framesPerBox == null || state.framesPerBox! <= 0),
              ),
            ],
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
          NumericInputField(
            labelText: 'edit_hive_type.brood_frames'.tr(),
            value: state.broodFrameCount ?? 0,
            min: 0,
            max: 100,
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeBroodFrameCountChanged(value),
              );
            },
          ),
          const SizedBox(height: 16),
          NumericInputField(
            labelText: 'edit_hive_type.honey_frames'.tr(),
            value: state.honeyFrameCount ?? 0,
            min: 0,
            max: 100,
            onChanged: (value) {
              context.read<EditHiveTypeBloc>().add(
                EditHiveTypeHoneyFrameCountChanged(value),
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NumericInputField(
                  labelText: 'edit_hive_type.brood_boxes'.tr(),
                  value: state.boxCount ?? 0,
                  min: 0,
                  max: 20,
                  onChanged: (value) {
                    context.read<EditHiveTypeBloc>().add(EditHiveTypeBoxCountChanged(value));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: NumericInputField(
                  labelText: 'edit_hive_type.super_boxes'.tr(),
                  value: state.superBoxCount ?? 0,
                  min: 0,
                  max: 20,
                  onChanged: (value) {
                    context.read<EditHiveTypeBloc>().add(EditHiveTypeSuperBoxCountChanged(value));
                  },
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
      child: TextFormField(
        controller: _costController,
        decoration: InputDecoration(
          labelText: 'edit_hive_type.cost'.tr(),
          border: const OutlineInputBorder(),
          prefixText: '\$ ',
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
        ],
        onChanged: (value) {
          final cost = value.isEmpty ? null : double.tryParse(value);
          context.read<EditHiveTypeBloc>().add(EditHiveTypeCostChanged(cost));
        },
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