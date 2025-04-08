extension DateCompareX on DateTime {
  /// Compare only the date part (day, month, year) ignoring time.
  /// 
  /// Returns:
  /// - negative value if this date is before [other]
  /// - 0 if both dates are the same day
  /// - positive value if this date is after [other]
  int compareDateOnly(DateTime other) {
    final thisDateOnly = DateTime(year, month, day);
    final otherDateOnly = DateTime(other.year, other.month, other.day);
    return thisDateOnly.compareTo(otherDateOnly);
  }

  /// Returns true if this date is the same day as [other], ignoring time.
  bool isSameDay(DateTime other) {
    return year == other.year && 
           month == other.month && 
           day == other.day;
  }

  /// Returns true if this date is before [other], comparing only day, month, year.
  bool isBeforeDay(DateTime other) {
    return compareDateOnly(other) < 0;
  }

  /// Returns true if this date is after [other], comparing only day, month, year.
  bool isAfterDay(DateTime other) {
    return compareDateOnly(other) > 0;
  }

  /// Returns a new DateTime with the same year, month, and day but time set to 00:00:00
  DateTime get dateOnly => DateTime(year, month, day);

  /// Returns true if this date is before or the same day as [other], comparing only day, month, year.
  bool isBeforeOrSameDay(DateTime other) {
    return compareDateOnly(other) <= 0;
  }

  /// Returns true if this date is after or the same day as [other], comparing only day, month, year.
  bool isAfterOrSameDay(DateTime other) {
    return compareDateOnly(other) >= 0;
  }
}
