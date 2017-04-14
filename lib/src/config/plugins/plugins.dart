library game.config.plugins;

import 'dart:async';
import 'package:angel_common/angel_common.dart';
import 'web_socket_configuration.dart';

Future configureServer(Angel app) async {
  // Include any plugins you have made here.
  app.justBeforeStart.add(new WebSocketConfiguration());
}
