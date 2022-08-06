import 'dart:math';

String getRandomString({int length = 15}) {
  const availableChars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  final random = Random();

  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => availableChars.codeUnitAt(
        random.nextInt(availableChars.length),
      ),
    ),
  );
}
