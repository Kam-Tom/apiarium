import 'package:apiarium/features/management/edit_apiary/widgets/edit_apiary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/management/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ApiaryBasicInfo extends StatefulWidget {
  const ApiaryBasicInfo({super.key});

  @override
  State<ApiaryBasicInfo> createState() => _ApiaryBasicInfoState();
}

class _ApiaryBasicInfoState extends State<ApiaryBasicInfo> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  bool _showColorPicker = false;

  static const List<Color> _predefinedColors = [
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.white,
    Colors.brown,
  ];

  @override
  void initState() {
    super.initState();
    final state = context.read<EditApiaryBloc>().state;
    _nameController.text = state.name;
    _descriptionController.text = state.description;
    _showColorPicker = state.color != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EditApiaryBloc, EditApiaryState>(
      listenWhen: (previous, current) =>
          previous.name != current.name || previous.color != current.color,
      listener: (context, state) {
        if (_nameController.text != state.name) {
          _nameController.text = state.name;
        }
        setState(() {
          _showColorPicker = state.color != null;
        });
      },
      child: EditApiaryCard(
        title: 'edit_apiary.basic_information'.tr(),
        icon: Icons.info_outline,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('edit_apiary.name_title'),
            const SizedBox(height: 8),
            _buildName(),
            const SizedBox(height: 16),
            _buildDescription(),
            const SizedBox(height: 16),
            _buildImageSection(),
            const SizedBox(height: 16),
            _buildColorToggle(),
            if (_showColorPicker) ...[
              const SizedBox(height: 8),
              _buildColorPicker(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String key) => Text(
        key.tr(),
        style: Theme.of(context).textTheme.titleMedium,
      );

  Widget _buildName() {
    final nameError = context.select(
      (EditApiaryBloc bloc) =>
          bloc.state.showValidationErrors && bloc.state.name.trim().isEmpty
              ? 'edit_apiary.name_required'.tr()
              : null,
    );
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: 'edit_apiary.name_label'.tr(),
        border: const OutlineInputBorder(),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        errorText: nameError,
        errorBorder: nameError != null
            ? OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red.shade700, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        suffixIcon: IconButton(
          onPressed: () {
            context.read<EditApiaryBloc>().add(const EditApiaryGenerateName());
          },
          icon: Icon(Icons.refresh, color: Colors.grey.shade600),
          tooltip: 'edit_apiary.generate_name'.tr(),
        ),
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
        labelText: 'edit_apiary.description'.tr(),
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: 3,
      onChanged: (value) {
        context.read<EditApiaryBloc>().add(EditApiaryDescriptionChanged(value.trim()));
      },
    );
  }

  Widget _buildImageSection() {
    final imageUrl = context.select((EditApiaryBloc bloc) => bloc.state.imageUrl);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('edit_apiary.apiary_image'),
        const SizedBox(height: 8),
        if (imageUrl != null) ...[
          _buildImagePreview(imageUrl),
          const SizedBox(height: 8),
        ],
        _buildImageButtons(imageUrl),
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
            label: Text('edit_apiary.gallery'.tr()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: Text('edit_apiary.camera'.tr()),
          ),
        ),
        if (imageUrl != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              context.read<EditApiaryBloc>().add(const EditApiaryImageDeleted());
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'edit_apiary.remove_image'.tr(),
          ),
        ],
      ],
    );
  }

  Widget _buildColorToggle() {
    return Row(
      children: [
        Switch(
          value: _showColorPicker,
          onChanged: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {
              _showColorPicker = value;
              if (!value) {
                context.read<EditApiaryBloc>().add(const EditApiaryColorChanged(null));
              }
            });
          },
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'edit_apiary.add_color'.tr(),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    final color = context.select((EditApiaryBloc bloc) => bloc.state.color);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('edit_apiary.choose_color'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _predefinedColors.map((predefinedColor) {
            final isSelected = color?.toARGB32() == predefinedColor.toARGB32();
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
          }).toList(),
        ),
        if (color == null && _showColorPicker)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'edit_apiary.no_color_selected'.tr(),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ),
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
        context.read<EditApiaryBloc>().add(EditApiaryImageChanged(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('edit_apiary.failed_pick_image'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}