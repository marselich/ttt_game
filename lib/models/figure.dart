import 'package:tttgame/models/figure_type.dart';

class Figure {
  final FigureType figureType;
  final int color;
  final int cellId;

  const Figure(this.figureType, this.color, this.cellId);

  factory Figure.fromJson(Map<String, dynamic> json) {
    return Figure(
      FigureType.values.byName(json["figureType"]),
      json["color"],
      json["cellId"],
    );
  }

  Map<String, dynamic> toJson() => {
        "figureType": figureType,
        "color": color,
        "cellId": cellId,
      };
}
