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
      toggleableState.registerNotifyUpdate(() => isUpdated = true);

      toggleableState.toggle();

      expect(isUpdated, isTrue);
    });
  });

  group('ToggleableState listeners', () {
    test('should be called sequentially', () {
      final toggleableState = ToggleableState();
      final streamController = StreamController<int>();

      toggleableState.addListener(turnOnCallback: () => streamController.add(1));
      toggleableState.addListener(turnOnCallback: () => streamController.add(2));
      toggleableState.addListener(turnOnCallback: () => streamController.add(3));
      toggleableState.addListener(turnOnCallback: () => streamController.add(4));

      toggleableState.on();

      expect(streamController.stream, emitsInOrder([1, 2, 3, 4]));
    });

    test('should be called sequentially with async callback too', () {
      final toggleableState = ToggleableState();

      final streamController = StreamController<int>();

      toggleableState.addListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 400)).then(
          (value) => streamController.add(1),
        ),
      );
      toggleableState.addListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 300)).then(
          (value) => streamController.add(2),
        ),
      );
      toggleableState.addListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 200)).then(
          (value) => streamController.add(3),
        ),
      );
      toggleableState.addListener(
        turnOnCallback: () => Future.delayed(Duration(milliseconds: 100)).then(
          (value) => streamController.add(4),
        ),
      );

      toggleableState.on();

      expect(streamController.stream, emitsInOrder([1, 2, 3, 4]));
    });

    test('callback should executed only once if listenerDelay is provided', () {
      final toggleableState = ToggleableState(listenerDelay: Duration(seconds: 1));
      final streamController = StreamController<int>();

      toggleableState.addListener(
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
      final toggleableState = ToggleableState(listenerDelay: Duration(seconds: 1));
      final streamController = StreamController<int>();
      bool isCompleted = false;
      toggleableState.addListener(
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
      final toggleableState = ToggleableState(listenerDelay: Duration(seconds: 1));
      final streamController = StreamController<int>();
      bool isCompleted = false;
      toggleableState.addListener(
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
      toggleableState.addListener(
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
