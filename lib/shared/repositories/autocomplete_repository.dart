import 'package:hive_ce/hive.dart' as hive_ce;
import '../shared.dart';

class AutocompleteRepository {
  static const String _boxName = 'autocomplete_data';
  static const String _sourcesKey = 'sources';
  static const String _targetsKey = 'targets';
  static const String _tag = 'AutocompleteRepository';
  
  late hive_ce.Box<List<dynamic>> _box;

  Future<void> initialize() async {
    try {
      _box = await hive_ce.Hive.openBox<List<dynamic>>(_boxName);
      
      // Initialize with empty lists if they don't exist
      if (!_box.containsKey(_sourcesKey)) {
        await _box.put(_sourcesKey, <String>[]);
      }
      if (!_box.containsKey(_targetsKey)) {
        await _box.put(_targetsKey, <String>[]);
      }
      
      Logger.i('Autocomplete repository initialized', tag: _tag);
    } catch (e) {
      Logger.e('Failed to initialize autocomplete repository', tag: _tag, error: e);
      rethrow;
    }
  }

  Future<List<String>> getSources() async {
    try {
      final sources = _box.get(_sourcesKey, defaultValue: <String>[]);
      return List<String>.from(sources ?? []);
    } catch (e) {
      Logger.e('Failed to get sources', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<String>> getTargets() async {
    try {
      final targets = _box.get(_targetsKey, defaultValue: <String>[]);
      return List<String>.from(targets ?? []);
    } catch (e) {
      Logger.e('Failed to get targets', tag: _tag, error: e);
      return [];
    }
  }

  Future<void> addSource(String source) async {
    if (source.trim().isEmpty) return;
    
    try {
      final sources = await getSources();
      final trimmedSource = source.trim();
      
      // Add only if it doesn't already exist (case-insensitive)
      if (!sources.any((s) => s.toLowerCase() == trimmedSource.toLowerCase())) {
        sources.add(trimmedSource);
        sources.sort(); // Keep sorted for better UX
        await _box.put(_sourcesKey, sources);
        Logger.d('Added new source: $trimmedSource', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to add source: $source', tag: _tag, error: e);
    }
  }

  Future<void> addTarget(String target) async {
    if (target.trim().isEmpty) return;
    
    try {
      final targets = await getTargets();
      final trimmedTarget = target.trim();
      
      // Add only if it doesn't already exist (case-insensitive)
      if (!targets.any((t) => t.toLowerCase() == trimmedTarget.toLowerCase())) {
        targets.add(trimmedTarget);
        targets.sort(); // Keep sorted for better UX
        await _box.put(_targetsKey, targets);
        Logger.d('Added new target: $trimmedTarget', tag: _tag);
      }
    } catch (e) {
      Logger.e('Failed to add target: $target', tag: _tag, error: e);
    }
  }

  Future<void> removeSource(String source) async {
    try {
      final sources = await getSources();
      sources.removeWhere((s) => s.toLowerCase() == source.toLowerCase());
      await _box.put(_sourcesKey, sources);
      Logger.d('Removed source: $source', tag: _tag);
    } catch (e) {
      Logger.e('Failed to remove source: $source', tag: _tag, error: e);
    }
  }

  Future<void> removeTarget(String target) async {
    try {
      final targets = await getTargets();
      targets.removeWhere((t) => t.toLowerCase() == target.toLowerCase());
      await _box.put(_targetsKey, targets);
      Logger.d('Removed target: $target', tag: _tag);
    } catch (e) {
      Logger.e('Failed to remove target: $target', tag: _tag, error: e);
    }
  }

  Future<List<String>> searchSources(String query) async {
    try {
      final sources = await getSources();
      if (query.trim().isEmpty) return sources;
      
      final lowercaseQuery = query.toLowerCase();
      return sources.where((source) => 
        source.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      Logger.e('Failed to search sources with query: $query', tag: _tag, error: e);
      return [];
    }
  }

  Future<List<String>> searchTargets(String query) async {
    try {
      final targets = await getTargets();
      if (query.trim().isEmpty) return targets;
      
      final lowercaseQuery = query.toLowerCase();
      return targets.where((target) => 
        target.toLowerCase().contains(lowercaseQuery)
      ).toList();
    } catch (e) {
      Logger.e('Failed to search targets with query: $query', tag: _tag, error: e);
      return [];
    }
  }

  Future<void> clearSources() async {
    try {
      await _box.put(_sourcesKey, <String>[]);
      Logger.i('Cleared all sources', tag: _tag);
    } catch (e) {
      Logger.e('Failed to clear sources', tag: _tag, error: e);
    }
  }

  Future<void> clearTargets() async {
    try {
      await _box.put(_targetsKey, <String>[]);
      Logger.i('Cleared all targets', tag: _tag);
    } catch (e) {
      Logger.e('Failed to clear targets', tag: _tag, error: e);
    }
  }

  Future<void> dispose() async {
    try {
      await _box.close();
      Logger.i('Autocomplete repository disposed', tag: _tag);
    } catch (e) {
      Logger.e('Failed to dispose autocomplete repository', tag: _tag, error: e);
    }
  }
}
