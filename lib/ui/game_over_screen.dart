import 'package:chess/logic/game_status.dart';
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget{

  final GameStatus gameStatus;
  final SideColor? winningSide;
  const GameOverScreen({super.key, required this.gameStatus, required this.winningSide});

  @override
  Widget build(BuildContext context) {

    final child = switch(gameStatus) {
      .checkMate => Column(
        spacing: 12.0,
        children: [
          Row(
            mainAxisAlignment: .center,
            children: [
            King(pieceColor: winningSide!).asWidget(),
            Text("won !")
          ],),
          Text("by Checkmate")
        ],
      ),

      .staleMate => Column(
        spacing: 12.0,
        children: [
          Text("Draw"),
          Text("by StaleMate")
        ],
      ),

      .drawByRepetition => Column(
        spacing: 12.0,
        children: [
          Text("Draw"),
          Text("by Repetition")
        ],
      ),

      .insufficientMaterial =>Column(
        spacing: 12.0,
        children: [
          Text("Draw"),
          Text("by Insufficient material ")
        ],
      ),

      _ => throw ArgumentError("Not supported for $gameStatus"),


    };
    return AlertDialog(
      content: Column(
        mainAxisSize: .min,
        children: [
          Align(
            alignment: .topRight,
            child: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
          ),

         child,
        ],
      ),
    );
  }


}