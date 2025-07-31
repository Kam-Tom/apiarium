import 'package:apiarium/shared/shared.dart';
import 'package:path_provider/path_provider.dart';

enum TransactionType {
  expense, // Purchase/cost
  income,  // Sale/revenue  
  use,     // Consumption/usage
  remove,  // Removal from storage
}

class StorageTransaction extends BaseModel {
  final String? apiaryId;
  final String group;
  final String item;
  final String? variant;
  final double amount;
  final TransactionType type;
  final String? sourceOrTarget;
  final DateTime date;
  final double? unitPrice;
  final String? notes;
  final String? receiptImageName; // Filename for receipt image (like imageName in Apiary)
  final bool affectsStorage; // Whether this transaction affects storage
  final String? storageItemId; // Reference to the storage item this affects

  const StorageTransaction({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    this.apiaryId,
    required this.group,
    required this.item,
    this.variant,
    required this.amount,
    required this.type,
    this.sourceOrTarget,
    required this.date,
    this.unitPrice,
    this.notes,
    this.receiptImageName,
    this.affectsStorage = true,
    this.storageItemId,
  });

  double get totalCost => unitPrice != null ? unitPrice! * amount : 0;

  /// Returns the local file path for the receipt image
  Future<String?> getLocalReceiptPath() async {
    if (receiptImageName == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/images/receipts/$receiptImageName';
  }

  factory StorageTransaction.fromMap(Map<String, dynamic> map) {
    return StorageTransaction(
      id: map['id'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      syncStatus: map['syncStatus'] != null
          ? SyncStatus.values.firstWhere((e) => e.name == map['syncStatus'])
          : SyncStatus.pending,
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'] as String)
          : null,
      deleted: map['deleted'] as bool? ?? false,
      apiaryId: map['apiaryId'] as String?,
      group: map['group'] as String,
      item: map['item'] as String,
      variant: map['variant'] as String?,
      amount: map['amount'] is int
          ? (map['amount'] as int).toDouble()
          : map['amount'] as double,
      type: TransactionType.values.firstWhere((e) => e.name == map['type']),
      sourceOrTarget: map['sourceOrTarget'] as String?,
      date: DateTime.parse(map['date'] as String),
      unitPrice: map['unitPrice'] as double?,
      notes: map['notes'] as String?,
      receiptImageName: map['receiptImageName'] as String?,
      affectsStorage: map['affectsStorage'] as bool? ?? true,
      storageItemId: map['storageItemId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'apiaryId': apiaryId,
      'group': group,
      'item': item,
      'variant': variant,
      'amount': amount,
      'type': type.name,
      'sourceOrTarget': sourceOrTarget,
      'date': date.toIso8601String(),
      'unitPrice': unitPrice,
      'notes': notes,
      'receiptImageName': receiptImageName,
      'affectsStorage': affectsStorage,
      'storageItemId': storageItemId,
    };
  }

  StorageTransaction copyWith({
    String? Function()? apiaryId,
    String Function()? group,
    String Function()? item,
    String? Function()? variant,
    double Function()? amount,
    TransactionType Function()? type,
    String? Function()? sourceOrTarget,
    DateTime Function()? date,
    double? Function()? unitPrice,
    String? Function()? notes,
    String? Function()? receiptImageName,
    bool Function()? affectsStorage,
    String? Function()? storageItemId,
    DateTime Function()? updatedAt,
    SyncStatus Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool Function()? deleted,
  }) {
    return StorageTransaction(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : SyncStatus.pending,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
      group: group != null ? group() : this.group,
      item: item != null ? item() : this.item,
      variant: variant != null ? variant() : this.variant,
      amount: amount != null ? amount() : this.amount,
      type: type != null ? type() : this.type,
      sourceOrTarget: sourceOrTarget != null ? sourceOrTarget() : this.sourceOrTarget,
      date: date != null ? date() : this.date,
      unitPrice: unitPrice != null ? unitPrice() : this.unitPrice,
      notes: notes != null ? notes() : this.notes,
      receiptImageName: receiptImageName != null ? receiptImageName() : this.receiptImageName,
      affectsStorage: affectsStorage != null ? affectsStorage() : this.affectsStorage,
      storageItemId: storageItemId != null ? storageItemId() : this.storageItemId,
    );
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    apiaryId, group, item, variant, amount, type,
    sourceOrTarget, date, unitPrice, notes, receiptImageName, affectsStorage, storageItemId,
  ];
}
