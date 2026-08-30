import 'dart:async';

/// Calls [action] after [duration] of inactivity, cancelling any pending call.
///
/// Used by the address-bar search and dictionary lookup so we don't fire a
/// query on every keystroke.
class Debouncer {
  Debouncer({this.duration = const Duration(milliseconds: 300)});

  final Duration duration;
  Timer? _timer;

  void call(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void cancel() => _timer?.cancel();

  bool get isPending => _timer?.isActive ?? false;
}
