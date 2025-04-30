import 'package:equatable/equatable.dart';
import 'package:apiarium/shared/shared.dart';

class HiveType extends Equatable {
  final String id;
  final String name;
  final String? manufacturer;
  final HiveMaterial mainMaterial;
  final bool hasFrames;
  
  // Frame specifications
  final int? defaultFrameCount;
  final double? frameWidth;
  final double? frameHeight;
  final double? broodFrameWidth;
  final double? broodFrameHeight;
  final String? frameStandard;
  final int? broodBoxCount;
  final int? honeySuperBoxCount;
  
  // Cost information
  final double? hiveCost;
  final Currency? currency;
  final double? frameUnitCost;
  final double? broodFrameUnitCost;
  final double? broodBoxUnitCost;
  final double? honeySuperBoxUnitCost;
  
  // Sorting and filtering fields
  final int priority;
  final String? country;
  final bool isStarred;

  const HiveType({
    required this.id,
    required this.name,
    this.manufacturer,
    required this.mainMaterial,
    required this.hasFrames,
    this.defaultFrameCount,
    this.frameWidth,
    this.frameHeight,
    this.broodFrameWidth,
    this.broodFrameHeight,
    this.frameStandard,
    this.broodBoxCount,
    this.honeySuperBoxCount,
    this.hiveCost,
    this.currency,
    this.frameUnitCost,
    this.broodFrameUnitCost,
    this.broodBoxUnitCost,
    this.honeySuperBoxUnitCost,
    this.priority = 0,
    this.country,
    this.isStarred = false,
  });

  HiveType copyWith({
    String Function()? id,
    String Function()? name,
    String? Function()? manufacturer,
    HiveMaterial Function()? mainMaterial,
    bool Function()? hasFrames,
    int? Function()? defaultFrameCount,
    double? Function()? frameWidth,
    double? Function()? frameHeight,
    double? Function()? broodFrameWidth,
    double? Function()? broodFrameHeight,
    String? Function()? frameStandard,
    int? Function()? broodBoxCount,
    int? Function()? honeySuperBoxCount,
    double? Function()? hiveCost,
    Currency? Function()? currency,
    double? Function()? frameUnitCost,
    double? Function()? broodFrameUnitCost,
    double? Function()? broodBoxUnitCost,
    double? Function()? honeySuperBoxUnitCost,
    int Function()? priority,
    String? Function()? country,
    bool Function()? isStarred,
  }) {
    return HiveType(
      id: id != null ? id() : this.id,
      name: name != null ? name() : this.name,
      manufacturer: manufacturer != null ? manufacturer() : this.manufacturer,
      mainMaterial: mainMaterial != null ? mainMaterial() : this.mainMaterial,
      hasFrames: hasFrames != null ? hasFrames() : this.hasFrames,
      defaultFrameCount: defaultFrameCount != null ? defaultFrameCount() : this.defaultFrameCount,
      frameWidth: frameWidth != null ? frameWidth() : this.frameWidth,
      frameHeight: frameHeight != null ? frameHeight() : this.frameHeight,
      broodFrameWidth: broodFrameWidth != null ? broodFrameWidth() : this.broodFrameWidth,
      broodFrameHeight: broodFrameHeight != null ? broodFrameHeight() : this.broodFrameHeight,
      frameStandard: frameStandard != null ? frameStandard() : this.frameStandard,
      broodBoxCount: broodBoxCount != null ? broodBoxCount() : this.broodBoxCount,
      honeySuperBoxCount: honeySuperBoxCount != null ? honeySuperBoxCount() : this.honeySuperBoxCount,
      hiveCost: hiveCost != null ? hiveCost() : this.hiveCost,
      currency: currency != null ? currency() : this.currency,
      frameUnitCost: frameUnitCost != null ? frameUnitCost() : this.frameUnitCost,
      broodFrameUnitCost: broodFrameUnitCost != null ? broodFrameUnitCost() : this.broodFrameUnitCost,
      broodBoxUnitCost: broodBoxUnitCost != null ? broodBoxUnitCost() : this.broodBoxUnitCost,
      honeySuperBoxUnitCost: honeySuperBoxUnitCost != null ? honeySuperBoxUnitCost() : this.honeySuperBoxUnitCost,
      priority: priority != null ? priority() : this.priority,
      country: country != null ? country() : this.country,
      isStarred: isStarred != null ? isStarred() : this.isStarred,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    manufacturer,
    mainMaterial,
    hasFrames,
    defaultFrameCount,
    frameWidth,
    frameHeight,
    broodFrameWidth,
    broodFrameHeight,
    frameStandard,
    broodBoxCount,
    honeySuperBoxCount,
    hiveCost,
    currency,
    frameUnitCost,
    broodFrameUnitCost,
    broodBoxUnitCost,
    honeySuperBoxUnitCost,
    priority,
    country,
    isStarred,
  ];
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'manufacturer': manufacturer,
      'mainMaterial': mainMaterial.name,
      'hasFrames': hasFrames ? 1 : 0,
      'defaultFrameCount': defaultFrameCount,
      'frameWidth': frameWidth,
      'frameHeight': frameHeight,
      'broodFrameWidth': broodFrameWidth,
      'broodFrameHeight': broodFrameHeight,
      'frameStandard': frameStandard,
      'broodBoxCount': broodBoxCount,
      'honeySuperBoxCount': honeySuperBoxCount,
      'hiveCost': hiveCost,
      'currency': currency?.name,
      'frameUnitCost': frameUnitCost,
      'broodFrameUnitCost': broodFrameUnitCost,
      'broodBoxUnitCost': broodBoxUnitCost,
      'honeySuperBoxUnitCost': honeySuperBoxUnitCost,
      'priority': priority,
      'country': country,
      'isStarred': isStarred ? 1 : 0,
    };
  }
}
