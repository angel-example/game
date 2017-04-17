library game.config.plugins;

import 'dart:async';
import 'package:angel_common/angel_common.dart';
import 'production_tuning.dart';
import 'web_socket_configuration.dart';

Future configureServer(Angel app) async {
  // Include any plugins you have made here.
  app.justBeforeStart
      .addAll([new ProductionTuning(), new WebSocketConfiguration()]);
}
