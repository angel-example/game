import 'package:angel_validate/angel_validate.dart';

final Validator USER = new Validator({
  'sprite': [isString, isNotEmpty],
  'token': [isString, isNotEmpty],
  'status': [isMap]
});

final Validator CREATE_USER = USER.extend({})
  ..requiredFields.addAll(['sprite', 'token']);
