library game.services;

import 'package:angel_common/angel_common.dart';
import 'collision.dart' as collision;
import 'player_status.dart' as player_status;
import 'user.dart' as user;

configureServer(Angel app) async {
  await app.configure(collision.configureServer);
  await app.configure(player_status.configureServer);
  await app.configure(user.configureServer);
}
