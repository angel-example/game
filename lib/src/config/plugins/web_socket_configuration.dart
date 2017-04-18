library game.config.plugins.web_socket_configuration;

import 'dart:async';
import 'dart:math' as math;
import 'package:angel_common/angel_common.dart';
import 'package:angel_websocket/server.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../../common.dart';

final Validator COLLIDE = new Validator({
  'userId*': [isString, isNotEmpty]
});

final Validator COORDINATE = new Validator({
  'x*': [isNum, isPositive],
  'y*': [isNum, isPositive]
});

final Validator PLAYER_STATUS =
    new Validator({'windowSize': COORDINATE, 'position': COORDINATE});

Future<User> loadUserByToken(RequestContext req, Service userService) async {
  if (req.session.containsKey('trusted_token')) {
    Iterable<Map> users = (await userService.index({
      'query': {'token': req.session['trusted_token']}
    }));

    if (users.isNotEmpty) {
      return UserMapper.parse(users.first);
    }
  }

  return null;
}

class WebSocketConfiguration extends AngelPlugin {
  @override
  Future call(Angel app) async {
    // Fire queued events every 3 seconds...
    var statusService = app.service('api/player_statuses'),
        userService = app.service('api/users');
    var ws = new AngelWebSocket();

    /// Delete users on disconnect
    ws.onDisconnection.listen((socket) async {
      var req = socket.request;
      var user = await loadUserByToken(req, userService);

      if (user != null) await userService.remove(user.id);
    });

    await app.configure(ws);
    await app.configure(new GameController(
        app.service('api/collisions'), statusService, userService));
  }
}

@Expose('/game')
class GameController extends WebSocketController {
  final math.Random _rnd = new math.Random();
  final Service _collisionService, _statusService, _userService;
  final Uuid _uuid = new Uuid();

  GameController(
      this._collisionService, this._statusService, this._userService);

  @ExposeWs('initialize')
  initialize(WebSocketContext socket, WebSocketAction action) async {
    var session = socket.request.session;

    if (session.containsKey('trusted_token'))
      throw new AngelHttpException.forbidden();
    else {
      var trustedToken = session['trusted_token'] = _uuid.v4();
      var data = action.data;

      if (data is! Map || !data.containsKey('window_size'))
        throw new AngelHttpException.badRequest();

      try {
        var windowSize = COORDINATE.enforce(data['window_size']);
        Size2D position;

        while (position == null) {
          position = Size2D.within(WINDOW_SIZE, _rnd);
          Iterable<User> users =
              (await _userService.index()).map(UserMapper.parse);

          for (var user in users.where((u) => u.status != null)) {
            if ((position.x - user.status.position.x).abs() <= 32 ||
                (position.x - user.status.position.x).abs() <= 48) {
              position = null;
              break;
            }
          }
        }

        var user = new User(
            sprite: SpriteName
                .CHARACTERS[_rnd.nextInt(SpriteName.CHARACTERS.length)],
            token: trustedToken);
        Map createdUser = await _userService.create(user.toJson());
        print('Created user #${createdUser['id']}');

        var status = new PlayerStatus(
            userId: createdUser['id'],
            windowSize: new Coordinate.fromMap(windowSize),
            position: new Coordinate(x: position.x, y: position.y));
        Map createdStatus = await _statusService.create(status.toJson());

        await socket.send('initialized', {
          'userId': createdUser['id'],
          'user': createdUser,
          'sprite': user.sprite,
          'status': createdStatus,
          'token': trustedToken
        });
      } on ValidationException catch (e) {
        throw new AngelHttpException.badRequest(
            message: e.message, errors: e.errors);
      } catch (e) {
        rethrow;
      }
    }
  }

  @ExposeWs('move')
  move(WebSocketContext socket, WebSocketAction action) async {
    try {
      var req = socket.request;
      var user = await loadUserByToken(req, _userService);

      if (user == null) {
        throw new AngelHttpException.forbidden();
      } else {
        var status =
            PlayerStatusMapper.parse(PLAYER_STATUS.enforce(action.data));
        await _statusService.modify(user.status.id,
            {'position': CoordinateMapper.map(status.position)});
      }
    } on ValidationException catch (e) {
      throw new AngelHttpException.badRequest(
          message: e.message, errors: e.errors);
    } on AngelHttpException catch (e) {
      socket.sendError(e);
    }
  }

  @ExposeWs('collide')
  collide(WebSocketContext socket, WebSocketAction action) async {
    try {
      var req = socket.request;
      var user = await loadUserByToken(req, _userService);

      if (user == null) {
        throw new AngelHttpException.forbidden();
      } else {
        var data = COLLIDE.enforce(action.data);
        await _collisionService
            .create({'player1': user.id, 'player2': data['userId']});
      }
    } on ValidationException catch (e) {
      throw new AngelHttpException.badRequest(
          message: e.message, errors: e.errors);
    } catch (e) {
      rethrow;
    }
  }
}
