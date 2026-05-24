import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { online, offline }

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  late StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityNotifier() : super(ConnectivityStatus.online) {
    _init();
  }

  Future<void> _init() async {
    final results = await Connectivity().checkConnectivity();
    _updateStatus(results);

    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _updateStatus(results);
    });
  }

  void _updateStatus(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
    } else {
      state = ConnectivityStatus.online;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final connectivityProvider = StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
  return ConnectivityNotifier();
});

