import 'dart:math' show Random;

abstract class SpriteName {
  static const String ARABIAN_BOY = 'arabian_boy';
  static const String BACKGROUND = 'background';
  static const String DEVIL = 'devil';
  static const String PRINCE = 'prince';
  static const String SCHOOLBOY = 'schoolboy';
  static const List<String> CHARACTERS = const [
    ARABIAN_BOY,
    DEVIL,
    PRINCE,
    SCHOOLBOY
  ];
}

const Size2D WINDOW_SIZE = const Size2D(800, 600);
const Size2D SPRITE_SIZE = const Size2D(32, 48);

class Size2D {
  final int x, y;

  const Size2D(this.x, this.y);
  factory Size2D.fromMap(Map map) => new Size2D(map['x'], map['y']);

  static Size2D within(Size2D size, Random rnd) {
    return new Size2D(rnd.nextInt(size.x + 1), rnd.nextInt(size.y + 1));
  }
}
