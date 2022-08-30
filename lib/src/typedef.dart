import 'dart:async';

import 'package:toggleable/toggleable.dart';

typedef MaybeAsyncCallback = FutureOr<void> Function();
typedef StateCallback = FutureOr<void> Function(Toggleable);
typedef VoidCallback = void Function();
