import 'package:angel_common/angel_common.dart';
import 'package:angel_test/angel_test.dart';
import 'package:angel_websocket/angel_websocket.dart';
import 'package:game/game.dart';
import 'package:test/test.dart';
import 'common.dart';

main() {
  Angel app;
  TestClient client;

  setUp(() async {
    app = await createServer();
    client = await connectTo(app);
  });

  tearDown(() async {
    await client.close();
    app = null;
  });

  test('initialize', () async {
    var ws = await client.websocket();

    ws.send('initialize', new WebSocketAction(data: {
      'window_size': {
        'x': 600,
        'y': 400
      }
    }));

    var ev = await ws.on['initialized'].first;
    print(ev.data);
    expect(ev.data, VALID_INITIALIZED_RESPONSE);
  });

  group('errors on invalid data', () {
  });
}
