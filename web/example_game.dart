import 'dart:html';
import 'package:angel_websocket/browser.dart';
import 'package:phaser/phaser.dart';
import 'package:game/common.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

class ExampleGame {
  void start() {
    new Game(
      window.innerWidth,
      window.innerHeight,
      Phaser.AUTO,
      'example-game',
      jsify({
        'preload': allowInterop(preload)
      })
    );
  }

  void preload(Game game) {

  }
}