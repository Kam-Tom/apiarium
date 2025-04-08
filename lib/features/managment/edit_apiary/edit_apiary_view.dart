import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/apiary_basic_info.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/apiary_hives_info.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/apiary_location_info.dart';
import 'package:apiarium/features/managment/edit_apiary/widgets/apiary_status_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class EditApiaryView extends StatefulWidget {
  const EditApiaryView({super.key});

  @override
  State<EditApiaryView> createState() => _EditApiaryViewState();
}

class _EditApiaryViewState extends State<EditApiaryView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditApiaryBloc, EditApiaryState>(
      listenWhen: (previous, current) => 
        previous.formStatus != current.formStatus || 
        previous.showValidationErrors != current.showValidationErrors,
      listener: (context, state) {
        if (state.formStatus == EditApiaryStatus.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Apiary saved successfully'.tr()),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else if (state.formStatus == EditApiaryStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'An error occurred'.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
        
        // Scroll to top when validation errors are shown
        if (state.showValidationErrors && !state.isValid) {
          _scrollToTop();
        }
      },
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus || previous != current,
      builder: (context, state) {
        if (state.formStatus == EditApiaryStatus.loading || state.formStatus == EditApiaryStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state.formStatus == EditApiaryStatus.failure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(state.errorMessage ?? 'An error occurred'.tr()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<EditApiaryBloc>().add(
                        EditApiaryLoadData(apiaryId: state.apiaryId));
                  },
                  child: Text('Try Again'.tr()),
                ),
              ],
            ),
          );
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
                    const ApiaryBasicInfo(),
                    const SizedBox(height: 16),
                    const ApiaryLocationInfo(),
                    const SizedBox(height: 16),
                    const ApiaryHivesInfo(),
                    const SizedBox(height: 16),
                    const ApiaryStatusInfo(),
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
                      onPressed: state.formStatus == EditApiaryStatus.submitting
                          ? null
                          : () {
                              context.read<EditApiaryBloc>().add(EditApiarySubmitted());
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: state.formStatus == EditApiaryStatus.submitting
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text('Save Apiary'.tr()),
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