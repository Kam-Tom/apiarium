import 'package:apiarium/core/core.dart';
import 'package:apiarium/core/theme/app_theme.dart';
import 'package:apiarium/features/managment/edit_hive/widgets/edit_hive_card.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:apiarium/shared/widgets/dropdown/searchable_rounded_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/features/managment/edit_hive/bloc/edit_hive_bloc.dart';
import 'package:go_router/go_router.dart';

class HiveQueen extends StatelessWidget {
  const HiveQueen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return EditHiveCard(
      title: 'Queen',
      icon: Icons.emoji_nature,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Assign Queen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              _buildQueenManagementButton(context),
            ],
          ),
          const SizedBox(height: 8),
          _buildQueenSelector(context),
          const SizedBox(height: 16),
          _buildQueenInfo(context),
        ],
      ),
    );
  }

  Widget _buildQueenManagementButton(BuildContext context) {
    final queen = context.select((EditHiveBloc bloc) => bloc.state.queen);
    
    return TextButton.icon(
      onPressed: () => _createQueen(context, queen),
      icon: Icon(
        queen != null ? Icons.edit : Icons.add, 
        size: 18,
        color: AppTheme.primaryColor,
      ),
      label: Text(
        queen != null ? 'Edit Queen' : 'Create Queen',
        style: TextStyle(color: AppTheme.primaryColor),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }

  Widget _buildQueenSelector(BuildContext context) {
    final queen = context.select((EditHiveBloc bloc) => bloc.state.queen);
    final queens = [
      null,
      ...context.select((EditHiveBloc bloc) => bloc.state.availableQueens)
    ];

    return RoundedDropdown<Queen?>(
      value: queen,
      items: queens,
      onChanged: (value) {
        context.read<EditHiveBloc>().add(EditHiveQueenChanged(value));
      },
      itemBuilder: (context, item, isSelected) => item != null
          ? Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      item.name,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: isSelected ? AppTheme.primaryColor : null,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (item.marked && item.markColor != null)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: item.markColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                ],
              ),
            )
          : const Center(child: Text("No Queen")),
      buttonItemBuilder: (context, item) => item != null
          ? Row(
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 8),
                if (item.marked && item.markColor != null)
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: item.markColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
              ],
            )
          : const Center(child: Text("No Queen")),
    );
  }

  Widget _buildQueenInfo(BuildContext context) {
    final queen = context.select((EditHiveBloc bloc) => bloc.state.queen);

    if (queen == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text("No queen assigned to this hive"),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (queen.marked && queen.markColor != null)
                      Container(
                        width: 24,
                        height: 24,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          color: queen.markColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    Text(
                      'Queen Details',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _infoRow('Name:', queen.name),
          _infoRow('Breed:', queen.breed.name),
          _infoRow(
            'Birth Date:',
            '${queen.birthDate.year}-${queen.birthDate.month.toString().padLeft(2, '0')}-${queen.birthDate.day.toString().padLeft(2, '0')}',
          ),
          _infoRow('Status:', queen.status.toString().split('.').last),
        ],
      ),
    );
  }

  void _createQueen(BuildContext context, Queen? queen) async {
    if(queen != null) {
      final updatedQueen = await context.push(AppRouter.editQueen, extra: {'queenId': queen.id, 'hideLocation': true});
      if(context.mounted && updatedQueen is Queen) {
        //Reload queen data
        context.read<EditHiveBloc>().add(EditHiveUpdateQueen(updatedQueen));
      }
      return;
    }

    final canCreateDefaultQueen = context.read<EditHiveBloc>().state.canCreateDefaultQueen;

    if(canCreateDefaultQueen){
      context.read<EditHiveBloc>().add(const EditHiveCreateDefaultQueen());
      return;
    }
    final newQueen = await context.push(AppRouter.editQueen, extra: {'skipSaving': true} );

    if(context.mounted && newQueen is Queen) {
      context.read<EditHiveBloc>().add(EditHiveCreateQueen(newQueen));
    }
  }
  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
