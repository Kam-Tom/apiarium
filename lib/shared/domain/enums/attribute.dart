import 'package:apiarium/shared/shared.dart';

enum Attribute {
  // Colony attributes
  colonyStrength('colony.strength', FieldType.number, false),
  colonyActivity('colony.activity', FieldType.number, false),
  colonyTemperament('colony.temperament', FieldType.number, false),
  colonyRobbingObserved('colony.robbingObserved', FieldType.boolean, false),
  
  // Queen attributes
  queenSeen('queen.seen', FieldType.boolean, false),
  queenIsMarked('queen.isMarked', FieldType.boolean, false),
  queenBehavior('queen.behavior', FieldType.number, false),
  queenCells('queen.cells', FieldType.categorical, false),
  queenSwarmingSigns('queen.swarmingSigns', FieldType.boolean, false),

  // Brood attributes
  broodEggs('brood.eggs', FieldType.boolean, false),
  broodLarvae('brood.larvae', FieldType.boolean, false),
  broodCapped('brood.capped', FieldType.boolean, false),
  broodExcessDrones('brood.excessDrones', FieldType.boolean, false),
  broodPattern('brood.pattern', FieldType.categorical, false),
  broodPopulation('brood.population', FieldType.number, false),

  // Frame attributes
  framesCoveredByBees('frames.coveredByBees', FieldType.number, false),
  framesBrood('frames.brood', FieldType.number, false),
  framesHoney('frames.honey', FieldType.number, false),
  framesPollen('frames.pollen', FieldType.number, false),
  framesEmpty('frames.empty', FieldType.number, false),
  framesTotal('frames.total', FieldType.number, false),

  // Stores attributes
  storesHoney('stores.honey', FieldType.number, false),
  storesPollen('stores.pollen', FieldType.number, false),
  storesSupplementalFeedAmount('stores.supplementalFeedAmount', FieldType.number, false),
  storesSupplementalFeedType('stores.supplementalFeedType', FieldType.categorical, false),

  // Pests and diseases
  pestsAndDiseasesDiseasesSpotted('pestsAndDiseases.diseasesSpotted', FieldType.multipleChoice, false),
  pestsAndDiseasesPestsSpotted('pestsAndDiseases.pestsSpotted', FieldType.multipleChoice, false),
  pestsAndDiseasesPredatorsSpotted('pestsAndDiseases.predatorsSpotted', FieldType.multipleChoice, false),
  pestsAndDiseasesVarroaDropObserved('pestsAndDiseases.varroaDropObserved', FieldType.number, false),

  // Hive condition
  hiveConditionEquipmentStatus('hiveCondition.equipmentStatus', FieldType.categorical, false),
  hiveConditionOdor('hiveCondition.odor', FieldType.categorical, false),
  hiveConditionBraceComb('hiveCondition.braceComb', FieldType.boolean, false),
  hiveConditionExcessivePropolis('hiveCondition.excessivePropolis', FieldType.boolean, false),
  hiveConditionDeadBeesVisible('hiveCondition.deadBeesVisible', FieldType.boolean, false),
  hiveConditionMoisture('hiveCondition.moisture', FieldType.boolean, false),
  hiveConditionMold('hiveCondition.mold', FieldType.boolean, false),

  // Frames moved
  framesMovedHoneySuperBoxNet('framesMoved.honeySuperBoxNet', FieldType.number, false),
  framesMovedHoneyNet('framesMoved.honeyNet', FieldType.number, false),
  framesMovedEmptyNet('framesMoved.emptyNet', FieldType.number, false),
  framesMovedBroodBoxNet('framesMoved.broodBoxNet', FieldType.number, false), // OK
  framesMovedBroodNet('framesMoved.broodNet', FieldType.number, false),
  framesMovedEmptyBroodNet('framesMoved.emptyBroodNet', FieldType.number, false),

  // Weight
  weightHiveWeightKg('weight.hiveWeightKg', FieldType.number, false),

  // Weather
  weatherConditions('weather.conditions', FieldType.categorical, false),
  weatherTemperature('weather.temperature', FieldType.number, false),
  weatherHumidity('weather.humidity', FieldType.number, false),
  weatherWindSpeed('weather.wind.speed', FieldType.number, false),
  weatherWindDirection('weather.wind.direction', FieldType.categorical, false),
  weatherPressure('weather.pressure', FieldType.number, false),

  // Actions
  actionsAdditional('actions.additional', FieldType.multipleChoice, false),

  // Notes
  notes('notes', FieldType.string, false),

  // None, for unrecognized attributes
  none('none', FieldType.string, true);

  final String name;
  final FieldType type;
  final bool obsolete;

  const Attribute(this.name, this.type, this.obsolete);
}