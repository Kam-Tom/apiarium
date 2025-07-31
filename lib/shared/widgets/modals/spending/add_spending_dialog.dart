import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddSpendingDialogResult {
  final double amount;
  final DateTime date;
  final Apiary? apiary;
  final String group;
  final String item;
  final String? variant;
  final String? notes;
  final String? receiptImagePath;
  final bool confirmed;

  AddSpendingDialogResult({
    required this.amount,
    required this.date,
    required this.apiary,
    required this.group,
    required this.item,
    this.variant,
    this.notes,
    this.receiptImagePath,
    required this.confirmed,
  });
}

class AddSpendingCubit extends Cubit<AddSpendingState> {
  final StorageService _storageService = GetIt.instance<StorageService>();

  AddSpendingCubit({
    required double initialAmount,
    required DateTime initialDate,
    required String group,
    required String item,
    String? variant,
    Apiary? initialApiary,
    String? notes,
  }) : super(AddSpendingState(
          amount: initialAmount,
          date: initialDate,
          group: group,
          item: item,
          variant: variant,
          apiary: initialApiary,
          notes: notes,
        ));

  void updateAmount(double amount) {
    emit(state.copyWith(amount: amount));
  }

  void updateDate(DateTime date) {
    emit(state.copyWith(date: date));
  }

  void updateApiary(Apiary? apiary) {
    emit(state.copyWith(apiary: apiary));
  }

  void updateNotes(String? notes) {
    emit(state.copyWith(notes: notes));
  }

  void updateReceiptImage(String? imagePath) {
    emit(state.copyWith(receiptImagePath: imagePath));
  }

  Future<void> pickReceiptImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source);
      
      if (image != null) {
        updateReceiptImage(image.path);
      }
    } catch (e) {
      emit(state.copyWith(error: 'storage.failed_pick_image'.tr(namedArgs: {'error': e.toString()})));
    }
  }

  void removeReceiptImage() {
    updateReceiptImage(null);
  }

  Future<void> saveTransaction() async {
    emit(state.copyWith(isLoading: true));
    
    try {
      final transaction = StorageTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        type: TransactionType.expense,
        group: state.group,
        item: state.item,
        variant: state.variant,
        amount: state.amount,
        date: state.date,
        apiaryId: state.apiary?.id,
        notes: state.notes,
        receiptImageName: state.receiptImagePath, // Will be processed by repository
        affectsStorage: true,
      );

      await _storageService.saveTransaction(transaction);
      emit(state.copyWith(isLoading: false, isSuccess: true));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}

class AddSpendingState {
  final double amount;
  final DateTime date;
  final String group;
  final String item;
  final String? variant;
  final Apiary? apiary;
  final String? notes;
  final String? receiptImagePath;
  final bool isLoading;
  final bool isSuccess;
  final String? error;

  AddSpendingState({
    required this.amount,
    required this.date,
    required this.group,
    required this.item,
    this.variant,
    this.apiary,
    this.notes,
    this.receiptImagePath,
    this.isLoading = false,
    this.isSuccess = false,
    this.error,
  });

  AddSpendingState copyWith({
    double? amount,
    DateTime? date,
    String? group,
    String? item,
    String? variant,
    Apiary? apiary,
    String? notes,
    String? receiptImagePath,
    bool? isLoading,
    bool? isSuccess,
    String? error,
  }) {
    return AddSpendingState(
      amount: amount ?? this.amount,
      date: date ?? this.date,
      group: group ?? this.group,
      item: item ?? this.item,
      variant: variant ?? this.variant,
      apiary: apiary ?? this.apiary,
      notes: notes ?? this.notes,
      receiptImagePath: receiptImagePath ?? this.receiptImagePath,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
    );
  }
}

Future<AddSpendingDialogResult?> showAddSpendingDialog({
  required BuildContext context,
  required String group,
  required String item,
  String? variant,
  double initialAmount = 0.0,
  DateTime? initialDate,
  required List<Apiary> apiaries,
  Apiary? initialApiary,
  String? notes,
  String? defaultCurrency,
  double? cost, // Add cost parameter from breed/hive type
}) {
  return showDialog<AddSpendingDialogResult>(
    context: context,
    builder: (ctx) => BlocProvider(
      create: (_) => AddSpendingCubit(
        initialAmount: cost ?? initialAmount, // Use cost if provided
        initialDate: initialDate ?? DateTime.now(),
        group: group,
        item: item,
        variant: variant,
        initialApiary: initialApiary,
        notes: notes,
      ),
      child: AddSpendingDialog(
        apiaries: apiaries,
        defaultCurrency: defaultCurrency,
      ),
    ),
  );
}

