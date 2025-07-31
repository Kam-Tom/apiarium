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
  final double? cost;
  
  final String breedId;
  final String breedName;
  final String? breedScientificName;
  final String? breedOrigin;
  final String? hiveId;
  final String? hiveName;
  final String? apiaryId;
  final String? apiaryName;
  final String? apiaryLocation;
  final DateTime? lastTimeSeen;

  const Queen({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    super.serverVersion = 0,
    required this.name,
    required this.birthDate,
    required this.source,
    required this.marked,
    this.markColor,
    required this.status,
    this.origin,
    this.cost,
    required this.breedId,
    required this.breedName,
    this.breedScientificName,
    this.breedOrigin,    
    this.hiveId,
    this.hiveName,
    this.apiaryId,
    this.apiaryName,
    this.apiaryLocation,
    this.lastTimeSeen,
  });

  factory Queen.fromMap(Map<String, dynamic> data) {
    return Queen(
      id: data['id'],
      createdAt: DateTime.parse(data['createdAt']),
      updatedAt: DateTime.parse(data['updatedAt']),
      syncStatus: SyncStatus.values.firstWhere(
        (s) => s.name == data['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
      lastSyncedAt: data['lastSyncedAt'] != null 
          ? DateTime.parse(data['lastSyncedAt']) 
          : null,
      deleted: data['deleted'] ?? false,
      serverVersion: data['serverVersion'] ?? 0,
      name: data['name'],
      birthDate: DateTime.parse(data['birthDate']),
      source: QueenSource.values.firstWhere(
        (s) => s.name == data['source'],
        orElse: () => QueenSource.bred,
      ),
      marked: data['marked'] ?? false,
      markColor: data['markColor'] != null ? Color(data['markColor']) : null,
      status: QueenStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => QueenStatus.active,
      ),
      origin: data['origin'],
      cost: data['cost']?.toDouble(),
      breedId: data['breedId'],
      breedName: data['breedName'],
      breedScientificName: data['breedScientificName'],
      breedOrigin: data['breedOrigin'],
      hiveId: data['hiveId'],
      hiveName: data['hiveName'],
      apiaryId: data['apiaryId'],
      apiaryName: data['apiaryName'],
      apiaryLocation: data['apiaryLocation'],
      lastTimeSeen: data['lastTimeSeen'] != null ? DateTime.parse(data['lastTimeSeen']) : null,
    );
  }

  int get ageInDays => DateTime.now().difference(birthDate).inDays;
  int get ageInWeeks => (ageInDays / 7).floor();
  double get ageInYears => DateTime.now().difference(birthDate).inDays / 365.25;

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, birthDate, source, marked, markColor, status, origin, cost,
    breedId, breedName, breedScientificName, breedOrigin,
    hiveId, hiveName, apiaryId, apiaryName, apiaryLocation,
    lastTimeSeen,
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
      'cost': cost,
      'breedId': breedId,
      'breedName': breedName,
      'breedScientificName': breedScientificName,
      'breedOrigin': breedOrigin,      
      'hiveId': hiveId,
      'hiveName': hiveName,
      'apiaryId': apiaryId,
      'apiaryName': apiaryName,
      'apiaryLocation': apiaryLocation,
      'lastTimeSeen': lastTimeSeen?.toIso8601String(),
    };
  }
  
  Queen copyWith({
    String Function()? name,
    DateTime Function()? birthDate,
    QueenSource Function()? source,
    bool Function()? marked,
    Color? Function()? markColor,
    QueenStatus Function()? status,
    String? Function()? origin,
    double? Function()? cost,
    String Function()? breedId,
    String Function()? breedName,
    String? Function()? breedScientificName,
    String? Function()? breedOrigin,    
    String? Function()? hiveId,
    String? Function()? hiveName,
    String? Function()? apiaryId,
    String? Function()? apiaryName,
    String? Function()? apiaryLocation,
    DateTime Function()? updatedAt,
    SyncStatus Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool Function()? deleted,
    DateTime? Function()? lastTimeSeen,
    int Function()? serverVersion,
  }) {
    return Queen(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : SyncStatus.pending,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      name: name != null ? name() : this.name,
      birthDate: birthDate != null ? birthDate() : this.birthDate,
      source: source != null ? source() : this.source,
      marked: marked != null ? marked() : this.marked,
      markColor: markColor != null ? markColor() : this.markColor,
      status: status != null ? status() : this.status,
      origin: origin != null ? origin() : this.origin,
      cost: cost != null ? cost() : this.cost,
      breedId: breedId != null ? breedId() : this.breedId,
      breedName: breedName != null ? breedName() : this.breedName,
      breedScientificName: breedScientificName != null ? breedScientificName() : this.breedScientificName,
      breedOrigin: breedOrigin != null ? breedOrigin() : this.breedOrigin,
      hiveId: hiveId != null ? hiveId() : this.hiveId,
      hiveName: hiveName != null ? hiveName() : this.hiveName,
      apiaryId: apiaryId != null ? apiaryId() : this.apiaryId,
      apiaryName: apiaryName != null ? apiaryName() : this.apiaryName,
      apiaryLocation: apiaryLocation != null ? apiaryLocation() : this.apiaryLocation,
      lastTimeSeen: lastTimeSeen != null ? lastTimeSeen() : this.lastTimeSeen,
      serverVersion: serverVersion != null ? serverVersion() : this.serverVersion,
    );
  }

  @override
  String toString() {
    return name;
  }
}
