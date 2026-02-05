import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:flutter/material.dart';

class PiecesEatenWidget extends StatelessWidget {
  final List<Piece> pieces;
  final double spacing;
  final SideColor color;
  const PiecesEatenWidget({
    super.key,
    required this.pieces,
    required this.spacing, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scaleX: color == .black ? -1 : 1,
      child: GridView.count(
        crossAxisCount: 8,
        physics: NeverScrollableScrollPhysics(),
        children: [
          ...pieces.map((p) => p.asWidget())
        ],
      ),
    );
  }
}
