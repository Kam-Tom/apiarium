import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_basic_info.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_location.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/hive_queen.dart';
import 'package:apiarium/shared/utils/toast_utils.dart';
import 'package:apiarium/shared/utils/scroll_utils.dart';
import 'package:apiarium/shared/widgets/dialogs/add_spending_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class EditHiveView extends StatefulWidget {
  final bool hideLocation;

  const EditHiveView({super.key, this.hideLocation = false});

  @override
  State<EditHiveView> createState() => _EditHiveViewState();
}

class _EditHiveViewState extends State<EditHiveView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditHiveBloc, EditHiveState>(
      listenWhen: (previous, current) =>
        (current.formStatus == EditHiveStatus.success && previous.formStatus != current.formStatus) ||
        (current.formStatus == EditHiveStatus.failure && previous.formStatus != current.formStatus) ||
        (current.showValidationErrors && !previous.showValidationErrors),
      listener: _handleStateChanges,
      buildWhen: (previous, current) =>
          previous.formStatus != current.formStatus || previous != current,
      builder: (context, state) {
        if (state.formStatus == EditHiveStatus.initial ||
            state.formStatus == EditHiveStatus.loading) {
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
                const HiveBasicInfo(),
                const SizedBox(height: 16),
                if (!widget.hideLocation) ...[
                  const HiveLocation(),
                  const SizedBox(height: 16),
                ],
                const HiveQueen(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.formStatus == EditHiveStatus.submitting
                        ? null
                        : () => context.read<EditHiveBloc>().add(EditHiveSubmitted()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.formStatus == EditHiveStatus.submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'edit_hive.save'.tr(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleStateChanges(BuildContext context, EditHiveState state) async {
    if (state.formStatus == EditHiveStatus.success) {
      ToastUtils.showSuccess(context, 'edit_hive.saved_success'.tr());
      
      final isCreation = state.hiveId == null || state.hiveId!.isEmpty;
      if (state.savedHive != null && isCreation) {
        final apiaries = state.availableApiaries;
        final result = await showAddSpendingDialog(
          context: context,
          initialAmount: state.hiveType?.cost ?? 0,
          initialDate: DateTime.now(),
          apiaries: apiaries,
          initialApiary: state.selectedApiary,
          title: 'Add spending for hive'.tr(),
          itemName: state.savedHive!.name,
        );
        if (result != null && result.confirmed && context.mounted) {
          context.read<EditHiveBloc>().add(
            EditHiveAddSpending(
              amount: result.amount,
              date: result.date,
              apiary: result.apiary,
              itemName: state.savedHive!.name,
            ),
          );
        }
        if(context.mounted) {
          Navigator.of(context).pop(state.savedHive);
        }
      } else {
        Navigator.of(context).pop(state.savedHive);
      }
      return;
    }

    if (state.formStatus == EditHiveStatus.failure && state.errorMessage != null && context.mounted) {
      ToastUtils.showError(context, state.errorMessage!);
      return;
    }

    if (state.showValidationErrors && state.validationErrors.isNotEmpty) {
      ScrollUtils.scrollToTop(_scrollController);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}