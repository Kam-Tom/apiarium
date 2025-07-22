import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_acquisition.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_basic_info.dart';
import 'package:apiarium/features/managment/edit_queen/widgets/queen_location.dart';
import 'package:apiarium/shared/widgets/dialogs/add_spending_dialog.dart';
import 'package:apiarium/shared/utils/scroll_utils.dart';
import 'package:apiarium/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_queen/bloc/edit_queen_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class EditQueenView extends StatefulWidget {
  const EditQueenView({super.key});

  @override
  State<EditQueenView> createState() => _EditQueenViewState();
}

class _EditQueenViewState extends State<EditQueenView> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<EditQueenBloc, EditQueenState>(
      listenWhen: (previous, current) =>
        (current.status == EditQueenStatus.success && previous.status != current.status) ||
        (current.status == EditQueenStatus.failure && previous.status != current.status),
      listener: _handleStateChanges,
      builder: (context, state) {
        if (state.status == EditQueenStatus.initial ||
            state.status == EditQueenStatus.loading) {
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
                const QueenBasicInfo(),
                const SizedBox(height: 16),
                if (state.shouldShowLocation) ...[
                  const QueenLocation(),
                  const SizedBox(height: 16),
                ],
                const QueenAcquisition(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: state.status == EditQueenStatus.submitting
                        ? null
                        : () => context.read<EditQueenBloc>().add(EditQueenSubmitted()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: state.status == EditQueenStatus.submitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'edit_queen.save'.tr(),
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

  void _handleStateChanges(BuildContext context, EditQueenState state) async {
    if (state.status == EditQueenStatus.success) {
      ToastUtils.showSuccess(context, 'edit_queen.saved_success'.tr());
      
      final isCreation = state.id == null || state.id!.isEmpty;
      if (state.queen != null && isCreation) {
        final apiaries = state.availableApiaries;
        final result = await showAddSpendingDialog(
          context: context,
          initialAmount: 0,
          initialDate: DateTime.now(),
          apiaries: apiaries,
          initialApiary: state.selectedApiary,
          title: 'Add spending for queen'.tr(),
          itemName: state.queen!.name,
        );
        if (result != null && result.confirmed) {
          context.read<EditQueenBloc>().add(
            EditQueenAddSpending(
              amount: result.amount,
              date: result.date,
              apiary: result.apiary,
              itemName: state.queen!.name,
            ),
          );
        }
        Navigator.of(context).pop(state.queen);
      } else {
        Navigator.of(context).pop(state.queen);
      }
      return;
    }

    if (state.status == EditQueenStatus.failure && state.errorMessage != null) {
      ToastUtils.showError(context, state.errorMessage!.tr());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}