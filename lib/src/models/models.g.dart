// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// Generator: JsonGenerator
// Target: library game.models
// **************************************************************************

// Generated by owl 0.1.2
// https://github.com/agilord/owl

// ignore: unused_import, library_prefixes
import 'models.dart';
// ignore: unused_import, library_prefixes
import 'dart:convert';
// ignore: unused_import, library_prefixes
import 'package:owl/util/json/core.dart' as _owl_json;

// **************************************************************************
// Generator: JsonGenerator
// Target: class User
// **************************************************************************

/// Mapper for User
abstract class UserMapper {
  /// Converts an instance of User to Map.
  static Map<String, dynamic> map(User object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('id', object.id)
          ..put('sprite', object.sprite)
          ..put('token', object.token)
          ..put('status', PlayerStatusMapper.map(object.status))
          ..put('createdAt', _owl_json.DateTimeMapper.map(object.createdAt))
          ..put('updatedAt', _owl_json.DateTimeMapper.map(object.updatedAt)))
        .toMap();
  }

  /// Converts a Map to an instance of User.
  static User parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final User object = new User();
    object.id = map['id'];
    object.sprite = map['sprite'];
    object.token = map['token'];
    object.status = PlayerStatusMapper.parse(map['status']);
    object.createdAt = _owl_json.DateTimeMapper.parse(map['createdAt']);
    object.updatedAt = _owl_json.DateTimeMapper.parse(map['updatedAt']);
    return object;
  }

  /// Converts a JSON string to an instance of User.
  static User fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of User to JSON string.
  static String toJson(User object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class PlayerStatus
// **************************************************************************

/// Mapper for PlayerStatus
abstract class PlayerStatusMapper {
  /// Converts an instance of PlayerStatus to Map.
  static Map<String, dynamic> map(PlayerStatus object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('id', object.id)
          ..put('userId', object.userId)
          ..put('windowSize', CoordinateMapper.map(object.windowSize))
          ..put('position', CoordinateMapper.map(object.position))
          ..put('createdAt', _owl_json.DateTimeMapper.map(object.createdAt))
          ..put('updatedAt', _owl_json.DateTimeMapper.map(object.updatedAt)))
        .toMap();
  }

  /// Converts a Map to an instance of PlayerStatus.
  static PlayerStatus parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final PlayerStatus object = new PlayerStatus();
    object.id = map['id'];
    object.userId = map['userId'];
    object.windowSize = CoordinateMapper.parse(map['windowSize']);
    object.position = CoordinateMapper.parse(map['position']);
    object.createdAt = _owl_json.DateTimeMapper.parse(map['createdAt']);
    object.updatedAt = _owl_json.DateTimeMapper.parse(map['updatedAt']);
    return object;
  }

  /// Converts a JSON string to an instance of PlayerStatus.
  static PlayerStatus fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of PlayerStatus to JSON string.
  static String toJson(PlayerStatus object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class Coordinate
// **************************************************************************

/// Mapper for Coordinate
abstract class CoordinateMapper {
  /// Converts an instance of Coordinate to Map.
  static Map<String, dynamic> map(Coordinate object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('x', object.x)
          ..put('y', object.y))
        .toMap();
  }

  /// Converts a Map to an instance of Coordinate.
  static Coordinate parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final Coordinate object = new Coordinate();
    object.x = map['x'];
    object.y = map['y'];
    return object;
  }

  /// Converts a JSON string to an instance of Coordinate.
  static Coordinate fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of Coordinate to JSON string.
  static String toJson(Coordinate object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}

// **************************************************************************
// Generator: JsonGenerator
// Target: class Collision
// **************************************************************************

/// Mapper for Collision
abstract class CollisionMapper {
  /// Converts an instance of Collision to Map.
  static Map<String, dynamic> map(Collision object) {
    if (object == null) return null;
    return (new _owl_json.MapBuilder(ordered: false)
          ..put('player1', object.player1)
          ..put('player2', object.player2))
        .toMap();
  }

  /// Converts a Map to an instance of Collision.
  static Collision parse(Map<String, dynamic> map) {
    if (map == null) return null;
    final Collision object = new Collision();
    object.player1 = map['player1'];
    object.player2 = map['player2'];
    return object;
  }

  /// Converts a JSON string to an instance of Collision.
  static Collision fromJson(String json) {
    if (json == null || json.isEmpty) return null;
    final Map<String, dynamic> map = JSON.decoder.convert(json);
    return parse(map);
  }

  /// Converts an instance of Collision to JSON string.
  static String toJson(Collision object) {
    if (object == null) return null;
    return JSON.encoder.convert(map(object));
  }
}
