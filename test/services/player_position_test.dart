import 'dart:io';
import 'package:game/game.dart';
import 'package:angel_common/angel_common.dart';
import 'package:angel_test/angel_test.dart';
import 'package:test/test.dart';

main() async {
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

  test('index via REST', () async {
    var response = await client.get('/api/player_positions');
    expect(response, hasStatus(HttpStatus.OK));
  });

  test('Index player_positions', () async {
    var player_positions = await client.service('api/player_positions').index();
    print(player_positions);
  });
}