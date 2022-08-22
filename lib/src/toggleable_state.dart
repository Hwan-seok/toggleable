import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:toggleable/src/typedef.dart';
import 'package:toggleable/src/util.dart';
import 'package:toggleable/toggleable.dart';

class ToggleableState {
  Toggleable _state;

  MaybeAsyncCallback? _notifyUpdate;

  String? _idForDebounce;

  final _turnOnListeners = <MaybeAsyncCallback>{};
  final _turnOffListeners = <MaybeAsyncCallback>{};

  final Duration _listenerDelay;

  Completer<void>? _delayedListenerCompleter;

  Toggleable get state => _state;

  bool get isOn => _state.isOn;
  bool get isOff => _state.isOff;

  bool get isEnabled => _state.isEnabled;
  bool get isDisabled => _state.isDisabled;

  Completer<void>? get delayedListenerCompleter => _delayedListenerCompleter;
  bool get willCallback => _delayedListenerCompleter != null;

  ToggleableState({
    Toggleable initialState = Toggleable.off,
    MaybeAsyncCallback? notifyUpdate,
    Duration listenerDelay = Duration.zero,
  })  : _state = initialState,
        _notifyUpdate = notifyUpdate,
        _listenerDelay = listenerDelay;

  void registerNotifyUpdate(MaybeAsyncCallback callback) => _notifyUpdate = callback;

  void addListener({
    MaybeAsyncCallback? turnOnCallback,
    MaybeAsyncCallback? turnOffCallback,
  }) {
    if (turnOnCallback != null) _turnOnListeners.add(turnOnCallback);
    if (turnOffCallback != null) _turnOffListeners.add(turnOffCallback);
  }

  void removeListeners({
    MaybeAsyncCallback? turnOnCallback,
    MaybeAsyncCallback? turnOffCallback,
  }) {
    if (turnOnCallback != null) _turnOnListeners.remove(turnOnCallback);
    if (turnOffCallback != null) _turnOffListeners.remove(turnOffCallback);
  }

  Future<void> toggle({bool withoutNotify = false}) async {
    return _state.toggled().when(
          on: () => on(withoutNotify: withoutNotify),
          off: () => off(withoutNotify: withoutNotify),
        );
  }

  Future<void> on({bool withoutNotify = false}) async {
    _state = Toggleable.on;
    if (withoutNotify) return;

    _notifyUpdate?.call();
    final completer = _delayedListenerCompleter ??= Completer();
    EasyDebounce.debounce(
      _idForDebounce ??= getRandomString(),
      _listenerDelay,
      () async {
        for (var idx = 0; idx < _turnOnListeners.length; idx++) {
          await _turnOnListeners.elementAt(idx)();
        }
        _completeCompleter();
      },
    );

    return completer.future;
  }

  Future<void> off({bool withoutNotify = false}) async {
    _state = Toggleable.off;
    if (withoutNotify) return;

    _notifyUpdate?.call();
    final completer = _delayedListenerCompleter ??= Completer();
    EasyDebounce.debounce(
      _idForDebounce ??= getRandomString(),
      _listenerDelay,
      () async {
        for (var idx = 0; idx < _turnOffListeners.length; idx++) {
          await _turnOffListeners.elementAt(idx)();
        }
        _completeCompleter();
      },
    );
    return completer.future;
  }

  void _completeCompleter() {
    _delayedListenerCompleter?.complete();
    _delayedListenerCompleter = null;
  }

  T when<T>({
    required T Function() on,
    required T Function() off,
  }) =>
      _state.when(on: on, off: off);
}
