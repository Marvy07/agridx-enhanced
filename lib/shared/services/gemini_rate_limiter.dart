import 'dart:async';
import 'dart:collection';

class GeminiRateLimiter {
  final _queue = Queue<Completer<void>>();
  Timer? _timer;
  final Duration _interval;

  GeminiRateLimiter({Duration interval = const Duration(seconds: 4)}) : _interval = interval;

  Future<void> waitForSlot() {
    final completer = Completer<void>();
    _queue.add(completer);
    _processQueue();
    return completer.future;
  }

  void _processQueue() {
    if (_timer != null || _queue.isEmpty) return;

    final completer = _queue.removeFirst();
    completer.complete();

    _timer = Timer(_interval, () {
      _timer = null;
      _processQueue();
    });
  }
}
