import 'package:apiarium/shared/shared.dart';
import 'package:path_provider/path_provider.dart';

enum TransactionType { expense, income, use }

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
    };
  }

  StorageTransaction copyWith({
    String? apiaryId,
    String? group,
    String? item,
    String? variant,
    double? amount,
    TransactionType? type,
    String? sourceOrTarget,
    DateTime? date,
    double? unitPrice,
    String? notes,
    String? Function()? receiptImageName,
    bool? affectsStorage,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return StorageTransaction(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      apiaryId: apiaryId ?? this.apiaryId,
      group: group ?? this.group,
      item: item ?? this.item,
      variant: variant ?? this.variant,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      sourceOrTarget: sourceOrTarget ?? this.sourceOrTarget,
      date: date ?? this.date,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
      receiptImageName: receiptImageName?.call() ?? this.receiptImageName,
      affectsStorage: affectsStorage ?? this.affectsStorage,
    );
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    apiaryId, group, item, variant, amount, type,
    sourceOrTarget, date, unitPrice, notes, receiptImageName, affectsStorage,
  ];
}
