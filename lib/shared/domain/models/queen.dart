import 'dart:core';
import 'dart:ui';

import 'package:apiarium/shared/shared.dart';

class Queen extends BaseModel {
  final String name;
  final DateTime birthDate;
  final QueenSource source;
  final bool marked;
  final Color? markColor;
  final QueenStatus status;
  final String? origin;
  
  final String breedId;
  final String breedName;
  final String? breedScientificName;
  final String? breedOrigin;
  final String? hiveId;
  final String? hiveName;
  final String? apiaryId;
  final String? apiaryName;
  final String? apiaryLocation;

  const Queen({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    required this.name,
    required this.birthDate,
    required this.source,
    required this.marked,
    this.markColor,
    required this.status,
    this.origin,
    required this.breedId,
    required this.breedName,
    this.breedScientificName,
    this.breedOrigin,    
    this.hiveId,
    this.hiveName,
    this.apiaryId,
    this.apiaryName,
    this.apiaryLocation,
  });

  int get ageInDays => DateTime.now().difference(birthDate).inDays;
  int get ageInWeeks => (ageInDays / 7).floor();

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, birthDate, source, marked, markColor, status, origin,
    breedId, breedName, breedScientificName, breedOrigin,
    hiveId, hiveName, apiaryId, apiaryName, apiaryLocation,
  ];

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'name': name,
      'birthDate': birthDate.toIso8601String(),
      'source': source.name,
      'marked': marked,
      'markColor': markColor?.toARGB32(),
      'status': status.name,
      'origin': origin,
      'breedId': breedId,
      'breedName': breedName,
      'breedScientificName': breedScientificName,
      'breedOrigin': breedOrigin,      
      'hiveId': hiveId,
      'hiveName': hiveName,
      'apiaryId': apiaryId,
      'apiaryName': apiaryName,
      'apiaryLocation': apiaryLocation,
    };
  }
  
  Queen copyWith({
    String? name,
    DateTime? birthDate,
    QueenSource? source,
    bool? marked,
    Color? markColor,
    QueenStatus? status,
    String? origin,
    String? breedId,
    String? breedName,
    String? breedScientificName,
    String? breedOrigin,    
    String? hiveId,
    String? hiveName,
    String? apiaryId,
    String? apiaryName,
    String? apiaryLocation,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return Queen(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      birthDate: birthDate ?? this.birthDate,
      source: source ?? this.source,
      marked: marked ?? this.marked,
      markColor: markColor ?? this.markColor,
      status: status ?? this.status,
      origin: origin ?? this.origin,
      breedId: breedId ?? this.breedId,
      breedName: breedName ?? this.breedName,
      breedScientificName: breedScientificName ?? this.breedScientificName,
      breedOrigin: breedOrigin ?? this.breedOrigin,      
      hiveId: hiveId ?? this.hiveId,
      hiveName: hiveName ?? this.hiveName,
      apiaryId: apiaryId ?? this.apiaryId,
      apiaryName: apiaryName ?? this.apiaryName,
      apiaryLocation: apiaryLocation ?? this.apiaryLocation,
    );
  }
}
