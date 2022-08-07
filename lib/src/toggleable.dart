enum Toggleable {
  on,
  off,
  ;

  Toggleable toggled() {
    switch (this) {
      case Toggleable.on:
        return Toggleable.off;
      case Toggleable.off:
        return Toggleable.on;
    }
  }

  bool get isOn => this == Toggleable.on;
  bool get isOff => this == Toggleable.off;

  bool get isEnabled => isOn;
  bool get isDisabled => isOff;

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
