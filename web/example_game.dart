import 'dart:async' as async_;
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
  CursorKeys keys;
  Group otherPlayers;
  Sprite player;
  int speed = 30;
  String token;
  User user;
  Body get playerBody => player.body;

  ExampleGame() {
    restClient = new rest.Rest(BASE_URL);
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
          'update': allowInterop(update),
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

  create(Game game) {
    game.physics.startSystem(Physics.ARCADE);
    otherPlayers = game.add.physicsGroup();
    keys = game.input.keyboard.createCursorKeys();
    setUpWebSockets(game);
  }

  update(Game game) {
    if (player != null) {
      game.physics.arcade.overlap(otherPlayers, player,
          allowInterop((_, Sprite otherPlayer) {
        for (var userId in others.keys) {
          if (others[userId] == otherPlayer) {
            // Send a collision action
            client.send(
                'collide', new WebSocketAction(data: {'userId': userId}));
            break;
          }
        }
      }));

      // Move logic
      if (keys.up.isDown) {
        player.animations.play('up');
        playerBody.velocity.y = speed * -1;
      } else if (keys.down.isDown) {
        player.animations.play('down');
        playerBody.velocity.y = speed;
      } else {
        playerBody.velocity.y = 0;
      }

      if (keys.left.isDown) {
        player.animations.play('left');
        playerBody.velocity.x = speed * -1;
      } else if (keys.right.isDown) {
        player.animations.play('right');
        playerBody.velocity.x = speed;
      } else {
        playerBody.velocity.x = 0;
      }
    }
  }

  setUpAnimations(Sprite sprite, Game game) {
    game.physics.enable(sprite);
    (sprite.body as Body).collideWorldBounds = true;
    sprite.animations
      ..add('up', ArrayUtils.numberArray(12, 15), 5)
      ..add('down', ArrayUtils.numberArray(0, 3), 5)
      ..add('left', ArrayUtils.numberArray(4, 7), 5)
      ..add('right', ArrayUtils.numberArray(8, 11), 5);
  }

  setUpWebSockets(Game game) async {
    client = new WebSockets(WS_URL);
    Timer timer;

    client.on['initialized'].first.then((e) async {
      var data = e.data as Map;
      user = UserMapper.parse(e.data['user']);
      others[user.id]?.kill(); // Remove existing sprite, if any
      var pos = new Size2D.fromMap(data['status']['position']);
      player = game.add.sprite(pos.x, pos.y, data['sprite']);
      setUpAnimations(player, game);
      player.anchor.setTo(0.5);
      game.physics.enable(player);
      timer.stop();
      window.console
          .info('Spawned ${data["sprite"]} at (${pos.x}, ${pos.y}) after ${timer
                .ms}ms!');

      token = data['token'];

      var auth = await restClient
          .authenticate(type: 'trusted_token', credentials: {'token': token});
      await client.authenticateViaJwt(auth.token);

      // Load everybody else...
      client.service('api/users').index();

      // Regularly send updates
      new async_.Timer.periodic(new Duration(seconds: 1), (_) async {
        client.send(
            'move',
            new WebSocketAction(data: {
              'position': {'x': player.x, 'y': player.y},
              'window_size': {'x': window.innerWidth, 'y': window.innerHeight}
            }));
      });
    });

    client.service('api/collisions').onCreated.listen((e) {
      var collision = CollisionMapper.parse(e.data);

      for (var id in [collision.player1, collision.player2]) {
        if (others.containsKey(id))
          others[id].kill();
        else if (id == this.user?.id) {
          player.kill();
          window.alert('Oh no! You died!');
        }
      }
    });

    client.service('api/users')
      ..onIndexed.listen((e) {
        if (e.data is Iterable)
          for (var user in e.data) handleUser(UserMapper.parse(user), game);
      })
      ..onCreated.listen((e) {
        var user = UserMapper.parse(e.data);
        handleUser(user, game);
      })
      ..onRemoved.listen((e) {
        // Remove users who disconnect
        others[e.data['id']]?.kill();
      });

    client.service('api/player_statuses').onModified.listen((e) {
      var status = PlayerStatusMapper.parse(e.data);
      var sprite = others[status.userId];

      if (sprite != null) {
        // TODO: Smooth motion
        sprite.position.setTo(status.position.x, status.position.y);
      }
    });

    client.onError.listen((e) {
      window.console..error('Error: ${e.message}')..error(e.errors);
    });

    await client.connect();
    timer = new Timer(game)..start();

    client.send(
        'initialize',
        new WebSocketAction(data: {
          'window_size': {'x': window.innerWidth, 'y': window.innerHeight}
        }));
  }

  void handleUser(User u, Game game) {
    if (!others.containsKey(u.id) && u.id != user?.id && u?.status != null) {
      var pos = new Size2D(u.status.position.x, u.status.position.y);
      var sprite = others[u.id] = game.add.sprite(pos.x, pos.y, u.sprite)
        ..anchor.setTo(0.5);
      otherPlayers.add(sprite);
      setUpAnimations(sprite, game);
    }
  }

  render(Game game) {
    if (player != null) game.debug.spriteInfo(player, 20, 20);
  }
}
