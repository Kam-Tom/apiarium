import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'add_spending_dialog_cubit.dart';

class AddSpendingDialogView extends StatelessWidget {
  final bool showUnitPrice;
  final bool showNotes;
  final bool showAttachments;
  final String? initialApiaryId;
  final String? initialApiaryName;
  final String type; // 'expense', 'income', 'use', etc.

  const AddSpendingDialogView({
    super.key,
    this.showUnitPrice = false,
    this.showNotes = false,
    this.showAttachments = false,
    this.initialApiaryId,
    this.initialApiaryName,
    this.type = 'expense',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddSpendingDialogCubit(
        initial: AddSpendingDialogState(
          apiaryId: initialApiaryId,
          apiaryName: initialApiaryName,
          type: type,
        ),
      ),
      child: BlocBuilder<AddSpendingDialogCubit, AddSpendingDialogState>(
        builder: (context, state) {
          final cubit = context.read<AddSpendingDialogCubit>();
          return AlertDialog(
            title: Text('Add ${type[0].toUpperCase()}${type.substring(1)}'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  // ...fields for group, item, amount, etc...
                  if (showUnitPrice)
                    TextField(
                      decoration: InputDecoration(labelText: 'Unit Price'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => cubit.updateField('unitPrice', double.tryParse(v)),
                    ),
                  if (showNotes)
                    TextField(
                      decoration: InputDecoration(labelText: 'Notes'),
                      onChanged: (v) => cubit.updateField('notes', v),
                    ),
                  if (showAttachments)
                    // Add your attachment picker here (image/file picker)
                    ElevatedButton(
                      onPressed: () {
                        // TODO: implement image/file picker and update cubit
                      },
                      child: Text('Add Attachment'),
                    ),
                  // ...other fields as needed...
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              ElevatedButton(
                onPressed: () {
                  // TODO: Validate and save using StorageService
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
