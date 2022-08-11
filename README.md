# Features

### Toggleable - enum
##### It is the switchable enum value which has `on`, `off`.
```dart
Toggleable t1 = Toggleable.on;
Toggleable t2 = Toggleable.off;
```
- **No more verbose if else - Use when()**
```dart
Toggleable toggleable = Toggleable.on;
// ... some logics that changes the toggleable
final result = toggleable.when(
  on: () => 1,
  off: () => 2,
);
// You could check the "Usage" section to explore more awesome examples!
``` 

- **It also provides some alias getters**
```dart
final t1 = Toggleable.on;

t1.isOn; // true
t1.isEnabled; // true

t1.isOff; // false
t1.isDisabled; // false
```
- **You can initializing it from boolean**
```dart
expect(Toggleable.from(true), Toggleable.on);
expect(Toggleable.from(false), Toggleable.off);
```

### ToggleableState
##### It is wrapper for `Toggleable` which helps using it.
```dart
final state = ToggleableState(initialState: Toggleable.off);

state.toggle(); // toggles the state
state.on(); // turn on the state
state.off(); // turn off the state
```

# Usage

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
