library game.config.plugins.production_tuning;

import 'dart:async';
import 'package:angel_framework/angel_framework.dart';
import 'package:angel_multiserver/angel_multiserver.dart';

class ProductionTuning extends AngelPlugin {
  @override
  Future call(Angel app) async {
    if (app.isProduction) {
      app.before.add(
          cacheResponses(filters: [new RegExp(r'assets'), '/main.dart.js']));
    }
  }
}
