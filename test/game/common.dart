library game.test.game.common;

import 'package:angel_validate/angel_validate.dart';
import 'package:game/common.dart';

final List<Matcher> VALID_STRING = [isString, isNotEmpty];

final Validator COORDINATE = new Validator({
  'x*': [isInt, greaterThanOrEqualTo(0)],
  'y*': [isInt, greaterThanOrEqualTo(0)]
});

final Validator PLAYER_POSITION = COORDINATE.extend({
  'x': [lessThanOrEqualTo(WINDOW_SIZE.x)],
  'y': [lessThanOrEqualTo(WINDOW_SIZE.y)]
});

final Validator PLAYER_STATUS = new Validator({
  'id*': VALID_STRING,
  'userId*': VALID_STRING,
  'windowSize': COORDINATE,
  'position': PLAYER_POSITION,
  'createdAt*': VALID_STRING,
  'updatedAt*': VALID_STRING
});

final Validator VALID_INITIALIZED_RESPONSE = new Validator({
  'userId*': VALID_STRING,
  'token*': VALID_STRING,
  'status*': PLAYER_STATUS
});
