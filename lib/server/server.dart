import 'dart:async';
import 'dart:io';

import 'package:logging/logging.dart';
import 'package:tttgame/common/constants.dart';
import 'package:tttgame/models/message.dart';
import 'package:tttgame/models/player_role.dart';
import 'package:tttgame/models/welcome_message.dart';
import 'package:tttgame/server/game_state.dart';
import 'package:uuid/uuid.dart';

class ServerManager {
  final _log = Logger("Server");
  final Map<String, WebSocket> connectedClients = {};
  bool gameStated = false;
  GameState gameState = GameState();

  void init() async {
    final server =
        await HttpServer.bind(InternetAddress.loopbackIPv4, Constants.port);
    _log.info(
        "Websocket started ws://${server.address.address}:${server.port}");

    await for (HttpRequest request in server) {
      if (WebSocketTransformer.isUpgradeRequest(request)) {
        WebSocketTransformer.upgrade(request).then((websocket) {
          handleNewConnection(websocket);
        });
      }
    }
  }

  void handleNewConnection(WebSocket webSocket) {
    final clientId = const Uuid().v4();
    _log.info("New client connected: $clientId");

    connectedClients[clientId] = webSocket;
    bool canPlay = false;
    PlayerRole playerRole = PlayerRole.observer;
    if (connectedClients.length <= 2) {
      canPlay = true;
      if (connectedClients.length == 1) {
        gameState.topPlayerId = clientId;
        playerRole = PlayerRole.topPlayer;
      } else if (connectedClients.length == 2) {
        gameState.bottomPlayerId = clientId;
        playerRole = PlayerRole.bottomPlayer;
      }
    }

    final welcomeMessage = Message(MessageType.welcome,
        welcomeMessage: WelcomeMessage(clientId, canPlay, playerRole));
    final messageString = welcomeMessage.toJsonString();
    webSocket.add(messageString);

    if (connectedClients.length > 1) {
      if (!gameStated) {
        _log.info(
            'A new game starting for clients: ${connectedClients.keys.toString()}');
        gameState.gameStatus.board.startNewGame();
        gameStated = true;
      }
    }
    handleMessages(webSocket, clientId);
  }

  void handleMessages(WebSocket webSocket, String clientId) {
    webSocket.listen((data) {
      final message = Message.fromJsonString(data);
      if (message.type == MessageType.move) {
        final move = message.move;
        gameState.moveFigure(move!);
      }
    }, onError: (error) {
      _log.shout('Error connection for client $clientId: $error');
      connectedClients.remove(clientId);
    }, onDone: () {
      _log.warning('Connection for client $clientId closed');
      connectedClients.remove(clientId);
    });
  }

  void broadcast() {
    Timer.periodic(Constants.broadcastInterval, (timer) {
      final message =
          Message(MessageType.gameStatus, gameStatus: gameState.gameStatus);
      final messageString = message.toJsonString();
      connectedClients.forEach((clientId, webSocket) {
        webSocket.add(messageString);
      });
    });
  }
}

void main() async {
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: '
        '${record.loggerName}: '
        '${record.message}');
  });
  ServerManager server = ServerManager();
  server.init();
}
