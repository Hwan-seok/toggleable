import 'dart:async';

import 'package:test/test.dart';
import 'package:toggleable/toggleable.dart';

void main() {
  group("ToggleableState", () {
    test("Default initial state is off", () {
      final toggleableState = ToggleableState();

      expect(toggleableState.state, Toggleable.off);
    });

    test('.toggle() makes toggled state', () {
      final toggleableState = ToggleableState(initialState: Toggleable.on);

      toggleableState.toggle();

      expect(toggleableState.state, Toggleable.off);
    });

    test('notifyUpdate should called immediately after state changed', () {
      final toggleableState = ToggleableState();
      bool isUpdated = false;
      toggleableState.addOnUpdatedCallback((_) => isUpdated = true);

      toggleableState.toggle();

      expect(isUpdated, isTrue);
    });

    test('notifyUpdate should pass the changed state', () {
      final toggleableState_1 = ToggleableState();
      Toggleable? result_1;
      toggleableState_1.addOnUpdatedCallback((changed) => result_1 = changed);
      toggleableState_1.on();
      expect(result_1, Toggleable.on);

      final toggleableState_2 = ToggleableState(initialState: Toggleable.on);
      Toggleable? result_2;
      toggleableState_2.addOnUpdatedCallback((changed) => result_2 = changed);
      toggleableState_2.off();
      expect(result_2, Toggleable.off);
    });

    test('does not callback if state not changed - on', () {
      final toggleableState = ToggleableState(initialState: Toggleable.on);
      toggleableState.addOnUpdatedCallback((changed) => fail("Should not be called"));
      toggleableState.on();
    });

    test('does not callback if state not changed - off', () {
      final toggleableState = ToggleableState(initialState: Toggleable.off);
      toggleableState.addOnUpdatedCallback((changed) => fail("Should not be called"));
      toggleableState.off();
    });

    test(
        'should callback even though the state is not changed if [forceCallback] passed as true - on',
        () {
      final toggleableState = ToggleableState(initialState: Toggleable.on);
      Toggleable? reported;
      toggleableState.addOnUpdatedCallback((changed) => reported = changed);
      toggleableState.on(forceCallback: true);
      expect(reported, Toggleable.on);
    });

    test(
        'should callback even though the state is not changed if [forceCallback] passed as true - off',
        () {
      final toggleableState = ToggleableState(initialState: Toggleable.off);
      Toggleable? reported;
      toggleableState.addOnUpdatedCallback((changed) => reported = changed);
      toggleableState.off(forceCallback: true);
      expect(reported, Toggleable.off);
    });
  });

  group('ToggleableState listeners', () {
    test('should be called sequentially', () {
      final toggleableState = ToggleableState();
      final streamController = StreamController<int>();

      toggleableState.addDebouncedListener(turnOnCallback: () => streamController.add(1));
      toggleableState.addDebouncedListener(turnOnCallback: () => streamController.add(2));
      toggleableState.addDebouncedListener(turnOnCallback: () => streamController.add(3));
      toggleableState.addDebouncedListener(turnOnCallback: () => streamController.add(4));

      toggleableState.on();

      expect(streamController.stream, emitsInOrder([1, 2, 3, 4]));
    });

    test('should be called sequentially with async callback too', () {
      final toggleableState = ToggleableState();

      final streamController = StreamController<int>();

      toggleableState.addDebouncedListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 400)).then(
          (value) => streamController.add(1),
        ),
      );
      toggleableState.addDebouncedListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 300)).then(
          (value) => streamController.add(2),
        ),
      );
      toggleableState.addDebouncedListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 200)).then(
          (value) => streamController.add(3),
        ),
      );
      toggleableState.addDebouncedListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 100)).then(
          (value) => streamController.add(4),
        ),
      );

      toggleableState.on();

      expect(streamController.stream, emitsInOrder([1, 2, 3, 4]));
    });

    test('callback should executed only once if listenerDelay is provided', () {
      final toggleableState = ToggleableState(listenersDelay: Duration(seconds: 1));
      final streamController = StreamController<int>();

      toggleableState.addDebouncedListener(
        turnOnCallback: () => streamController.add(1),
        turnOffCallback: () => streamController.add(1),
      );

      toggleableState.toggle();
      toggleableState.toggle();
      toggleableState.toggle();
      toggleableState.toggle();
      toggleableState.toggle();

      expect(streamController.stream, emitsInOrder([1]));
    });

    test('completer completes if listenerDelay is provided', () async {
      final toggleableState = ToggleableState(listenersDelay: Duration(seconds: 1));
      final streamController = StreamController<int>();
      bool isCompleted = false;
      toggleableState.addDebouncedListener(
        turnOnCallback: () => streamController.add(1),
        turnOffCallback: () => streamController.add(1),
      );

      expect(toggleableState.delayedListenerCompleter, isNull);

      final togglingFuture = toggleableState.toggle();
      expect(toggleableState.delayedListenerCompleter, isNotNull);

      toggleableState.delayedListenerCompleter?.future.then((_) => isCompleted = true);

      expect(isCompleted, isFalse);
      await togglingFuture;
      expect(isCompleted, isTrue);
    });

    test('completer completes if listenerDelay is provided', () async {
      final toggleableState = ToggleableState(listenersDelay: Duration(seconds: 1));
      final streamController = StreamController<int>();
      bool isCompleted = false;
      toggleableState.addDebouncedListener(
        turnOnCallback: () => streamController.add(1),
        turnOffCallback: () => streamController.add(1),
      );

      expect(toggleableState.delayedListenerCompleter, isNull);

      final togglingFuture = toggleableState.toggle();
      expect(toggleableState.delayedListenerCompleter, isNotNull);

      toggleableState.delayedListenerCompleter?.future.then((_) => isCompleted = true);

      expect(isCompleted, isFalse);
      await togglingFuture;
      expect(isCompleted, isTrue);
      expect(toggleableState.delayedListenerCompleter, isNull);
    });

    test('completer completes even if listenerDelay is not provided', () async {
      final toggleableState = ToggleableState();
      final streamController = StreamController<int>();
      bool isCompleted = false;
      toggleableState.addDebouncedListener(
        turnOnCallback: () => streamController.add(1),
        turnOffCallback: () => streamController.add(1),
      );

      expect(toggleableState.delayedListenerCompleter, isNull);

      final togglingFuture = toggleableState.toggle();
      expect(toggleableState.delayedListenerCompleter, isNotNull);

      toggleableState.delayedListenerCompleter?.future.then((_) => isCompleted = true);

      expect(isCompleted, isFalse);
      await togglingFuture;
      expect(isCompleted, isTrue);
      expect(toggleableState.delayedListenerCompleter, isNull);
    });
  });
}
