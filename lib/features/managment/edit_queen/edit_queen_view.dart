import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_acquisition.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_basic_info.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';

class EditQueenView extends StatefulWidget {
  final String? queenId;
  
  const EditQueenView({super.key, this.queenId});

  @override
  State<EditQueenView> createState() => _EditQueenViewState();
}

class _EditQueenViewState extends State<EditQueenView> {
  final _scrollController = ScrollController();
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditQueenBloc, EditQueenState>(
      listenWhen: (previous, current) => 
          previous.status != current.status || 
          previous.errorMessage != current.errorMessage ||
          previous.showValidationErrors != current.showValidationErrors,
      listener: _handleStateChanges,
      buildWhen: (previous, current) => 
          previous.status != current.status || 
          previous != current,
      builder: (context, state) {
        if (state.status == EditQueenStatus.initial || 
            state.status == EditQueenStatus.loading) {
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
                    const QueenBasicInfo(),
                    const SizedBox(height: 20),
                    if(!state.hideLocation) ...[
                      const QueenLocation(),
                      const SizedBox(height: 20),
                    ],
                    const QueenAcquisition(),
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
                      onPressed: state.status == EditQueenStatus.submitting
                          ? null
                          : () => context.read<EditQueenBloc>().add(EditQueenSubmitted()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.status == EditQueenStatus.submitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Queen'),
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
  
  void _handleStateChanges(BuildContext context, EditQueenState state) {
    if (state.status == EditQueenStatus.success) {
      if (state.skipSaving) {
        // Return the created queen without saving
        Navigator.of(context).pop(state.createdQueen);
      } else {
        // Show success message and return queen to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Queen saved successfully!')),
        );
        Navigator.of(context).pop(state.createdQueen);
      }
    }
    
    if (state.status == EditQueenStatus.failure && state.errorMessage != null) {
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
