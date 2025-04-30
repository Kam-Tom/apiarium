import 'package:apiarium/shared/shared.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:apiarium/shared/domain/enums/apiary_status.dart';
import 'package:apiarium/shared/domain/models/hive.dart';

class Apiary extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? location;
  final int position;
  final DateTime createdAt;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isMigratory;
  final Color? color;
  final List<Hive>? hives;
  final ApiaryStatus status;
  final int? _hiveCount; 

  const Apiary({
    required this.id,
    required this.name,
    this.description,
    required this.location,
    required this.position,
    required this.createdAt,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isMigratory = false,
    this.color,
    this.hives,
    this.status = ApiaryStatus.active,
    int? hiveCount,
  }) : _hiveCount = hiveCount;

  // Get hive count: prefer explicit count if available, otherwise calculate from hives
  int get hiveCount => _hiveCount ?? hives?.length ?? 0;

  Apiary copyWith({
    String Function()? id,
    String Function()? name,
    String? Function()? description,
    String? Function()? location,
    int Function()? position,
    DateTime Function()? createdAt,
    String? Function()? imageUrl,
    double? Function()? latitude,
    double? Function()? longitude,
    bool Function()? isMigratory,
    Color? Function()? color,
    List<Hive>? Function()? hives,
    ApiaryStatus Function()? status,
    int? Function()? hiveCount,
  }) {
    return Apiary(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      description: description != null ? description() : this.description,
      location: location != null ? location() : this.location,
      position: position != null ? position() : this.position,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      latitude: latitude != null ? latitude() : this.latitude,
      longitude: longitude != null ? longitude() : this.longitude,
      isMigratory: isMigratory != null ? isMigratory() : this.isMigratory,
      color: color != null ? color() : this.color,
      hives: hives != null ? hives() : this.hives,
      status: status != null ? status() : this.status,
      hiveCount: hiveCount != null ? hiveCount() : this._hiveCount,
    );
  }

  @override
  List<Object?> get props => [
    id, 
    name, 
    description, 
    location, 
    position,
    createdAt,
    imageUrl, 
    latitude, 
    longitude, 
    isMigratory,
    color,
    hives,
    status,
    _hiveCount
  ];
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'location': location,
      'position': position,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isMigratory': isMigratory ? 1 : 0,
      'color': color?.toHex(),
      'status': status.name,
      'hiveCount': _hiveCount,
    };
  }
}
