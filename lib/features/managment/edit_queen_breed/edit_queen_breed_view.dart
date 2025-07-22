import 'package:apiarium/shared/widgets/dropdown/rounded_dropdown.dart';
import 'package:apiarium/shared/utils/toast_utils.dart';
import 'package:apiarium/shared/utils/scroll_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_bloc.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_event.dart';
import 'package:apiarium/features/managment/edit_queen_breed/bloc/edit_queen_breed_state.dart';
import 'package:apiarium/shared/widgets/submit_button.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditQueenBreedView extends StatefulWidget {
  const EditQueenBreedView({super.key});

  @override
  State<EditQueenBreedView> createState() => _EditQueenBreedViewState();
}

class _EditQueenBreedViewState extends State<EditQueenBreedView> {
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _originController = TextEditingController();
  final _characteristicsController = TextEditingController();
  final _costController = TextEditingController();
  final _scrollController = ScrollController();
  final ImagePicker _picker = ImagePicker();

  static const List<String> _countries = [
    '', 'PL', 'IT', 'SI', 'DE', 'FR', 'ES', 'GB', 'US', 'CA', 'AU', 'NZ', 'DK', 'SE', 'NO', 'FI'
  ];

  bool _shouldScrollToTop = false; // Flag to control scroll behavior

