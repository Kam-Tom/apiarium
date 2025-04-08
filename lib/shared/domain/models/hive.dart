import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';
import 'package:flutter/material.dart';

class Hive extends Equatable {
  final String id;
  final String name;
  final Apiary? apiary;
  final HiveType hiveType;
  final Queen? queen;
  final HiveStatus status;
  final DateTime acquisitionDate;
  final String? imageUrl;
  final int position;
  final Color? color;
  final int? currentFrameCount;
  final int? currentBroodFrameCount;
  final int? currentBroodBoxCount;
  final int? currentHoneySuperBoxCount;

  const Hive({
    required this.id,
    required this.name,
    this.apiary,
    required this.hiveType,
    this.queen,
    required this.status,
    required this.acquisitionDate,
    this.imageUrl,
    required this.position,
    this.color,
    this.currentFrameCount,
    this.currentBroodFrameCount,
    this.currentBroodBoxCount,
    this.currentHoneySuperBoxCount,
  });

  Hive copyWith({
    String Function()? id,
    String Function()? name,
    Apiary? Function()? apiary, 
    HiveType Function()? hiveType,
    Queen? Function()? queen,
    HiveStatus Function()? status,
    DateTime Function()? acquisitionDate,
    String? Function()? imageUrl,
    int Function()? position,
    Color? Function()? color,
    int? Function()? currentFrameCount,
    int? Function()? currentBroodFrameCount,
    int? Function()? currentBroodBoxCount,
    int? Function()? currentHoneySuperBoxCount,
  }) {
    return Hive(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      apiary: apiary != null ? apiary() : this.apiary,
      hiveType: hiveType != null ? hiveType() : this.hiveType,
      queen: queen != null ? queen() : this.queen,
      status: status != null ? status() : this.status,
      acquisitionDate: acquisitionDate != null ? acquisitionDate() : this.acquisitionDate,
      imageUrl: imageUrl != null ? imageUrl() : this.imageUrl,
      position: position != null ? position() : this.position,
      color: color != null ? color() : this.color,
      currentFrameCount: currentFrameCount != null ? currentFrameCount() : this.currentFrameCount,
      currentBroodFrameCount: currentBroodFrameCount != null ? currentBroodFrameCount() : this.currentBroodFrameCount,
      currentBroodBoxCount: currentBroodBoxCount != null ? currentBroodBoxCount() : this.currentBroodBoxCount,
      currentHoneySuperBoxCount: currentHoneySuperBoxCount != null ? currentHoneySuperBoxCount() : this.currentHoneySuperBoxCount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    apiary,
    hiveType,
    queen,
    status,
    acquisitionDate,
    imageUrl,
    position,
    color,
    currentFrameCount,
    currentBroodFrameCount,
    currentBroodBoxCount,
    currentHoneySuperBoxCount,
  ];
}
