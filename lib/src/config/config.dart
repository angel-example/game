library game.config;

import 'dart:convert';
import 'dart:io';
import 'package:angel_common/angel_common.dart';
// import 'package:angel_multiserver/angel_multiserver.dart';
import 'plugins/plugins.dart' as plugins;

/// This is a perfect place to include configuration and load plug-ins.
configureServer(Angel app) async {
  await app.configure(loadConfigurationFile());
  await app.configure(mustache(new Directory('views')));
  app
    ..lazyParseBodies = true
    ..injectSerializer(JSON.encode);
  await plugins.configureServer(app);

  // Uncomment this to enable session synchronization across instances.
  // This will add the overhead of querying a database at the beginning
  // and end of every request. Thus, it should only be activated if necessary.
  //
  // For applications of scale, it is better to steer clear of session use
  // entirely.
  // await app.configure(new MongoSessionSynchronizer(db.collection('sessions')));
}
