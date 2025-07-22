import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:apiarium/shared/domain/models/storage_item.dart';

class AddSpendingDialogState {
  final String? apiaryId;
  final String? apiaryName;
  final String group;
  final String item;
  final String? variant;
  final double amount;
  final String type;
  final String? sourceOrTarget;
  final DateTime date;
  final double? unitPrice;
  final String? notes;
  final List<String>? attachments;

  AddSpendingDialogState({
    this.apiaryId,
    this.apiaryName,
    this.group = '',
    this.item = '',
    this.variant,
    this.amount = 1,
    this.type = 'expense',
    this.sourceOrTarget,
    DateTime? date,
    this.unitPrice,
    this.notes,
    this.attachments,
  }) : date = date ?? DateTime.now();

  AddSpendingDialogState copyWith({
    String? apiaryId,
    String? apiaryName,
    String? group,
    String? item,
    String? variant,
    double? amount,
    String? type,
    String? sourceOrTarget,
    DateTime? date,
    double? unitPrice,
    String? notes,
    List<String>? attachments,
  }) {
    return AddSpendingDialogState(
      apiaryId: apiaryId ?? this.apiaryId,
      apiaryName: apiaryName ?? this.apiaryName,
      group: group ?? this.group,
      item: item ?? this.item,
      variant: variant ?? this.variant,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      sourceOrTarget: sourceOrTarget ?? this.sourceOrTarget,
      date: date ?? this.date,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
      attachments: attachments ?? this.attachments,
    );
  }
}

class AddSpendingDialogCubit extends Cubit<AddSpendingDialogState> {
  AddSpendingDialogCubit({AddSpendingDialogState? initial})
      : super(initial ?? AddSpendingDialogState());

  void updateField(String field, dynamic value) {
    switch (field) {
      case 'apiaryId':
        emit(state.copyWith(apiaryId: value));
        break;
      case 'apiaryName':
        emit(state.copyWith(apiaryName: value));
        break;
      case 'group':
        emit(state.copyWith(group: value));
        break;
      case 'item':
        emit(state.copyWith(item: value));
        break;
      case 'variant':
        emit(state.copyWith(variant: value));
        break;
      case 'amount':
        emit(state.copyWith(amount: value));
        break;
      case 'type':
        emit(state.copyWith(type: value));
        break;
      case 'sourceOrTarget':
        emit(state.copyWith(sourceOrTarget: value));
        break;
      case 'date':
        emit(state.copyWith(date: value));
        break;
      case 'unitPrice':
        emit(state.copyWith(unitPrice: value));
        break;
      case 'notes':
        emit(state.copyWith(notes: value));
        break;
      case 'attachments':
        emit(state.copyWith(attachments: value));
        break;
    }
  }
}
