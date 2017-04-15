import 'dart:math' show Random;

abstract class Sprite {
  static const String ARABIAN_BOY = 'arabian_boy';
  static const String DEVIL = 'devil';
  static const String PRINCE = 'prince';
  static const String SCHOOLBOY = 'schoolboy';
  static const List<String> ALL = const [ARABIAN_BOY, DEVIL, PRINCE, SCHOOLBOY];
}

const Size2D WINDOW_SIZE = const Size2D._(800, 600);
const Size2D SPRITE_SIZE = const Size2D._(32, 48);

class Size2D {
  final int x, y;

  const Size2D._(this.x, this.y);

  static Size2D within(Size2D size, Random rnd) {
    return new Size2D._(rnd.nextInt(size.x + 1), rnd.nextInt(size.y + 1));
  }
}
