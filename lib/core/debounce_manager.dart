import 'dart:async';

/// A manager that handles in-memory debouncing of asynchronous tasks.
class DebounceManager {
  DebounceManager._internal();

  /// Singleton instance of [DebounceManager].
  static final DebounceManager instance = DebounceManager._internal();

  final Map<String, Timer> _timers = <String, Timer>{};

  /// Runs the [action] after the specified [duration] has elapsed.
  /// If another call is made with the same [id] before the [duration]
  /// completes, the timer is reset.
  void run(String id, Duration duration, FutureOr<void> Function() action) {
    _timers[id]?.cancel();
    _timers[id] = Timer(duration, () async {
      _timers.remove(id);
      await action();
    });
  }

  /// Cancels the active timer associated with [id], if any.
  void cancel(String id) {
    _timers[id]?.cancel();
    _timers.remove(id);
  }

  /// Clears all active timers in the manager.
  void clear() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}
