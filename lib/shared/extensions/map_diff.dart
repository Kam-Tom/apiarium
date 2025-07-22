extension MapDiffX<K, V> on Map<K, V?> {
  /// Compares this map (old data) with another map (new data)
  /// Returns a MapDiffResult containing the changed and previous values
  MapDiffResult<K, V?> differenceWith(Map<K, V?> newMap) {
    final Map<K, V?> changedFields = {};
    final Map<K, V?> previousValues = {};
    
    // Skip metadata fields that shouldn't be tracked
    const skipFields = {
      'id', 'createdAt', 'updatedAt', 'syncStatus', 'lastSyncedAt', 
      'deleted', 'serverVersion'
    };
    
    // Check all keys from both maps
    final allKeys = {...keys, ...newMap.keys};
    
    for (final key in allKeys) {
      // Skip metadata fields
      if (skipFields.contains(key)) continue;
      
      final oldValue = this[key];
      final newValue = newMap[key];
      
      // If values are different
      if (oldValue != newValue) {
        changedFields[key] = newValue;
        previousValues[key] = oldValue;
      }
    }
    
    return MapDiffResult(
      changedFields: changedFields,
      previousValues: previousValues,
    );
  }
}

class MapDiffResult<K, V> {
  final Map<K, V> changedFields;
  final Map<K, V> previousValues;
  
  const MapDiffResult({
    required this.changedFields,
    required this.previousValues,
  });
  
  bool get hasChanges => changedFields.isNotEmpty;
}