import 'package:logging/logging.dart';
import 'package:tttgame/common/constants.dart';
import 'package:tttgame/models/board.dart';
import 'package:tttgame/models/figure.dart';
import 'package:tttgame/models/figure_type.dart';
import 'package:tttgame/models/game_status.dart';
import 'package:tttgame/models/move.dart';
import 'package:tttgame/models/winner.dart';

class GameState {
  final _log = Logger("Server");
  late String? topPlayerId;
  late String? bottomPlayerId;
  Winner winner = Winner.none;
  bool bottomPlayerTurn = false;
  GameStatus gameStatus = GameStatus(board: Board(figures: <Figure>[]));

  Move moveFigure(Move move) {
    final figureType =
        FigureType.values.firstWhere((FigureType e) => e == move.figureType);
    if (move.clientId == topPlayerId && !bottomPlayerTurn ||
        move.clientId == bottomPlayerTurn && bottomPlayerTurn) {
      bool canPut =
          gameStatus.board.canPutFigure(move.targetCellId, figureType);
      if (canPut) {
        int color = Constants.player1Color;
        bottomPlayerTurn = true;
        if (move.clientId == bottomPlayerId) {
          color = Constants.player2Color;
          bottomPlayerTurn = false;
        }
        gameStatus.board
            .putFigure(Figure(figureType, color, move.targetCellId));
        gameStatus.board.removeFigureFromCell(move.sourceCellId);
        winner = gameStatus.board.checkWinner();
        if (winner == Winner.top) {
          _log.info('Player $topPlayerId win');
          gameStatus.winnerId = topPlayerId;
        } else if (winner == Winner.bottom) {
          _log.info('Player $bottomPlayerId win');
          gameStatus.winnerId = bottomPlayerId;
        }
        move.canPut = true;
      } else {
        move.canPut = false;
      }
    }
    return move;
  }
}
