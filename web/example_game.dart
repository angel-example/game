import 'dart:html' show window;
import 'package:angel_client/browser.dart' as rest;
import 'package:angel_configuration/browser.dart';
import 'package:angel_websocket/browser.dart';
import 'package:phaser/phaser.dart';
import 'package:game/src/models/models.dart';
import 'package:game/common.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';

final String BASE_URL = config('base_url'), WS_URL = config('ws_url');

class ExampleGame {
  final Map<String, Sprite> others = {};
  rest.Angel restClient;
  WebSockets client;
  Sprite player;
  String token;
  User user;
  Body get playerBody => player.body;

  ExampleGame() {
    restClient = new rest.Rest(BASE_URL);
    window.localStorage.remove('game_token');
  }

  void start() {
    new Game(
        WINDOW_SIZE.x,
        WINDOW_SIZE.y,
        Phaser.AUTO,
        'example-game',
        jsify({
          'preload': allowInterop(preload),
          'create': allowInterop(create),
          'render': allowInterop(render)
        }));
  }

  void preload(Game game) {
    game.load.crossOrigin = 'Anonymous';
    game.load.image(SpriteName.BACKGROUND,
        '$BASE_URL/assets/background/full-background.png');

    for (var character in SpriteName.CHARACTERS) {
      game.load.spritesheet(
          character,
          '$BASE_URL/assets/characters/$character.png',
          SPRITE_SIZE.x,
          SPRITE_SIZE.y);
    }
  }

  create(Game game) async {
    game.physics.startSystem(Physics.ARCADE);

    /*Sprite background = game.add.sprite(0, 0, SpriteName.BACKGROUND);
    game.physics.enable(background);
    var bgBody = background.body as Body;
    background.scale
      ..x = game.world.width * 2 / bgBody.width
      ..y = game.world.height / bgBody.height;*/

    if (client == null && !window.localStorage.containsKey('game_token')) {
      client = new WebSockets(WS_URL);
      Timer timer;

      client.on['initialized'].first.then((e) async {
        var data = e.data as Map;
        var pos = new Size2D.fromMap(data['status']['position']);
        player = game.add.sprite(pos.x, pos.y, data['sprite']);
        player.anchor.setTo(0.5);
        game.physics.enable(player);
        timer.stop();
        window.alert(
            'Spawned ${data["sprite"]} at (${pos.x}, ${pos.y}) after ${timer
                .ms}ms!');

        token = window.localStorage['game_token'] = data['token'];
        var auth = await restClient
            .authenticate(type: 'trusted_token', credentials: {'token': token});
        print(auth.toJson());

        client.service('api/users').index();
      });

      client.service('api/users')
        ..onIndexed.listen((e) {
          for (var user in e.data) handleUser(UserMapper.parse(user), game);
        })
        ..onCreated.listen((e) {
          var user = UserMapper.parse(e.data);
          handleUser(user, game);
        });

      await client.connect();
      timer = new Timer(game)..start();

      client.send(
          'initialize',
          new WebSocketAction(data: {
            'window_size': {'x': window.innerWidth, 'y': window.innerHeight}
          }));
    }
  }

  void handleUser(User user, Game game) {
    if (user.token == token) {
      this.user = user;
    } else if (!others.containsKey(user.id)) {
      var pos = new Size2D(user.status.position.x, user.status.position.y);
      others[user.id] = game.add.sprite(pos.x, pos.y, user.sprite);
    }
  }

  render(Game game) {
    if (player != null) game.debug.spriteInfo(player, 20, 20);
  }
}
