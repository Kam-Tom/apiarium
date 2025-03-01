import 'dart:async';
import 'package:flutter/foundation.dart';

/// Converts Streams to a Listenable implementation
/// 
/// Useful when you need a Listenable interface instead of Streams, such as
/// in router implementations like go_router's RefreshListenable or other
/// scenarios where the Listenable pattern is required.
class StreamToListenable extends ChangeNotifier {
  late final List<StreamSubscription> subscriptions;

  StreamToListenable(List<Stream> streams) {
    subscriptions = [];
    for (var e in streams) {
      var s = e.asBroadcastStream().listen(_handleChange);
      subscriptions.add(s);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    for (var e in subscriptions) {
      e.cancel();
    }
    super.dispose();
  }

  void _handleChange(dynamic _) => notifyListeners();
}