class AddSpendingDialog extends StatelessWidget {
  final List<Apiary> apiaries;
  final String? defaultCurrency;

  const AddSpendingDialog({
    super.key,
    required this.apiaries,
    this.defaultCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddSpendingCubit, AddSpendingState>(
      listener: (context, state) {
        if (state.isSuccess) {
          Navigator.of(context).pop(AddSpendingDialogResult(
            amount: state.amount,
            date: state.date,
            apiary: state.apiary,
            group: state.group,
            item: state.item,
            variant: state.variant,
            notes: state.notes,
            receiptImagePath: state.receiptImagePath,
            confirmed: true,
          ));
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddSpendingCubit>();

        return AlertDialog(
          backgroundColor: Colors.white,
          contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          title: Row(
            children: [
              Icon(Icons.money_off, color: Colors.amber.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'storage.add_expense'.tr(),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              // Removed calendar icon from here
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item info (compact, light background)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.label_important, color: Colors.amber.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.group} / ${state.item}',
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              if (state.variant != null)
                                Text(
                                  state.variant!,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  NumericInputField(
                    labelText: 'storage.amount'.tr(),
                    value: state.amount,
                    min: 0,
                    max: 999999,
                    allowDecimal: true,
                    decimalPlaces: 2,
                    step: 1.0,
                    onChanged: cubit.updateAmount,
                    helperText: defaultCurrency != null 
                        ? 'storage.currency_hint'.tr(namedArgs: {'currency': defaultCurrency!})
                        : null,
                  ),
                  const SizedBox(height: 12),

                  // Date input field (medium size)
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: state.date,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        cubit.updateDate(picked);
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'common.date'.tr(),
                        border: const OutlineInputBorder(),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14), // smaller than before
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat.yMMMd().format(state.date),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500), // slightly smaller
                          ),
                          const Icon(Icons.calendar_today, size: 20), // slightly smaller
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Advanced section (expandable, slightly larger font)
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: false,
                    title: Row(
                      children: [
                        Icon(Icons.tune, size: 18, color: Colors.amber.shade700),
                        const SizedBox(width: 6),
                        Text(
                          'common.advanced'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                        ),
                      ],
                    ),
                    children: [
                      const SizedBox(height: 12),
                      
                      // Apiary dropdown
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'apiary.apiary'.tr(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          RoundedDropdown<Apiary?>(
                            value: state.apiary,
                            items: [null, ...apiaries],
                            onChanged: cubit.updateApiary,
                            hintText: 'apiary.filter.select',
                            translate: true,
                            minHeight: 52,
                            itemBuilder: (context, apiary, isSelected) {
                              if (apiary == null) {
                                return Text(
                                  'apiary.filter.none'.tr(),
                                  style: TextStyle(
                                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                );
                              }
                              return Text(
                                apiary.name,
                                style: TextStyle(
                                  color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 15,
                                ),
                              );
                            },
                            buttonItemBuilder: (context, apiary) {
                              if (apiary == null) {
                                return Container(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'apiary.filter.none'.tr(),
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                );
                              }
                              return Container(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  apiary.name,
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Receipt image
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'storage.receipt_image'.tr(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          if (state.receiptImagePath != null) ...[
                            Container(
                              height: 110,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade200),
                                color: Colors.grey.shade50,
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      File(state.receiptImagePath!),
                                      height: 110,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: cubit.removeReceiptImage,
                                      child: Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: () => cubit.pickReceiptImage(ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt, size: 17),
                                    label: Text('storage.camera'.tr()),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    onPressed: () => cubit.pickReceiptImage(ImageSource.gallery),
                                    icon: const Icon(Icons.photo_library, size: 17),
                                    label: Text('storage.gallery'.tr()),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Notes field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'storage.notes'.tr(),
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            initialValue: state.notes,
                            decoration: InputDecoration(
                              hintText: 'storage.notes_hint'.tr(),
                              border: const OutlineInputBorder(),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                            ),
                            maxLines: 3,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                            onChanged: cubit.updateNotes,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: state.isLoading ? null : () => Navigator.of(context).pop(),
              child: Text('common.dont'.tr(), style: const TextStyle(fontSize: 15)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                minimumSize: const Size(100, 44),
              ),
              onPressed: state.isLoading 
                  ? null 
                  : () => cubit.saveTransaction(),
              child: state.isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('common.add'.tr()),
            ),
          ],
        );
      },
    );
  }
}
