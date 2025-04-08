extension EnumByNameX<T extends Enum> on List<T> {
  /// Parse a string value to an enum instance
  /// Returns the default value if the string is null or not found
  T byNameOrDefault(String? value, {required T defaultValue}) {
    if (value == null) return defaultValue;
    return firstWhere(
      (e) => e.name == value,
      orElse: () => defaultValue,
    );
  }
  
  /// Parse a string value to an optional enum instance
  /// Returns null if the string is null
  T? byNameOrNull(String? value) {
    if (value == null) return null;
    try {
      return firstWhere((e) => e.name == value);
    } catch (_) {
      return null;
    }
  }
}