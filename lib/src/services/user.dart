import 'package:angel_common/angel_common.dart';
import 'package:angel_framework/hooks.dart' as hooks;
import 'package:angel_relations/angel_relations.dart' as relations;
import 'package:angel_security/hooks.dart' as auth;
import '../validators/user.dart';

configureServer(Angel app) async {
  app.use('/api/users', new MapService());

  HookedService service = app.service('api/users');

  // Prevent clients from doing anything funny to the `api/users` service.

  service
    ..before([
      HookedServiceEvent.CREATED,
      HookedServiceEvent.MODIFIED,
      HookedServiceEvent.UPDATED,
      HookedServiceEvent.REMOVED,
    ], hooks.disable())
    ..beforeAll(hooks.remove('token'))
    ..beforeCreated.listen(validateEvent(CREATE_USER))
    ..beforeCreated.listen(hooks.addCreatedAt())
    ..beforeRead.listen(auth.restrictToOwner(ownerField: 'id'))
    ..beforeModify(hooks.addUpdatedAt())
    ..afterAll(hooks.chainListeners([
      hooks.remove('token'),
      relations.hasOne('api/player_statuses', as: 'status')
    ]));
}
