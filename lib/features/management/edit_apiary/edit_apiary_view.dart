import 'package:apiarium/features/management/edit_apiary/bloc/edit_apiary_bloc.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/apiary_basic_info.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/apiary_hives_info.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/apiary_location_info.dart';
import 'package:apiarium/features/management/edit_apiary/widgets/apiary_status_info.dart';
import 'package:apiarium/shared/widgets/forms/submit_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:apiarium/shared/utils/toast_utils.dart';
import 'package:apiarium/shared/utils/scroll_utils.dart';

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
        (current.formStatus == EditApiaryStatus.success && previous.formStatus != current.formStatus) ||
        (current.formStatus == EditApiaryStatus.failure && previous.formStatus != current.formStatus) ||
        (current.showValidationErrors && !previous.showValidationErrors),
      listener: _handleStateChanges,
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
                Text(state.errorMessage ?? 'common.error_occurred'.tr()),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<EditApiaryBloc>().add(
                        EditApiaryLoadData(apiaryId: state.apiaryId));
                  },
                  child: Text('common.retry'.tr()),
                ),
              ],
            ),
          );
        }
        
        return SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ApiaryBasicInfo(),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),
                const ApiaryLocationInfo(),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),
                const ApiaryStatusInfo(),
                const SizedBox(height: 8),
                const Divider(thickness: 1, color: Colors.grey),
                const SizedBox(height: 8),
                const ApiaryHivesInfo(),
                const SizedBox(height: 16),
                SubmitButton(
                  text: 'edit_apiary.save'.tr(),
                  isSubmitting: state.formStatus == EditApiaryStatus.submitting,
                  onPressed: () {
                    context.read<EditApiaryBloc>().add(const EditApiarySubmitted());
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, EditApiaryState state) {
    if (state.formStatus == EditApiaryStatus.success) {
      ToastUtils.showSuccess(context, 'edit_apiary.saved_success'.tr());
      Navigator.of(context).pop();
      return;
    }
    
    if (state.formStatus == EditApiaryStatus.failure) {
      ToastUtils.showError(context, state.errorMessage ?? 'common.error_occurred'.tr());
      return;
    }
    
    if (state.showValidationErrors && !state.isValid) {
      ScrollUtils.scrollToTop(_scrollController);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}