enum Toggleable {
  on,
  off,
  ;

  const Toggleable();

  /// Factory method that creates [Toggleable] from the boolean.
  /// [Toggleable.from(true)] returns [Toggleable.on]
  factory Toggleable.from(bool value) {
    if (value) {
      return Toggleable.on;
    } else {
      return Toggleable.off;
    }
  }

  /// create and returns toggled value.
  Toggleable toggled() {
    switch (this) {
      case Toggleable.on:
        return Toggleable.off;
      case Toggleable.off:
        return Toggleable.on;
    }
  }

  /// Whether the value is [Toggleable.on]
  bool get isOn => this == Toggleable.on;

  /// Whether the value is [Toggleable.off]
  bool get isOff => this == Toggleable.off;

  /// Shortcut for [isOn]
  bool get isEnabled => isOn;

  /// Shortcut for [isOff]
  bool get isDisabled => isOff;

  /// Branches the method call whether to the value.
  ///
  /// This is similar to if-else statement but more intuitive.
  ///
  /// Example,
  /// ```dart
  /// Toggleable toggleable = Toggleable.on;
  /// toggleable.when(
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
  }) {
    switch (this) {
      case Toggleable.on:
        return on();
      case Toggleable.off:
        return off();
    }
  }
}
