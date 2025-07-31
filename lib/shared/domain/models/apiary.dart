import 'dart:core';

import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Apiary extends BaseModel {
  final String name;
  final String? description;
  final String? location;
  final int order;
  final String? imageName;
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
    super.deleted = false,
    super.syncStatus,
    super.lastSyncedAt,
    super.serverVersion = 0,
    required this.name,
    this.description,
    this.location,
    required this.order,
    this.imageName,
    this.latitude,
    this.longitude,
    this.isMigratory = false,
    this.color,
    this.status = ApiaryStatus.active,
    this.hiveCount = 0,
    this.activeHiveCount = 0,
  });

  /// Returns the local file path for the apiary image
  Future<String?> getLocalImagePath() async {
    if (imageName == null) return null;
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/images/apiaries/$imageName';
  }

  factory Apiary.fromMap(Map<String, dynamic> data) {
    return Apiary(
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
      description: data['description'],
      location: data['location'],
      order: data['order'],
      imageName: data['imageName'],
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isMigratory: data['isMigratory'] ?? false,
      color: data['color'] != null ? Color(data['color']) : null,
      status: ApiaryStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => ApiaryStatus.active,
      ),
      hiveCount: data['hiveCount'] ?? 0,
      activeHiveCount: data['activeHiveCount'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    ...baseSyncProps,
    name, description, location, order, imageName, latitude, longitude,
    isMigratory, color, status, hiveCount, activeHiveCount,
  ];
  
  Map<String, dynamic> toMap() {
    return {
      ...baseSyncFields,
      'name': name,
      'description': description,
      'location': location,
      'order': order,
      'imageName': imageName,
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
    String Function()? name,
    String? Function()? description,
    String? Function()? location,
    int Function()? order,
    String? Function()? imageName,
    double? Function()? latitude,
    double? Function()? longitude,
    bool Function()? isMigratory,
    Color? Function()? color,
    ApiaryStatus Function()? status,
    int Function()? hiveCount,
    int Function()? activeHiveCount,
    DateTime Function()? updatedAt,
    SyncStatus Function()? syncStatus,
    DateTime? Function()? lastSyncedAt,
    bool Function()? deleted,
    int Function()? serverVersion,
  }) {
    return Apiary(
      id: id,
      createdAt: createdAt,
      updatedAt: updatedAt != null ? updatedAt() : DateTime.now(),
      syncStatus: syncStatus != null ? syncStatus() : SyncStatus.pending,
      lastSyncedAt: lastSyncedAt != null ? lastSyncedAt() : this.lastSyncedAt,
      deleted: deleted != null ? deleted() : this.deleted,
      serverVersion: serverVersion != null ? serverVersion() : this.serverVersion,
      name: name != null ? name() : this.name,
      description: description != null ? description() : this.description,
      location: location != null ? location() : this.location,
      order: order != null ? order() : this.order,
      imageName: imageName != null ? imageName() : this.imageName,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      isMigratory: isMigratory != null ? isMigratory() : this.isMigratory,
      color: color != null ? color() : this.color,
      status: status != null ? status() : this.status,
      hiveCount: hiveCount != null ? hiveCount() : this.hiveCount,
      activeHiveCount: activeHiveCount != null ? activeHiveCount() : this.activeHiveCount,
    );
  }

  @override
  String toString() {
    return name;
  }
}