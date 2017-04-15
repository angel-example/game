library game.routes.controllers.auth;

import 'dart:async';
import 'package:angel_common/angel_common.dart';
import '../../models/models.dart';

@Expose('/auth')
class AuthController extends Controller {
  AngelAuth auth;

  /// Clients will see the result of `deserializer`, so let's pretend to be a client.
  ///
  /// Our User service is already wired to remove sensitive data from serialized JSON.
  deserializer(String id) async =>
      app.service('api/users').read(id, {'provider': Providers.REST});

  serializer(User user) async => user.id;

  @override
  call(Angel app) async {
    // Wire up local authentication, connected to our User service
    auth = new AngelAuth(jwtKey: app.jwt_secret, allowCookie: false)
      ..serializer = serializer
      ..deserializer = deserializer
      ..strategies.add(new TrustedTokenAuthStrategy(app.service('api/users')));

    await super.call(app);
    await app.configure(auth);
  }

  @Expose('/trusted_token', method: 'POST')
  login() => auth.authenticate('trusted_token');
}

/// Authenticate users via secure, randomly-generated tokens,
/// rather than a mere username and password.
class TrustedTokenAuthStrategy extends AuthStrategy {
  final Service _service;

  @override
  final String name = 'trusted_token';

  TrustedTokenAuthStrategy(this._service);

  @override
  Future authenticate(RequestContext req, ResponseContext res,
      [AngelAuthOptions options]) async {
    var body = await req.lazyBody();

    if (!body.containsKey('token'))
      throw new AngelHttpException.badRequest();
    else {
      var token = body['token'].toString();
      Iterable<User> users = (await _service.index({
        'query': {'token': token}
      }))
          .map(UserMapper.parse);

      if (users.isEmpty)
        return false;
      else {
        return UserMapper.parse(users.first.toJson()..remove('token'));
      }
    }
  }

  @override
  Future<bool> canLogout(RequestContext req, ResponseContext res) async => true;
}
