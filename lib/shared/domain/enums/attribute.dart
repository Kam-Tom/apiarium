enum FieldType {
  string,
  number,
  boolean,
  categorical,
  multipleChoice,
  date,
}

enum Attribute {
  // Essential colony attributes
  familyStrength('familyStrength', FieldType.number),
  colonyTemperament('colonyTemperament', FieldType.number),
  
  // Queen attributes (most important)
  queenSeen('queenSeen', FieldType.boolean),
  queenMarked('queenMarked', FieldType.boolean),
  lastTimeQueenSeen('lastTimeQueenSeen', FieldType.date),
  queenCells('queenCells', FieldType.categorical),
  swarmingSigns('swarmingSigns', FieldType.boolean),

  // Brood (simplified)
  broodPresent('broodPresent', FieldType.boolean),
  broodPattern('broodPattern', FieldType.categorical),
  broodFrames('broodFrames', FieldType.number),

  // Food stores (essential)
  foodStores('foodStores', FieldType.number),
  honeyFrames('honeyFrames', FieldType.number),
  honeyHarvested('honeyHarvested', FieldType.number),
  feedingRequired('feedingRequired', FieldType.boolean),
  
  // Health & condition (important)
  diseasesSeen('diseasesSeen', FieldType.multipleChoice),
  pestsSeen('pestsSeen', FieldType.multipleChoice),
  varroaMites('varroaMites', FieldType.categorical),
  deadBeesVisible('deadBeesVisible', FieldType.boolean),

  // Hive condition (simplified)
  hiveCondition('hiveCondition', FieldType.categorical),
  moisture('moisture', FieldType.boolean),

  // Space management
  framesAdded('framesAdded', FieldType.number),
  framesRemoved('framesRemoved', FieldType.number),

  // Actions taken
  treatmentApplied('treatmentApplied', FieldType.multipleChoice),
  
  // Weather (useful for context)
  temperature('temperature', FieldType.number),
  weatherConditions('weatherConditions', FieldType.categorical),

  // Weight (optional but useful)
  hiveWeight('hiveWeight', FieldType.number),

  // General
  notes('notes', FieldType.string);

  final String name;
  final FieldType type;

  const Attribute(this.name, this.type);
}