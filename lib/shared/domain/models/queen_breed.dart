import 'package:apiarium/shared/shared.dart';

class QueenBreed extends BaseModel {
  final String name;
  final String? scientificName;
  final String? origin;
  final String? country;
  final bool isStarred;

  const QueenBreed({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    required this.name,
    this.scientificName,
    this.origin,
    this.country,
    this.isStarred = false,
  });

  String get displayName => scientificName != null 
    ? '$name ($scientificName)'
    : name;

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, scientificName, origin, country, isStarred
  ];

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'name': name,
      'scientificName': scientificName,
      'origin': origin,
      'country': country,
      'isStarred': isStarred,
    };
  }
  
  QueenBreed copyWith({
    String? name,
    String? scientificName,
    String? origin,
    String? country,
    bool? isStarred,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return QueenBreed(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      origin: origin ?? this.origin,
      country: country ?? this.country,
      isStarred: isStarred ?? this.isStarred,
    );
  }
}
