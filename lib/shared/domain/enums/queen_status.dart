enum QueenStatus {
  active,       // Queen is healthy and present
  dead,         // Queen died
  replaced,     // Queen was replaced by beekeeper or naturally
  lost,         // Queen lost (escaped or not found)
  superseded,   // Queen replaced naturally by colony
  missing,      // Queen not currently found (maybe temporarily)
  quarantined,  // Queen isolated for health reasons
}