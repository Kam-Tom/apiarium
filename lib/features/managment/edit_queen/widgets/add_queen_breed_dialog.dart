import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/shared/shared.dart';

class AddQueenBreedDialog extends StatefulWidget {
  const AddQueenBreedDialog({super.key});

  @override
  State<AddQueenBreedDialog> createState() => _AddQueenBreedDialogState();
}

class _AddQueenBreedDialogState extends State<AddQueenBreedDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _originController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isStarred = false;

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _originController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Queen Breed'.tr()),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Breed Name'.tr(),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required'.tr();
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _scientificNameController,
                decoration: InputDecoration(
                  labelText: 'Scientific Name (Latin)'.tr(),
                  border: const OutlineInputBorder(),
                  hintText: 'Apis mellifera...',
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _originController,
                decoration: InputDecoration(
                  labelText: 'Origin'.tr(),
                  border: const OutlineInputBorder(),
                  hintText: 'Region of origin'.tr(),
                ),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _countryController,
                decoration: InputDecoration(
                  labelText: 'Country'.tr(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Checkbox(
                    value: _isStarred,
                    onChanged: (value) {
                      setState(() {
                        _isStarred = value ?? false;
                      });
                    },
                  ),
                  Text('Add to favorites'.tr()),
                  const SizedBox(width: 4),
                  Icon(Icons.star, color: _isStarred ? AppTheme.primaryColor : Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'.tr()),
        ),
        ElevatedButton(
          onPressed: _submitForm,
          child: Text('Save'.tr()),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final newBreed = QueenBreed(
        id: '',
        name: _nameController.text.trim(),
        scientificName: _scientificNameController.text.isEmpty 
            ? null 
            : _scientificNameController.text.trim(),
        origin: _originController.text.isEmpty 
            ? null 
            : _originController.text.trim(),
        country: _countryController.text.isEmpty 
            ? null 
            : _countryController.text.trim(),
        isStarred: _isStarred,
      );
      
      Navigator.of(context).pop(newBreed);
    }
  }
}
