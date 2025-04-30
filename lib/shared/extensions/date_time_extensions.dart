
/// Extension on DateTime to add beekeeping-specific season detection
extension BeekeepingDateTime on DateTime {
  /// Determines if the current date is in winter season
  static bool isWinterSeason({
    DateTime? date,
    bool isNorthernHemisphere = true,
  }) {
    final dateToCheck = date ?? DateTime.now();
    final month = dateToCheck.month;
    
    if (isNorthernHemisphere) {
      // Northern Hemisphere winter: November through February
      return month >= 11 || month <= 2;
    } else {
      // Southern Hemisphere winter: May through August
      return month >= 5 && month <= 8;
    }
  }
}
