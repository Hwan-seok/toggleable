import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:toggleable/toggleable.dart';

void main() {
  group('Toggleable', () {
    test('.from() initializes from bool value', () {
      expect(Toggleable.from(true), Toggleable.on);
      expect(Toggleable.from(false), Toggleable.off);
    });

    test('.toggled() should return toggled value', () {
      Toggleable toggleable1 = Toggleable.off;
      expect(toggleable1.toggled(), Toggleable.on);

      Toggleable toggleable2 = Toggleable.on;
      expect(toggleable2.toggled(), Toggleable.off);
    });

    test('.toggled() does not changes the original value', () {
      Toggleable toggleable = Toggleable.off;

      toggleable.toggled();

      expect(toggleable, Toggleable.off);
    });

    test('.isOn and .isEnabled returns whether the value is on', () {
      Toggleable toggleable = Toggleable.on;

      expect(toggleable.isOn, isTrue);
      expect(toggleable.isEnabled, isTrue);
      expect(toggleable.toggled().isOn, isFalse);
    });

    test('.isOff and .isDisabled returns whether the value is off', () {
      Toggleable toggleable = Toggleable.off;

      expect(toggleable.isOff, isTrue);
      expect(toggleable.isDisabled, isTrue);
      expect(toggleable.toggled().isOff, isFalse);
    });

    test('.when() executes the function by current state - (off should be called)', () {
      Toggleable toggleableOff = Toggleable.off;

      bool didOnFunctionCalled = false;
      bool didOffFunctionCalled = false;

      toggleableOff.when(
        on: () => didOnFunctionCalled = true,
        off: () => didOffFunctionCalled = true,
      );

      expect(didOnFunctionCalled, isFalse);
      expect(didOffFunctionCalled, isTrue);
    });

    test('.when() executes the function by current state - (on should be called)', () {
      Toggleable toggleableOff = Toggleable.on;

      bool didOnFunctionCalled = false;
      bool didOffFunctionCalled = false;

      toggleableOff.when(
        on: () => didOnFunctionCalled = true,
        off: () => didOffFunctionCalled = true,
      );

      expect(didOnFunctionCalled, isTrue);
      expect(didOffFunctionCalled, isFalse);
    });
  });
}
