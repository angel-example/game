[![The Angel Framework](https://angel-dart.github.io/images/logo.png)](https://angel-dart.github.io)

[![Gitter](https://img.shields.io/gitter/room/nwjs/nw.js.svg)](https://gitter.im/angel_dart/discussion)
[![version: v1.0.0](https://img.shields.io/badge/pub-v1.0.0-brightgreen.svg)](https://pub.dartlang.org/packages/angel_common)

# game
A real-time multi-player game implemented with Angel and
[Phaser](http://phaser.io/). This project showcases:
* [WebSockets](https://github.com/angel-dart/websocket)
* [Client use](https://github.com/angel-dart/client)
* [Proxying `pub serve`](https://github.com/angel-dart/proxy)
* [Services](https://github.com/angel-dart/angel/wiki/Service-Basics)
    * [In-memory Services](https://github.com/angel-dart/angel/wiki/In-Memory)
* [Testing](https://github.com/angel-dart/angel/wiki/Testing)
* [Authentication](https://github.com/angel-dart/auth)
* [Error Handling](https://github.com/angel-dart/angel/wiki/Error-Handling)
* [Mustache Templates](https://github.com/angel-dart/mustache)
* And more...

# Installation and Setup

## Installing Dependencies
```bash
pub get
```

## Building the Client
```bash
pub build
```

## Running the Server
```bash
ANGEL_ENV=production dart bin/server.dart
```

Now, you can visit
[http://localhost:3000](http://localhost:3000)
and start playing!

# Credit
*Background:* Bevouliin
https://opengameart.org/content/bevouliin-free-game-background-for-game-developers