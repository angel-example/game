library game.config.plugins.web_socket_configuration;

import 'dart:async';
import 'package:angel_auth/angel_auth.dart';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_websocket/server.dart';
import 'package:uuid/uuid.dart';
import '../../models/models.dart';

class WebSocketConfiguration extends AngelPlugin {
  @override
  Future call(Angel app) async {
    // Fire queued events every 3 seconds...
    var userService = app.service('api/users');
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
    await app.configure(new GameController(userService));
  }
}

@Expose('/game')
class GameController extends WebSocketController {
  final Service _userService;
  final Uuid _uuid = new Uuid();

  GameController(this._userService);

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
      var status = new PlayerStatus();
      throw new AngelHttpException.unavailable(
          message: 'TODO: initialize - make status, validate');
      var player = new User(
          sprite: 'arabian_boy',
          token: trustedToken,
          status: status); // TODO: Random sprite name
      await _userService.create(player.toJson());
      socket.send('initialized',
          {'status': PlayerStatusMapper.toJson(status), 'token': trustedToken});
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
