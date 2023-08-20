import 'board.dart';

class GameStatus {
  GameStatus({required this.board, this.winnerId});
  Board board;
  String? winnerId;

  factory GameStatus.fromJson(Map<String, dynamic> json) {
    return GameStatus(
      board: Board.fromJson(json['board']),
      winnerId: json.containsKey('winnerId') ? json['winnerId'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'board': board.toJson(),
    };
    if (winnerId != null) {
      data['winnerId'] = winnerId;
    }
    return data;
  }
}
