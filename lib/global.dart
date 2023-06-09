import 'dart:math';

int generateUniqueId() {
  final random = Random();
  return random.nextInt(9999999) + DateTime.now().millisecondsSinceEpoch;
}