  @override
  void initState() {
    super.initState();
    final state = context.read<EditQueenBreedBloc>().state;
    _nameController.text = state.name;
    _scientificNameController.text = state.scientificName;
    _originController.text = state.origin;
    _characteristicsController.text = state.characteristics;
    _costController.text = state.cost?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditQueenBreedBloc, EditQueenBreedState>(
      listenWhen: (previous, current) => 
        (current.status == EditQueenBreedStatus.saved && previous.status != current.status) ||
        (current.status == EditQueenBreedStatus.error && previous.status != current.status) ||
        (current.hasTriedSubmit && !previous.hasTriedSubmit),
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state.status == EditQueenBreedStatus.initial ||
            state.status == EditQueenBreedStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
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
                  _buildCharacteristicsCard(state),
                  const SizedBox(height: 16),
                  _buildOriginCard(state),
                  const SizedBox(height: 32),
                  SubmitButton(
                    text: 'edit_queen_breed.save'.tr(),
                    isSubmitting: state.status == EditQueenBreedStatus.saving,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      _shouldScrollToTop = true; // Set flag to true when submit is clicked
                      context.read<EditQueenBreedBloc>().add(const EditQueenBreedSubmitted());
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(EditQueenBreedState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
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
                          state.name.isEmpty ? 'edit_queen_breed.new_breed'.tr() : state.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (state.scientificName.isNotEmpty)
                          Text(
                            state.scientificName,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (state.isStarred)
                              Icon(
                                Icons.star,
                                color: Colors.amber.shade700,
                                size: 20,
                              ),
                            if (state.isLocal)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'edit_queen_breed.local'.tr(),
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      context.read<EditQueenBreedBloc>().add(const EditQueenBreedToggleStarred());
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
        ),
      ),
    );
  }

  Widget _buildHeaderImage(EditQueenBreedState state) {
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
                    Icons.pets,
                    size: 40,
                    color: Colors.amber.shade700,
                  );
                },
              ),
            )
          : Icon(
              Icons.pets,
              size: 40,
              color: Colors.amber.shade700,
            ),
    );
  }

  Widget _buildBasicInfoCard(EditQueenBreedState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'edit_queen_breed.basic_information'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'edit_queen_breed.name'.tr(),
                  border: const OutlineInputBorder(),
                  helperText: 'edit_queen_breed.name_help'.tr(),
                  errorText: state.hasTriedSubmit && state.name.trim().isEmpty 
                      ? 'edit_queen_breed.name_required'.tr() 
                      : null,
                ),
                onChanged: (value) {
                  // Reset the error flag when user starts typing
                  if (state.hasTriedSubmit && value.trim().isNotEmpty) {
                    context.read<EditQueenBreedBloc>().add(EditQueenBreedResetValidation());
                  }
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedNameChanged(value));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _scientificNameController,
                decoration: InputDecoration(
                  labelText: 'edit_queen_breed.scientific_name'.tr(),
                  border: const OutlineInputBorder(),
                  helperText: 'edit_queen_breed.scientific_name_help'.tr(),
                ),
                onChanged: (value) {
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedScientificNameChanged(value));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _costController,
                decoration: InputDecoration(
                  labelText: 'edit_queen_breed.cost'.tr(),
                  border: const OutlineInputBorder(),
                  helperText: 'edit_queen_breed.cost_help'.tr(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (value) {
                  final cost = value.isEmpty ? null : double.tryParse(value);
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedCostChanged(cost));
                },
              ),
              const SizedBox(height: 16),
              _buildImageSection(state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCharacteristicsCard(EditQueenBreedState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.star, color: Colors.orange.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'edit_queen_breed.breed_characteristics'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildRatingRow(
                'edit_queen_breed.temperament'.tr(),
                'edit_queen_breed.temperament_help'.tr(),
                state.temperamentRating,
                [
                  'edit_queen_breed.very_aggressive'.tr(),
                  'edit_queen_breed.aggressive'.tr(),
                  'edit_queen_breed.moderate'.tr(),
                  'edit_queen_breed.gentle'.tr(),
                  'edit_queen_breed.very_gentle'.tr(),
                ],
                (rating) {
                  FocusScope.of(context).unfocus();
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedTemperamentRatingChanged(rating));
                },
              ),
              const SizedBox(height: 16),
              _buildRatingRow(
                'edit_queen_breed.honey_production'.tr(),
                'edit_queen_breed.honey_production_help'.tr(),
                state.honeyProductionRating,
                [
                  'edit_queen_breed.very_low'.tr(),
                  'edit_queen_breed.low'.tr(),
                  'edit_queen_breed.medium'.tr(),
                  'edit_queen_breed.high'.tr(),
                  'edit_queen_breed.very_high'.tr(),
                ],
                (rating) {
                  FocusScope.of(context).unfocus();
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedHoneyProductionRatingChanged(rating));
                },
              ),
              const SizedBox(height: 16),
              _buildRatingRow(
                'edit_queen_breed.winter_hardiness'.tr(),
                'edit_queen_breed.winter_hardiness_help'.tr(),
                state.winterHardinessRating,
                [
                  'edit_queen_breed.very_poor'.tr(),
                  'edit_queen_breed.poor'.tr(),
                  'edit_queen_breed.average'.tr(),
                  'edit_queen_breed.good'.tr(),
                  'edit_queen_breed.excellent'.tr(),
                ],
                (rating) {
                  FocusScope.of(context).unfocus();
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedWinterHardinessRatingChanged(rating));
                },
              ),
              const SizedBox(height: 16),
              _buildRatingRow(
                'edit_queen_breed.disease_resistance'.tr(),
                'edit_queen_breed.disease_resistance_help'.tr(),
                state.diseaseResistanceRating,
                [
                  'edit_queen_breed.very_poor'.tr(),
                  'edit_queen_breed.poor'.tr(),
                  'edit_queen_breed.average'.tr(),
                  'edit_queen_breed.good'.tr(),
                  'edit_queen_breed.excellent'.tr(),
                ],
                (rating) {
                  FocusScope.of(context).unfocus();
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedDiseaseResistanceRatingChanged(rating));
                },
              ),
              const SizedBox(height: 16),
              _buildRatingRow(
                'edit_queen_breed.popularity'.tr(),
                'edit_queen_breed.popularity_help'.tr(),
                state.popularityRating,
                [
                  'edit_queen_breed.very_rare'.tr(),
                  'edit_queen_breed.rare'.tr(),
                  'edit_queen_breed.common'.tr(),
                  'edit_queen_breed.popular'.tr(),
                  'edit_queen_breed.very_popular'.tr(),
                ],
                (rating) {
                  FocusScope.of(context).unfocus();
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedPopularityRatingChanged(rating));
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _characteristicsController,
                decoration: InputDecoration(
                  labelText: 'edit_queen_breed.characteristics'.tr(),
                  border: const OutlineInputBorder(),
                  alignLabelWithHint: true,
                  helperText: 'edit_queen_breed.characteristics_help'.tr(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedCharacteristicsChanged(value));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOriginCard(EditQueenBreedState state) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.public, color: Colors.green.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'edit_queen_breed.origin_information'.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'edit_queen_breed.origin'.tr(),
                  border: const OutlineInputBorder(),
                  helperText: 'edit_queen_breed.origin_help'.tr(),
                ),
                onChanged: (value) {
                  context.read<EditQueenBreedBloc>().add(EditQueenBreedOriginChanged(value));
                },
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'edit_queen_breed.country'.tr(),
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  RoundedDropdown<String>(
                    value: state.country.isEmpty ? null : state.country,
                    items: _countries,
                    onChanged: (value) {
                      context.read<EditQueenBreedBloc>().add(EditQueenBreedCountryChanged(value ?? ''));
                    },
                    itemBuilder: (context, country, isSelected) => Text(
                      country.isEmpty ? 'None' : country,
                    ),
                    hintText: 'Select Country',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingRow(String title, String subtitle, int currentRating, List<String> labels, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(5, (index) {
            final rating = index + 1;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(rating),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: rating <= currentRating ? Colors.amber : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    boxShadow: rating <= currentRating ? [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    color: rating <= currentRating ? Colors.white : Colors.grey.shade400,
                    size: 16,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(
          currentRating == 0 ? 'edit_queen_breed.not_rated'.tr() : labels[currentRating - 1],
          style: TextStyle(
            color: currentRating == 0 ? Colors.grey.shade600 : Colors.amber.shade700,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(EditQueenBreedState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_queen_breed.breed_image'.tr(),
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
            onPressed: () {
              FocusScope.of(context).unfocus();
              _pickImage(ImageSource.gallery);
            },
            icon: const Icon(Icons.photo_library),
            label: Text('edit_queen_breed.gallery'.tr()),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              FocusScope.of(context).unfocus();
              _pickImage(ImageSource.camera);
            },
            icon: const Icon(Icons.camera_alt),
            label: Text('edit_queen_breed.camera'.tr()),
          ),
        ),
        if (imageUrl != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              FocusScope.of(context).unfocus();
              context.read<EditQueenBreedBloc>().add(const EditQueenBreedImageDeleted());
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'edit_queen_breed.remove_image'.tr(),
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
        context.read<EditQueenBreedBloc>().add(EditQueenBreedImageChanged(image.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('edit_queen_breed.failed_pick_image'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleStateChanges(BuildContext context, EditQueenBreedState state) {
    if (state.status == EditQueenBreedStatus.saved) {
      ToastUtils.showSuccess(context, 'edit_queen_breed.saved_success'.tr());
      Navigator.of(context).pop(true);
      return;
    }

    if (state.status == EditQueenBreedStatus.error) {
      String errorMessage = state.errorMessage == 'Breed name is required'
          ? 'edit_queen_breed.name_required'.tr()
          : state.errorMessage ?? 'Unknown error occurred';
      ToastUtils.showError(context, errorMessage);
      return;
    }

    if (state.hasTriedSubmit && state.name.trim().isEmpty) {
      ScrollUtils.scrollToTop(_scrollController);
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _scientificNameController.dispose();
    _originController.dispose();
    _characteristicsController.dispose();
    _costController.dispose();
    super.dispose();
  }
}