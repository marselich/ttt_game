import 'figure_type.dart';

class Move {
  Move(
      {required this.clientId,
      required this.sourceCellId,
      required this.targetCellId,
      required this.figureType,
      this.canPut});

  String clientId;
  int sourceCellId;
  int targetCellId;
  FigureType figureType;
  bool? canPut;

  factory Move.fromJson(Map<String, dynamic> json) {
    return Move(
      clientId: json["clientId"],
      sourceCellId: json["sourceCellId"],
      targetCellId: json["targetCellId"],
      figureType: FigureType.values.byName(json["figureType"]),
      canPut: json.containsKey("canPut") ? json["canPut"] : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> data = {
      "clientId": clientId,
      "sourceCellId": sourceCellId,
      "targetCellId": targetCellId,
      "figureType": figureType,
    };
    if (canPut != null) {
      data["canPut"] = canPut;
    }
    return data;
  }
}
