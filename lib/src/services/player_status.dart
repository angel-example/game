import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;

configureServer(Angel app) async {
  app.use('/api/player_statuses', new MapService());

  var service = app.service('api/player_statuses') as HookedService;
  service.beforeAll(hooks.disable());
}
