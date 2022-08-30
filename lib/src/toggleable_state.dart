import 'dart:async';

import 'package:easy_debounce/easy_debounce.dart';
import 'package:toggleable/src/typedef.dart';
import 'package:toggleable/src/util.dart';
import 'package:toggleable/toggleable.dart';

class ToggleableState {
  Toggleable _state;

  final _onUpdateListeners = <MaybeAsyncCallback>{};

  String? _idForDebounce;

  final _turnOnListeners = <MaybeAsyncCallback>{};
  final _turnOffListeners = <MaybeAsyncCallback>{};

  final Duration _listenersDelay;

  Completer<void>? _delayedListenerCompleter;

  Toggleable get state => _state;

  /// shortcut for the state is on
  bool get isOn => _state.isOn;

  /// shortcut for the state is off
  bool get isOff => _state.isOff;

  /// shortcut for the state is enabled
  bool get isEnabled => _state.isEnabled;

  /// shortcut for the state is disabled
  bool get isDisabled => _state.isDisabled;

  Completer<void>? get delayedListenerCompleter => _delayedListenerCompleter;
  bool get willCallback => _delayedListenerCompleter != null;

  /// [initialState] sets the initial state.
  ///
  /// You can register the multiple callback method to [_onUpdateListeners] through [addOnUpdatedCallback].
  /// This is executed immediately after the [state] changed.
  ///
  /// When you pass [listenersDelay] as [Duration.zero], the listeners are called immediately after onUpdate called
  ///
  /// If you pass the non-zero delay, the listeners added by [addDebouncedListener] are called after [listenersDelay]
  /// If the state is changed through [on], [off] or [toggle] before the listeners are called, the previous callback is canceled(debounced)
  ///
  /// For example, let the delay is 500ms, the listeners are not called before 500ms is passed between the state changes.
  /// [on] - 300ms passed - [off] - 400ms passed - [on] - 300ms passed - [off] - 500ms passed - [listeners are called]
  ///
  /// Use-case
  /// Generally, [ToggleableState] could be used in the switch button in flutter.
  ///
  /// Let the switch button has two functionality.
  ///
  /// 1. Toggles the state of itself
  /// 2. Calls API that follow or un-follows the other user
  /// If you call API on every button tap, the server could dive to the harmful state like at least increase load or at most deadlocks.
  /// In this case, you can use [ToggleableState] with [listenersDelay].
  ///
  /// When you call [toggle], the [_onUpdateListeners] are called immediately in sequence of registered
  /// [_onUpdateListeners] are usually the method that updates the UI like [setState].
  /// And after the [listenersDelay] passed, [_turnOnListeners] & [_turnOffListeners] executed that usually calls the API.
  ToggleableState({
    Toggleable initialState = Toggleable.off,
    Duration listenersDelay = Duration.zero,
  })  : _state = initialState,
        _listenersDelay = listenersDelay;

  /// Registers the [callback] from [_onUpdateListeners]
  /// [callback] is called immediately after the state updated.
  void addOnUpdatedCallback(MaybeAsyncCallback callback) => _onUpdateListeners.add(callback);

  /// Removes [callback] from [onUpdateCallback]
  void removeOnUpdatedCallback(MaybeAsyncCallback callback) => _onUpdateListeners.remove(callback);

  /// add listeners that called after state changed
  /// [turnOnCallback] is called after [on] is called.
  /// [turnOffCallback] is called after [off] is called.
  /// When you call [toggle], it calls the appropriate callback respect to changing state.
  void addDebouncedListener({
    MaybeAsyncCallback? turnOnCallback,
    MaybeAsyncCallback? turnOffCallback,
  }) {
    if (turnOnCallback != null) _turnOnListeners.add(turnOnCallback);
    if (turnOffCallback != null) _turnOffListeners.add(turnOffCallback);
  }

  /// Shortcut for adding identical on & off callbacks to addDebouncedListeners
  void addBothDebouncedListeners(MaybeAsyncCallback callback) {
    _turnOnListeners.add(callback);
    _turnOffListeners.add(callback);
  }

  /// Shortcut for removing identical on & off callbacks to removeDebouncedListeners
  void removeBothDebouncedListeners(MaybeAsyncCallback callback) {
    _turnOnListeners.remove(callback);
    _turnOffListeners.remove(callback);
  }

  /// remove listeners
  void removeDebouncedListener({
    MaybeAsyncCallback? turnOnCallback,
    MaybeAsyncCallback? turnOffCallback,
  }) {
    if (turnOnCallback != null) _turnOnListeners.remove(turnOnCallback);
    if (turnOffCallback != null) _turnOffListeners.remove(turnOffCallback);
  }

  /// Toggles the current state.
  ///
  /// [withoutNotify] decides whether to call listeners.
  /// [forceCallback] forces calling the callbacks that previously registered even if the state is not changed.
  Future<void> toggle({bool withoutNotify = false, bool forceCallback = false}) async {
    return _state.toggled().when(
          on: () => on(withoutNotify: withoutNotify, forceCallback: forceCallback),
          off: () => off(withoutNotify: withoutNotify, forceCallback: forceCallback),
        );
  }

  /// Changes the current state as [Toggleable.on]
  ///
  /// [withoutNotify] decides whether to call listeners.
  /// [forceCallback] forces calling the callbacks that previously registered even if the state is not changed.
  Future<void> on({bool withoutNotify = false, bool forceCallback = false}) async {
    if (_state == Toggleable.on && !forceCallback) return;
    _state = Toggleable.on;
    if (withoutNotify) return;

    for (final callback in _onUpdateListeners) {
      await callback();
    }

    final completer = _delayedListenerCompleter ??= Completer();
    EasyDebounce.debounce(
      _idForDebounce ??= getRandomString(),
      _listenersDelay,
      () async {
        for (var idx = 0; idx < _turnOnListeners.length; idx++) {
          await _turnOnListeners.elementAt(idx)();
        }
        _completeCompleter();
      },
    );

    return completer.future;
  }

  /// Changes the current state as [Toggleable.off]
  ///
  /// [withoutNotify] decides whether to call listeners.
  /// [forceCallback] forces calling the callbacks that previously registered even if the state is not changed.
  Future<void> off({bool withoutNotify = false, bool forceCallback = false}) async {
    if (_state == Toggleable.off && !forceCallback) return;
    _state = Toggleable.off;
    if (withoutNotify) return;

    for (final callback in _onUpdateListeners) {
      await callback();
    }

    final completer = _delayedListenerCompleter ??= Completer();
    EasyDebounce.debounce(
      _idForDebounce ??= getRandomString(),
      _listenersDelay,
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

  /// Branches the method call whether to the current state.
  ///
  /// This is similar to if-else statement but more intuitive.
  ///
  /// Example,
  /// ```dart
  /// final toggleableState = ToggleableState();
  /// toggleableState.when(
  ///   on: () async {
  ///     /// logics
  ///   },
  ///   off: () async {
  ///     /// logics
  ///   },
  /// );
  /// ```
  T when<T>({
    required T Function() on,
    required T Function() off,
  }) =>
      _state.when(on: on, off: off);
}
