import 'dart:core';

import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class Apiary extends BaseModel {
  final String name;
  final String? description;
  final String? location;
  final int position;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isMigratory;
  final Color? color;
  final ApiaryStatus status;
  final int hiveCount;
  final int activeHiveCount;

  const Apiary({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    super.lastSyncedAt,
    super.deleted = false,
    required this.name,
    this.description,
    this.location,
    required this.position,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isMigratory = false,
    this.color,
    this.status = ApiaryStatus.active,
    this.hiveCount = 0,
    this.activeHiveCount = 0,
  });

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, description, location, position, imageUrl, latitude, longitude,
    isMigratory, color, status, hiveCount, activeHiveCount,
  ];
  
  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'name': name,
      'description': description,
      'location': location,
      'position': position,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isMigratory': isMigratory,
      'color': color?.toARGB32(),
      'status': status.name,
      'hiveCount': hiveCount,
      'activeHiveCount': activeHiveCount,
    };
  }

  Apiary copyWith({
    String? name,
    String? description,
    String? location,
    int? position,
    String? imageUrl,
    double? latitude,
    double? longitude,
    bool? isMigratory,
    Color? color,
    ApiaryStatus? status,
    int? hiveCount,
    int? activeHiveCount,
    int? queenedHiveCount,
    DateTime? updatedAt,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    bool? deleted,
  }) {
    return Apiary(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      syncStatus: syncStatus ?? SyncStatus.pending,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deleted: deleted ?? this.deleted,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      position: position ?? this.position,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isMigratory: isMigratory ?? this.isMigratory,
      color: color ?? this.color,
      status: status ?? this.status,
      hiveCount: hiveCount ?? this.hiveCount,
      activeHiveCount: activeHiveCount ?? this.activeHiveCount,
    );
  }
}