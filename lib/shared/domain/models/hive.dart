import 'dart:core';

import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class Hive extends BaseModel {  
  final String name;
  final String? apiaryId;
  final String? apiaryName;
  final String? apiaryLocation;
  final HiveStatus status;
  final DateTime acquisitionDate;
  final String? imageUrl;
  final int order;
  final Color? color;  
  // Hive type reference and denormalized data
  final String hiveTypeId;
  final String hiveType;
  final String? manufacturer;
  final HiveMaterial material;
  final bool hasFrames;
  final int? broodFrameCount;
  final int? honeyFrameCount;
  final String? frameStandard;
  final int? boxCount;
  final int? superBoxCount;
  final int? framesPerBox;
  final int? maxBroodFrameCount;
  final int? maxHoneyFrameCount;
  final int? maxBoxCount;
  final int? maxSuperBoxCount;
  final List<String>? accessories;
  final double? cost;
  // Current hive state
  final int? currentBroodFrameCount;
  final int? currentHoneyFrameCount;
  final int? currentBoxCount;
  final int? currentSuperBoxCount;   
  // Queen data (optional)
  final String? queenId;
  final String? queenName;
  final bool? queenMarked;
  final Color? queenMarkColor;
  final String? breed;
  final DateTime? queenBirthDate;
  final int? familyStrength;
  final DateTime? lastInspection;
  final DateTime? lastTimeQueenSeen;
  
  const Hive({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,    
    super.serverVersion = 0,
    required this.name,
    this.apiaryId,
    this.apiaryName,
    this.apiaryLocation,
    required this.status,
    required this.acquisitionDate,
    this.imageUrl,
    required this.order,
    this.color,
    required this.hiveTypeId,
    required this.hiveType,
    this.manufacturer,
    required this.material,
    required this.hasFrames,
    this.broodFrameCount,
    this.honeyFrameCount,
    this.frameStandard,
    this.boxCount,
    this.superBoxCount,
    this.framesPerBox,
    this.maxBroodFrameCount,
    this.maxHoneyFrameCount,
    this.maxBoxCount,
    this.maxSuperBoxCount,
    this.accessories,
    this.cost,
    this.currentBroodFrameCount,
    this.currentHoneyFrameCount,
    this.currentBoxCount,
    this.currentSuperBoxCount,      
    this.queenId,
    this.queenName,
    this.queenMarked,
    this.queenMarkColor,
    this.breed,
    this.queenBirthDate,
    this.familyStrength,
    this.lastInspection,
    this.lastTimeQueenSeen,
  });
  
  factory Hive.fromMap(Map<String, dynamic> map) {
    return Hive(
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
      serverVersion: map['serverVersion'] as int? ?? 0,
      name: map['name'] as String,
      apiaryId: map['apiaryId'] as String?,
      apiaryName: map['apiaryName'] as String?,
      apiaryLocation: map['apiaryLocation'] as String?,
      status: HiveStatus.values.firstWhere((e) => e.name == map['status']),
      acquisitionDate: DateTime.parse(map['acquisitionDate'] as String),
      imageUrl: map['imageUrl'] as String?,
      order: map['order'] as int,
      color: map['color'] != null ? Color(map['color'] as int) : null,
      hiveTypeId: map['hiveTypeId'] as String,
      hiveType: map['hiveType'] as String,
      manufacturer: map['manufacturer'] as String?,
      material: HiveMaterial.values.firstWhere((e) => e.name == map['material']),
      hasFrames: map['hasFrames'] as bool,
      broodFrameCount: map['broodFrameCount'] as int?,
      honeyFrameCount: map['honeyFrameCount'] as int?,
      frameStandard: map['frameStandard'] as String?,
      boxCount: map['boxCount'] as int?,
      superBoxCount: map['superBoxCount'] as int?,
      framesPerBox: map['framesPerBox'] as int?,
      maxBroodFrameCount: map['maxBroodFrameCount'] as int?,
      maxHoneyFrameCount: map['maxHoneyFrameCount'] as int?,
      maxBoxCount: map['maxBoxCount'] as int?,
      maxSuperBoxCount: map['maxSuperBoxCount'] as int?,
      accessories: map['accessories'] != null 
          ? List<String>.from(map['accessories'] as List)
          : null,
      cost: map['cost'] as double?,
      currentBroodFrameCount: map['currentBroodFrameCount'] as int?,
      currentHoneyFrameCount: map['currentHoneyFrameCount'] as int?,
      currentBoxCount: map['currentBoxCount'] as int?,
      currentSuperBoxCount: map['currentSuperBoxCount'] as int?,      
      queenId: map['queenId'] as String?,
      queenName: map['queenName'] as String?,
      queenMarked: map['queenMarked'] as bool?,
      queenMarkColor: map['queenMarkColor'] != null ? Color(map['queenMarkColor'] as int) : null,
      breed: map['breed'] as String?,
      queenBirthDate: map['queenBirthDate'] != null ? DateTime.parse(map['queenBirthDate']) : null,
      familyStrength: map['familyStrength'] as int?,
      lastInspection: map['lastInspection'] != null ? DateTime.parse(map['lastInspection']) : null,
      lastTimeQueenSeen: map['lastTimeQueenSeen'] != null ? DateTime.parse(map['lastTimeQueenSeen']) : null,
    );
  }

  bool get hasQueen => queenId != null;
  
  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, apiaryId, apiaryName, apiaryLocation, status, acquisitionDate, imageUrl, order, color,
    hiveTypeId, hiveType, manufacturer, material, hasFrames, broodFrameCount, honeyFrameCount, frameStandard,
    boxCount, superBoxCount, framesPerBox, maxBroodFrameCount, maxHoneyFrameCount, maxBoxCount, maxSuperBoxCount,    accessories, cost, currentBroodFrameCount, currentHoneyFrameCount, currentBoxCount, currentSuperBoxCount,
    queenId, queenName, queenMarked, queenMarkColor, breed, queenBirthDate,
    familyStrength, lastInspection, lastTimeQueenSeen,
  ];

  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,      
      'name': name,
      'apiaryId': apiaryId,
      'apiaryName': apiaryName,
      'apiaryLocation': apiaryLocation,
      'status': status.name,
      'acquisitionDate': acquisitionDate.toIso8601String(),
      'imageUrl': imageUrl,
      'order': order,
      'color': color?.toARGB32(),
      'hiveTypeId': hiveTypeId,
      'hiveType': hiveType,
      'manufacturer': manufacturer,
      'material': material.name,
      'hasFrames': hasFrames,
      'broodFrameCount': broodFrameCount,
      'honeyFrameCount': honeyFrameCount,
      'frameStandard': frameStandard,
      'boxCount': boxCount,
      'superBoxCount': superBoxCount,
      'framesPerBox': framesPerBox,
      'maxBroodFrameCount': maxBroodFrameCount,
      'maxHoneyFrameCount': maxHoneyFrameCount,
      'maxBoxCount': maxBoxCount,
      'maxSuperBoxCount': maxSuperBoxCount,
      'accessories': accessories,
      'cost': cost,
      'currentBroodFrameCount': currentBroodFrameCount,
      'currentHoneyFrameCount': currentHoneyFrameCount,
      'currentBoxCount': currentBoxCount,
      'currentSuperBoxCount': currentSuperBoxCount,        
      'queenId': queenId,
      'queenName': queenName,
      'queenMarked': queenMarked,
      'queenMarkColor': queenMarkColor?.toARGB32(),
      'breed': breed,
      'queenBirthDate': queenBirthDate?.toIso8601String(),
      'familyStrength': familyStrength,
      'lastInspection': lastInspection?.toIso8601String(),
      'lastTimeQueenSeen': lastTimeQueenSeen?.toIso8601String(),
    };
  }
  Hive copyWith({    
    String? Function()? name,
    String? Function()? apiaryId,
    String? Function()? apiaryName,
    String? Function()? apiaryLocation,
    HiveStatus? Function()? status,
    DateTime? Function()? acquisitionDate,
    String? Function()? imageUrl,
    int? Function()? order,
    Color? Function()? color,
    String? Function()? hiveTypeId,
    String? Function()? hiveType,
    String? Function()? manufacturer,
    HiveMaterial? Function()? material,
    bool? Function()? hasFrames,
    int? Function()? broodFrameCount,
    int? Function()? honeyFrameCount,
    String? Function()? frameStandard,
    int? Function()? boxCount,
    int? Function()? superBoxCount,
    int? Function()? framesPerBox,
    int? Function()? maxBroodFrameCount,
    int? Function()? maxHoneyFrameCount,
    int? Function()? maxBoxCount,
    int? Function()? maxSuperBoxCount,
    List<String>? Function()? accessories,
    double? Function()? cost,
    int? Function()? currentBroodFrameCount,
    int? Function()? currentHoneyFrameCount,
    int? Function()? currentBoxCount,
    int? Function()? currentSuperBoxCount,
    String? Function()? queenId,
    String? Function()? queenName,
    bool? Function()? queenMarked,
    Color? Function()? queenMarkColor,
    String? Function()? breed,
    DateTime? Function()? queenBirthDate,
    int? Function()? familyStrength,
    DateTime? Function()? lastInspection,
    DateTime? Function()? updatedAt,
    SyncStatus? Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool? Function()? deleted,
    int? Function()? serverVersion,
    DateTime? Function()? lastTimeQueenSeen,
  }) {
    return Hive(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt?.call() ?? DateTime.now(),
      syncStatus: syncStatus?.call() ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt?.call() ?? this.lastSyncedAt,
      deleted: deleted?.call() ?? this.deleted,
      serverVersion: serverVersion?.call() ?? this.serverVersion,
      name: name?.call() ?? this.name,
      apiaryId: apiaryId?.call() ?? this.apiaryId,
      apiaryName: apiaryName?.call() ?? this.apiaryName,
      apiaryLocation: apiaryLocation?.call() ?? this.apiaryLocation,
      status: status?.call() ?? this.status,
      acquisitionDate: acquisitionDate?.call() ?? this.acquisitionDate,
      imageUrl: imageUrl?.call() ?? this.imageUrl,
      order: order?.call() ?? this.order,
      color: color?.call() ?? this.color,
      hiveTypeId: hiveTypeId?.call() ?? this.hiveTypeId,
      hiveType: hiveType?.call() ?? this.hiveType,
      manufacturer: manufacturer?.call() ?? this.manufacturer,
      material: material?.call() ?? this.material,
      hasFrames: hasFrames?.call() ?? this.hasFrames,
      broodFrameCount: broodFrameCount?.call() ?? this.broodFrameCount,
      honeyFrameCount: honeyFrameCount?.call() ?? this.honeyFrameCount,
      frameStandard: frameStandard?.call() ?? this.frameStandard,
      boxCount: boxCount?.call() ?? this.boxCount,
      superBoxCount: superBoxCount?.call() ?? this.superBoxCount,
      framesPerBox: framesPerBox?.call() ?? this.framesPerBox,
      maxBroodFrameCount: maxBroodFrameCount?.call() ?? this.maxBroodFrameCount,
      maxHoneyFrameCount: maxHoneyFrameCount?.call() ?? this.maxHoneyFrameCount,
      maxBoxCount: maxBoxCount?.call() ?? this.maxBoxCount,
      maxSuperBoxCount: maxSuperBoxCount?.call() ?? this.maxSuperBoxCount,
      accessories: accessories?.call() ?? this.accessories,
      cost: cost?.call() ?? this.cost,
      currentBroodFrameCount: currentBroodFrameCount?.call() ?? this.currentBroodFrameCount,
      currentHoneyFrameCount: currentHoneyFrameCount?.call() ?? this.currentHoneyFrameCount,
      currentBoxCount: currentBoxCount?.call() ?? this.currentBoxCount,
      currentSuperBoxCount: currentSuperBoxCount?.call() ?? this.currentSuperBoxCount,
      queenId: queenId?.call() ?? this.queenId,
      queenName: queenName?.call() ?? this.queenName,
      queenMarked: queenMarked?.call() ?? this.queenMarked,
      queenMarkColor: queenMarkColor?.call() ?? this.queenMarkColor,
      breed: breed?.call() ?? this.breed,
      queenBirthDate: queenBirthDate?.call() ?? this.queenBirthDate,
      familyStrength: familyStrength?.call() ?? this.familyStrength,
      lastInspection: lastInspection?.call() ?? this.lastInspection,
      lastTimeQueenSeen: lastTimeQueenSeen?.call() ?? this.lastTimeQueenSeen,
    );
  }

  @override
  String toString() {
    return name;
  }
}
