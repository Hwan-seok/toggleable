## Features

## Getting started


## Usage

```dart
final mySwitch = ToggleableState();

mySwitch.on();
mySwitch.isOn; // true
mySwitch.isEnabled; // true

mySwitch.off();
mySwitch.isOff; // true
mySwitch.isDisabled; // true

mySwitch.toggle();

int someOtherState = 1;

mySwitch.addListener(turnOnCallback: () => someOtherState++);
```

## Additional information

- Please improve this package by contributing!
