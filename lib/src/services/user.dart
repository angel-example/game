import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import '../validators/user.dart';

configureServer(Angel app) async {
  app.use('/api/users', new MapService());

  HookedService service = app.service('api/users');

  // Prevent clients from doing anything to the `users` service.
  service.beforeAll(hooks.disable());

  service
    ..beforeAll(hooks.remove('token'))
    ..beforeCreated.listen(validateEvent(CREATE_USER))
    ..beforeCreated.listen(hooks.addCreatedAt())
    ..beforeModify(hooks.addUpatedAt())
    ..afterAll(hooks.remove('token'));
}
