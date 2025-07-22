import 'package:apiarium/shared/shared.dart';

class StorageItem extends BaseModel {
  final String group; // e.g., 'accessories', 'honey'
  final String item; // e.g., 'frames', 'honey extractor', 'sunflower'
  final String? variant; // e.g., '0.7L', '1L'
  final double currentAmount; // Current quantity in storage
  final String? unit; // e.g., 'pieces', 'liters', 'kg'
  final double? lastPrice; // Most recent unit price for this item
  final DateTime? lastPriceUpdate; // When the price was last updated
  final String? notes;

  const StorageItem({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    required this.group,
    required this.item,
    this.variant,
    required this.currentAmount,
    this.unit,
    this.lastPrice,
    this.lastPriceUpdate,
    this.notes,
  });

  double get estimatedValue => lastPrice != null ? lastPrice! * currentAmount : 0;

  factory StorageItem.fromMap(Map<String, dynamic> map) {
    return StorageItem(
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
      group: map['group'] as String,
      item: map['item'] as String,
      variant: map['variant'] as String?,
      currentAmount: map['currentAmount'] is int
          ? (map['currentAmount'] as int).toDouble()
          : map['currentAmount'] as double,
      unit: map['unit'] as String?,
      lastPrice: map['lastPrice'] as double?,
      lastPriceUpdate: map['lastPriceUpdate'] != null
          ? DateTime.parse(map['lastPriceUpdate'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'group': group,
      'item': item,
      'variant': variant,
      'currentAmount': currentAmount,
      'unit': unit,
      'lastPrice': lastPrice,
      'lastPriceUpdate': lastPriceUpdate?.toIso8601String(),
      'notes': notes,
    };
  }

  StorageItem copyWith({
    String? group,
    String? item,
    String? variant,
    double? currentAmount,
    String? unit,
    double? lastPrice,
    DateTime? lastPriceUpdate,
    String? notes,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return StorageItem(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      group: group ?? this.group,
      item: item ?? this.item,
      variant: variant ?? this.variant,
      currentAmount: currentAmount ?? this.currentAmount,
      unit: unit ?? this.unit,
      lastPrice: lastPrice ?? this.lastPrice,
      lastPriceUpdate: lastPriceUpdate ?? this.lastPriceUpdate,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    group, item, variant, currentAmount, unit, lastPrice, lastPriceUpdate, notes,
  ];
}