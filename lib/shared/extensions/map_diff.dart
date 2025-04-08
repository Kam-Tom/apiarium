extension MapDiffX<K, V> on Map<K, V> {
  /// Compares this map (old data) with another map (new data)
  /// Returns a map containing only the keys with different values,
  /// showing both old and new values
  Map<K, Map<String, V?>> differenceWith(Map<K, V> newMap) {
    final Map<K, Map<String, V?>> differences = {};
    
    // Check all keys from both maps
    final allKeys = {...keys, ...newMap.keys};
    
    for (final key in allKeys) {
      final oldValue = this[key];
      final newValue = newMap[key];
      
      // If values are different
      if (oldValue != newValue) {
        differences[key] = {
          'old': oldValue,
          'new': newValue,
        };
      }
    }
    
    return differences;
  }
}