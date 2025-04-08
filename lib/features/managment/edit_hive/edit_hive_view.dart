import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_basic_info.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_frames.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_location.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_queen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EditHiveView extends StatefulWidget {
  const EditHiveView({super.key});

  @override
  State<EditHiveView> createState() => _EditHiveViewState();
}

class _EditHiveViewState extends State<EditHiveView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditHiveBloc, EditHiveState>(
      listenWhen: (previous, current) =>
          previous.formStatus != current.formStatus ||
          previous.errorMessage != current.errorMessage ||
          previous.showValidationErrors != current.showValidationErrors,
      listener: _handleStateChanges,
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus || previous != current,
      builder: (context, state) {
        if (state.formStatus == EditHiveStatus.initial ||
            state.formStatus == EditHiveStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const HiveBasicInfo(),
                    const SizedBox(height: 20),
                    // Only show location if hideLocation is false
                    if (!state.hideLocation) ...[
                      const HiveLocation(),
                      const SizedBox(height: 20),
                    ],
                    const HiveFrames(),
                    const SizedBox(height: 20),
                    const HiveQueen(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: state.formStatus == EditHiveStatus.submitting
                          ? null
                          : () => context.read<EditHiveBloc>().add(EditHiveSubmitted()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.formStatus == EditHiveStatus.submitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Hive'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, EditHiveState state) {
    if (state.formStatus == EditHiveStatus.success) {
      if (state.skipSaving) {
        // Return the created hive without saving to database
        Navigator.of(context).pop(state.createdHive);
      } else {
        // Show success message and return the created/updated hive
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hive saved successfully!')),
        );
        Navigator.of(context).pop(state.createdHive);
      }
    }

    if (state.formStatus == EditHiveStatus.failure && state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.errorMessage!)),
      );
    }

    if (state.showValidationErrors && state.validationErrors.isNotEmpty) {
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}