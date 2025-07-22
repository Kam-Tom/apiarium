import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../domain/models/apiary.dart';

class AddSpendingDialogResult {
  final double amount;
  final DateTime date;
  final Apiary? apiary;
  final String? title;
  final String? itemName;
  final bool confirmed;

  AddSpendingDialogResult({
    required this.amount,
    required this.date,
    required this.apiary,
    required this.confirmed,
    this.title,
    this.itemName,
  });
}

Future<AddSpendingDialogResult?> showAddSpendingDialog({
  required BuildContext context,
  required double initialAmount,
  required DateTime initialDate,
  required List<Apiary> apiaries,
  Apiary? initialApiary,
  String? title,
  String? itemName,
  String? defaultCurrency,
}) {
  final amountController = TextEditingController(text: initialAmount.toStringAsFixed(2));
  DateTime selectedDate = initialDate;
  Apiary? selectedApiary = initialApiary;

  return showDialog<AddSpendingDialogResult>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(title ?? 'Add spending'.tr()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (itemName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            TextFormField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount spent'.tr(),
                prefixText: (defaultCurrency ?? 'PLN ') + ' ',
              ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: selectedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  selectedDate = picked;
                  (ctx as Element).markNeedsBuild();
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Date'.tr(),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(DateFormat.yMMMd().format(selectedDate)),
                    const Icon(Icons.calendar_today, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Apiary?>(
              value: selectedApiary,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Apiary'.tr(),
              ),
              items: [
                DropdownMenuItem<Apiary?>(
                  value: null,
                  child: Text('No Apiary'.tr()),
                ),
                ...apiaries.map((a) => DropdownMenuItem<Apiary?>(
                  value: a,
                  child: Text(a.name),
                )),
              ],
              onChanged: (a) {
                selectedApiary = a;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('No'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0.0;
              Navigator.of(ctx).pop(AddSpendingDialogResult(
                amount: amount,
                date: selectedDate,
                apiary: selectedApiary,
                confirmed: true,
                title: title,
                itemName: itemName,
              ));
            },
            child: Text('Yes'.tr()),
          ),
        ],
      );
    },
  );
}
