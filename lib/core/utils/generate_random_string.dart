import 'dart:math';

class GenerateRandomStringUtil {
  static const String _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  static final Random _rnd = Random();

  String call(int length) =>
      String.fromCharCodes(Iterable.generate(length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}
