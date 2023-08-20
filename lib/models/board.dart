import 'package:tttgame/models/figure.dart';
import 'package:tttgame/models/figure_type.dart';
import 'package:tttgame/models/winner.dart';

import '../common/constants.dart';

class Board {
  Board({required this.figures});
  List<Figure> figures;

  factory Board.fromJson(Map<String, dynamic> json) {
    List<dynamic> figuresJson = json["figures"];
    final figures = figuresJson.map((e) => Figure.fromJson(e)).toList();
    return Board(figures: figures);
  }

  Map<String, dynamic> toJson() => {
        "figures": figures.map((e) => e.toJson()).toList(),
      };

  void startNewGame() {
    figures.clear();
    figures.add(const Figure(FigureType.small, Constants.player1Color, 0));
    figures.add(const Figure(FigureType.small, Constants.player1Color, 0));

    figures.add(const Figure(FigureType.medium, Constants.player1Color, 1));
    figures.add(const Figure(FigureType.medium, Constants.player1Color, 1));

    figures.add(const Figure(FigureType.large, Constants.player1Color, 2));
    figures.add(const Figure(FigureType.large, Constants.player1Color, 2));

    figures.add(const Figure(FigureType.small, Constants.player2Color, 12));
    figures.add(const Figure(FigureType.small, Constants.player2Color, 12));

    figures.add(const Figure(FigureType.medium, Constants.player2Color, 13));
    figures.add(const Figure(FigureType.medium, Constants.player2Color, 13));

    figures.add(const Figure(FigureType.large, Constants.player2Color, 14));
    figures.add(const Figure(FigureType.large, Constants.player2Color, 14));
  }

  void removeFigureFromCell(int cellId) {
    final int index = figures.indexWhere((element) => element.cellId == cellId);
    if (index != -1) {
      figures.removeAt(index);
    }
  }

  bool canPutFigure(int cellId, FigureType otherFigureType) {
    final Figure figureServer = figures.lastWhere(
      (figure) => figure.cellId == cellId,
      orElse: () => Constants.noneFigure,
    );
    if (figureServer.figureType == FigureType.none) {
      return true;
    } else if (figureServer.figureType == FigureType.large) {
      return false;
    } else {
      switch (otherFigureType) {
        case FigureType.small:
          return false;
        case FigureType.medium:
          if (figureServer.figureType == FigureType.small) {
            return true;
          } else {
            return false;
          }
        case FigureType.large:
          if (figureServer.figureType == FigureType.small ||
              figureServer.figureType == FigureType.medium) {
            return true;
          } else {
            return false;
          }
        case FigureType.none:
          return true;
      }
    }
  }

  void putFigure(Figure figure) => figures.add(figure);

  Winner checkWinner() {
    if (playerWin(Constants.player1Color)) {
      return Winner.top;
    } else if (playerWin(Constants.player2Color)) {
      return Winner.bottom;
    }
    return Winner.none;
  }

  bool playerWin(int playerColor) {
    final List<int> playerCells = <int>[];
    for (final Figure pFigure in figures) {
      final Figure lastFigure =
          figures.where((figure) => figure.cellId == pFigure.cellId).last;
      if (lastFigure.color == playerColor) {
        playerCells.add(pFigure.cellId);
      }
      for (final List<int> wins in Constants.winnigCombinations) {
        int matchCount = 0;
        for (final int w in wins) {
          if (playerCells.contains(w)) {
            matchCount++;
          }
        }
        if (matchCount == Constants.winningCount) {
          return true;
        }
      }
    }
    return false;
  }
}
