import 'package:angel_framework/angel_framework.dart';
import 'package:angel_framework/hooks.dart' as hooks;

configureServer(Angel app) async {
  app.use('api/collisions', new AnonymousService(create: (data, [params]) async => data));
  var service = app.service('api/collisions') as HookedService;
  service.beforeAll(hooks.disable());
}