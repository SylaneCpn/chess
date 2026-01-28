import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:flutter/material.dart';

class PromoteWiget  extends StatelessWidget{
  final SideColor sideColor;
  final void Function(Piece) promoteCallback;

  const PromoteWiget({super.key, required this.sideColor, required this.promoteCallback});
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        mainAxisAlignment: .center,
        children : [
          GestureDetector(
            onTap :() => promoteCallback(Queen(pieceColor: sideColor)),
            child: Queen(pieceColor: sideColor).asWidget(),
          ),

          GestureDetector(
            onTap: () => promoteCallback(Rook(pieceColor: sideColor)),
            child: Rook(pieceColor: sideColor).asWidget(),
          ),

          GestureDetector(
            onTap: () => promoteCallback(Knight(pieceColor: sideColor)),
            child: Knight(pieceColor: sideColor).asWidget(),
          ),

          GestureDetector(
            onTap: () => promoteCallback(Bishop(pieceColor: sideColor)),
            child: Bishop(pieceColor: sideColor).asWidget(),
          ),
        ]
      ) ,
    );
  }
  
}