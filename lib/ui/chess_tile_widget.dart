import 'package:chess/logic/piece.dart';
import 'package:flutter/material.dart';

class ChessTileWidget extends StatelessWidget {
  final int tileIndex;
  final bool isLightedUp;
  final bool isSelected;
  final bool isLastMove;
  final Color darkTileColor;
  final Color lightTileColor;
  final Color selectedTileColor;
  final Color lightedLightTileColor;
  final Color lightedDarkTileColor;
  final Color lastLightTileColor;
  final Color lastDarkTileColor;
  final Piece? piece;
  final bool hidePiece;
  const ChessTileWidget({
    super.key,
    required this.tileIndex,
    this.darkTileColor = const Color.fromARGB(255, 12, 117, 58),
    this.lightTileColor = Colors.white12,
    this.piece,
    this.hidePiece = false,
    this.isLightedUp = false,
    this.isSelected = false,
    this.isLastMove = false,
    this.selectedTileColor = Colors.teal,
    this.lightedLightTileColor = const Color.fromARGB(255, 64, 255, 124),
    this.lightedDarkTileColor = const Color.fromARGB(255, 71, 195, 141),
    this.lastDarkTileColor = const Color.fromARGB(255, 246, 106, 96),
    this.lastLightTileColor = Colors.red

  });

  bool get isDarkSquare {
    final rowEven = tileIndex ~/ 8 % 2;
    return (tileIndex + rowEven) % 2 == 0;
  }

  Color get squareColor {
    if (isSelected) return selectedTileColor;
    return switch (isDarkSquare) {
      true => switch (isLightedUp) {
        true => lightedDarkTileColor,
        _ => switch(isLastMove) {
          true => lastDarkTileColor,
          _ => darkTileColor,
        },
      },
      _ => switch (isLightedUp) {
        true => lightedLightTileColor,
        _ => switch (isLastMove) {
          true => lastLightTileColor,
          _ => lightTileColor
        },
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: squareColor,
      child: hidePiece ? null : piece?.asWidget(),
    );
  }
}
