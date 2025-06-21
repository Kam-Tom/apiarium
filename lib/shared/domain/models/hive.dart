import 'dart:core';

import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class Hive extends BaseModel {  
  final String name;
  final String apiaryId;
  final String apiaryName;
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
  final String? breed;
  final double? queenAgeInYears;

  const Hive({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,    
    required this.name,
    required this.apiaryId,
    required this.apiaryName,
    this.apiaryLocation,
    required this.status,
    required this.acquisitionDate,
    this.imageUrl,
    required this.order,
    this.color,    required this.hiveTypeId,
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
    this.breed,
    this.queenAgeInYears,
  });

  bool get hasQueen => queenId != null;
  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, apiaryId, apiaryName, apiaryLocation, status, acquisitionDate, imageUrl, order, color,
    hiveTypeId, hiveType, manufacturer, material, hasFrames, broodFrameCount, honeyFrameCount, frameStandard,
    boxCount, superBoxCount, framesPerBox, maxBroodFrameCount, maxHoneyFrameCount, maxBoxCount, maxSuperBoxCount,
    accessories, cost, currentBroodFrameCount, currentHoneyFrameCount, currentBoxCount, currentSuperBoxCount,
    queenId, queenName, queenMarked, breed, queenAgeInYears,
  ];
    Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,      'name': name,
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
      'breed': breed,
      'queenAgeInYears': queenAgeInYears,
    };
  }Hive copyWith({    String? name,
    String? apiaryId,
    String? apiaryName,
    String? apiaryLocation,
    HiveStatus? status,
    DateTime? acquisitionDate,
    String? imageUrl,
    int? position,
    Color? color,
    String? hiveTypeId,
    String? hiveType,
    String? manufacturer,
    HiveMaterial? material,
    bool? hasFrames,
    int? broodFrameCount,
    int? honeyFrameCount,
    String? frameStandard,
    int? boxCount,
    int? superBoxCount,
    int? framesPerBox,
    int? maxBroodFrameCount,
    int? maxHoneyFrameCount,
    int? maxBoxCount,
    int? maxSuperBoxCount,
    List<String>? accessories,
    double? cost,
    int? currentBroodFrameCount,
    int? currentHoneyFrameCount,
    int? currentBoxCount,
    int? currentSuperBoxCount,    
    String? queenId,
    String? queenName,
    bool? queenMarked,
    String? breed,
    double? queenAgeInYears,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return Hive(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,      name: name ?? this.name,
      apiaryId: apiaryId ?? this.apiaryId,
      apiaryName: apiaryName ?? this.apiaryName,
      apiaryLocation: apiaryLocation ?? this.apiaryLocation,
      status: status ?? this.status,
      acquisitionDate: acquisitionDate ?? this.acquisitionDate,
      imageUrl: imageUrl ?? this.imageUrl,
      order: position ?? this.order,
      color: color ?? this.color,
      hiveTypeId: hiveTypeId ?? this.hiveTypeId,
      hiveType: hiveType ?? this.hiveType,
      manufacturer: manufacturer ?? this.manufacturer,
      material: material ?? this.material,
      hasFrames: hasFrames ?? this.hasFrames,
      broodFrameCount: broodFrameCount ?? this.broodFrameCount,
      honeyFrameCount: honeyFrameCount ?? this.honeyFrameCount,
      frameStandard: frameStandard ?? this.frameStandard,
      boxCount: boxCount ?? this.boxCount,
      superBoxCount: superBoxCount ?? this.superBoxCount,
      framesPerBox: framesPerBox ?? this.framesPerBox,
      maxBroodFrameCount: maxBroodFrameCount ?? this.maxBroodFrameCount,
      maxHoneyFrameCount: maxHoneyFrameCount ?? this.maxHoneyFrameCount,
      maxBoxCount: maxBoxCount ?? this.maxBoxCount,
      maxSuperBoxCount: maxSuperBoxCount ?? this.maxSuperBoxCount,
      accessories: accessories ?? this.accessories,
      cost: cost ?? this.cost,
      currentBroodFrameCount: currentBroodFrameCount ?? this.currentBroodFrameCount,
      currentHoneyFrameCount: currentHoneyFrameCount ?? this.currentHoneyFrameCount,
      currentBoxCount: currentBoxCount ?? this.currentBoxCount,
      currentSuperBoxCount: currentSuperBoxCount ?? this.currentSuperBoxCount,      
      queenId: queenId ?? this.queenId,
      queenName: queenName ?? this.queenName,
      queenMarked: queenMarked ?? this.queenMarked,
      breed: breed ?? this.breed,
      queenAgeInYears: queenAgeInYears ?? this.queenAgeInYears,
    );
  }
}
