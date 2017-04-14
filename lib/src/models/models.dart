library game.models;

import 'package:angel_framework/common.dart';
import 'package:owl/annotation/json.dart';
import 'models.g.dart';
export 'models.g.dart';

@JsonClass()
class User extends Model {
  @override
  String id;
  String sprite, token;
  PlayerStatus status;
  @override
  DateTime createdAt, updatedAt;

  User(
      {this.id,
      this.sprite,
      this.token,
      this.status,
      this.createdAt,
      this.updatedAt});
  Map<String, dynamic> toJson() => UserMapper.map(this);
}

@JsonClass()
class PlayerStatus extends Model {
  @override
  String id;
  String userId;
  Coordinate windowSize, position;

  @override
  DateTime createdAt, updatedAt;

  PlayerStatus(
      {this.id,
      this.userId,
      this.windowSize,
      this.position,
      this.createdAt,
      this.updatedAt});
}

@JsonClass()
class Coordinate {
  num x, y;
  Coordinate({this.x, this.y});
}
