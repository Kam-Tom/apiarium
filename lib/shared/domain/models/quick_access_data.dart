import 'package:apiarium/shared/domain/enums/attribute.dart';

enum InspectionSeason { winter, spring, summer }

abstract class QuickInspection {
  List<Attribute> get quickAccessFields;
  InspectionSeason get season;
}

class WinterQuickInspection extends QuickInspection {
  @override
  InspectionSeason get season => InspectionSeason.winter;

  @override
  List<Attribute> get quickAccessFields => [
    Attribute.familyStrength,
    Attribute.foodStores,
    Attribute.queenSeen,
    Attribute.lastTimeQueenSeen,
    Attribute.deadBeesVisible,
    Attribute.notes,
  ];
}

class SpringSummerQuickInspection extends QuickInspection {
  @override
  InspectionSeason get season => InspectionSeason.spring;

  @override
  List<Attribute> get quickAccessFields => [
    Attribute.familyStrength,
    Attribute.queenSeen,
    Attribute.queenMarked,
    Attribute.lastTimeQueenSeen,
    Attribute.honeyHarvested,
    Attribute.swarmingSigns,
    Attribute.notes,
  ];
}