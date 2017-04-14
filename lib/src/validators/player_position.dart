library game.models.player_position;
import 'package:angel_validate/angel_validate.dart';

final Validator PLAYER_POSITION = new Validator({
  'name': [isString, isNotEmpty],
  'desc': [isString, isNotEmpty]
});

final Validator CREATE_PLAYER_POSITION = PLAYER_POSITION.extend({})
  ..requiredFields.addAll(['name', 'desc']);