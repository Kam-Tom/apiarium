import 'package:apiarium/core/core.dart';
import 'package:apiarium/features/management/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/management/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';

class HiveQueen extends StatelessWidget {
  const HiveQueen({super.key});

  @override
  Widget build(BuildContext context) {
    return EditHiveCard(
      title: 'edit_hive.queen'.tr(),
      icon: Icons.emoji_nature,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQueenHeader(context),
          const SizedBox(height: 12),
          _buildQueenSelector(context),
          const SizedBox(height: 16),
          _buildQueenInfo(context),
        ],
      ),
    );
  }

  Widget _buildQueenHeader(BuildContext context) {
    final queen = context.select((EditHiveBloc bloc) => bloc.state.queen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'edit_hive.assign_queen'.tr(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _createQueen(context, queen),
            icon: Icon(
              queen != null ? Icons.edit : Icons.add,
              size: 18,
            ),
            label: Text(queen != null ? 'edit_hive.edit_queen'.tr() : 'edit_hive.create_queen'.tr()),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryColor,
              side: BorderSide(color: AppTheme.primaryColor),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQueenSelector(BuildContext context) {
    final queen = context.select((EditHiveBloc bloc) => bloc.state.queen);
    final queens = [
      null,
      ...context.select((EditHiveBloc bloc) => bloc.state.availableQueens)
    ];

    return SearchableRoundedDropdown<Queen?>(
      value: queen,
      items: queens,
      onChanged: (value) {
        context.read<EditHiveBloc>().add(EditHiveQueenChanged(value));
      },
      itemBuilder: (ctx, queenOption, isSelected) {
        if (queenOption == null) {
          return Text("edit_hive.no_queen".tr());
        }
        return Row(
          children: [
            Expanded(
              child: Text(
                queenOption.name,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            if (queenOption.marked && queenOption.markColor != null)
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: queenOption.markColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey),
                ),
              ),
          ],
        );
      },
      hintText: 'edit_hive.select_queen'.tr(),
      searchHintText: 'edit_hive.search_queen'.tr(),
      minHeight: 48.0,
    );
  }

  Widget _buildQueenInfo(BuildContext context) {
    final queen = context.select((EditHiveBloc bloc) => bloc.state.queen);

    if (queen == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            "edit_hive.no_queen_assigned".tr(),
            style: const TextStyle(
              color: Colors.grey,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (queen.marked && queen.markColor != null) ...[
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: queen.markColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  'edit_hive.queen_details'.tr(),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow('edit_hive.queen_name'.tr(), queen.name),
          _infoRow('edit_hive.queen_breed'.tr(), queen.breedName),
          _infoRow(
            'edit_hive.queen_birth_date'.tr(),
            '${queen.birthDate.year}-${queen.birthDate.month.toString().padLeft(2, '0')}-${queen.birthDate.day.toString().padLeft(2, '0')}',
          ),
          _infoRow('edit_hive.queen_status'.tr(), queen.status.toString().split('.').last),
        ],
      ),
    );
  }

  void _createQueen(BuildContext context, Queen? queen) async {
    if (queen != null) {
      final updatedQueen = await context.push(
        AppRouter.editQueen,
        extra: {
          'queenId': queen.id,
          'hideLocation': true,
        }
      );
      if (context.mounted && updatedQueen is Queen) {
        context.read<EditHiveBloc>().add(EditHiveUpdateQueen(updatedQueen));
      }
      return;
    }

    // Create new queen - always navigate to edit queen page
    final newQueen = await context.push(
      AppRouter.editQueen,
      extra: {
        'hideLocation': true,
      }
    );

    if (context.mounted && newQueen is Queen) {
      context.read<EditHiveBloc>().add(EditHiveCreateQueen(newQueen));
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}