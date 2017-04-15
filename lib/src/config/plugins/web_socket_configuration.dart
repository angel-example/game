library game.config.plugins.web_socket_configuration;

import 'dart:async';
import 'dart:math' as math;
import 'package:angel_common/angel_common.dart';
import 'package:angel_websocket/server.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';
import '../../../common.dart';

final Validator COORDINATE = new Validator({
  'x*': [isNum, isPositive],
  'y*': [isNum, isPositive]
});

final Validator PLAYER_STATUS =
    new Validator({'windowSize': COORDINATE, 'position': COORDINATE});

class WebSocketConfiguration extends AngelPlugin {
  @override
  Future call(Angel app) async {
    // Fire queued events every 3 seconds...
    var statusService = app.service('api/player_statuses'),
        userService = app.service('api/users');
    var ws = new _Delay(new Duration(seconds: 3));

    /// Delete users on disconnect
    ws.onDisconnection.listen((socket) {
      var req = socket.request;

      if (req.injections.containsKey(AuthToken)) {
        var token = req.grab<AuthToken>('token');
        userService.remove(token.userId);
      }
    });

    await app.configure(ws);
    await app.configure(new GameController(statusService, userService));
  }
}

@Expose('/game')
class GameController extends WebSocketController {
  final math.Random _rnd = new math.Random();
  final Service _statusService, _userService;
  final Uuid _uuid = new Uuid();

  GameController(this._statusService, this._userService);

  /// TODO: Remove this
  @override
  onAction(WebSocketAction action, WebSocketContext socket) async {
    socket.request.inject(WebSocketAction, action);
  }

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
        var position = Size2D.within(WINDOW_SIZE, _rnd);

        var user = new User(
            sprite: Sprite.ALL[_rnd.nextInt(Sprite.ALL.length)],
            token: trustedToken);
        print(user.toJson());
        Map createdUser = await _userService.create(user.toJson());

        var status = new PlayerStatus(
            userId: createdUser['id'],
            windowSize: new Coordinate.fromMap(windowSize),
            position: new Coordinate(x: position.x, y: position.y));
        Map createdStatus = await _statusService.create(status.toJson());

        await _userService.modify(createdUser['id'], {'status': createdStatus});

        await socket.send('initialized', {
          'userId': createdUser['id'],
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
    var req = socket.request;

    if (!req.properties.containsKey('user'))
      throw new AngelHttpException.forbidden();
    else {
      var user = req.user as User;
      throw new AngelHttpException.unavailable(message: 'TODO: move');
    }
  }
}

class _Delay extends AngelWebSocket {
  final List<_BatchInfo> _batched = [];
  final Duration _duration;
  Timer _timer;

  _Delay(this._duration);

  @override
  call(Angel app) async {
    await super.call(app);

    _timer = new Timer.periodic(_duration, (_) async {
      if (_batched.isEmpty)
        return;
      else {
        await Future.wait(_batched.map((b) =>
            super.batchEvent(b.event, filter: b.filter, notify: b.notify)));
      }
    });

    app.justBeforeStop.add((app) async {
      _timer.cancel();
    });
  }

  @override
  batchEvent(WebSocketEvent e,
      {filter(WebSocketContext socket), bool notify: true}) {
    _batched.add(new _BatchInfo(e, filter, notify != false));
  }
}

typedef _Filter(WebSocketContext socket);

class _BatchInfo {
  final WebSocketEvent event;
  final _Filter filter;
  final bool notify;

  _BatchInfo(this.event, this.filter, this.notify);
}
