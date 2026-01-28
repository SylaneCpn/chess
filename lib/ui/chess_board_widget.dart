import 'dart:math';

import 'package:chess/logic/chess_board.dart';
import 'package:chess/logic/chess_move.dart';
import 'package:chess/logic/game_status.dart';
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:chess/logic/tile_coordinate.dart';
import 'package:chess/ui/chess_tile_widget.dart';
import 'package:chess/ui/promote_wiget.dart';
import 'package:flutter/material.dart';

class ChessBoardWidget extends StatefulWidget {
  const ChessBoardWidget({super.key});

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  final ChessBoard chessBoard = .new();
  SideColor orientationColor = .white;
  SideColor playingColor = .white;
  int? selectedTileIndex;

  void _setSelected(int index) {
    final newIndex = switch (index == selectedTileIndex) {
      true => null,
      _ => index,
    };
    setState(() {
      selectedTileIndex = newIndex;
    });
  }

  void _handleIfGameEnded() {
    final gameStatus = chessBoard.gameStatus(playingColor);
    if (gameStatus != GameStatus.stillPlaying) {
      setState(() {
        chessBoard.resetBoard();
        playingColor = .white;
        orientationColor = .white;
      });
    }
  }

  void _onTapCallback(int index, Set<ChessMove>? legalMoves) async {
    final move = legalMoves
        ?.where(
          (m) => m.newPosition == TileCoordinate.fromChessTileIndex(index),
        )
        .firstOrNull;
    if (selectedTileIndex == null || move == null) {
      _setSelected(index);
      return;
    }

    chessBoard.applyMove(move);

    // Refresh the screen before promoting
    setState(() {
      
    });

    //Check if can promote
    if (chessBoard.needToPromote(playingColor) != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PromoteWiget(
          sideColor: playingColor,
          promoteCallback: (piece) {
            chessBoard.promote(playingColor, piece);
            Navigator.pop(context);
          },
        ),
      );
    }

    // final lastMove = chessBoard.history.last.lastMove;
    // final lastPieceMoved = chessBoard.getTile(lastMove.newPosition)!;
    // print("lastMove piece type : ${lastPieceMoved.runtimeType}");
    // print("lastPieceMoved row distance : ${(lastMove.oldPosition.row - lastMove.newPosition.row).abs()}");

    setState(() {
      playingColor = playingColor.other();
      selectedTileIndex = null;
    });

    // Check if game has ended
    _handleIfGameEnded();
  }

  Set<ChessMove>? _legalMovesForSelectedIndex() {
    if (selectedTileIndex == null) return null;
    final selectedPiece = chessBoard.tiles[selectedTileIndex!];

    // No selected piece or Not for the side playing
    if (selectedPiece == null || selectedPiece.pieceColor != playingColor) {
      return null;
    }

    final tiles = selectedPiece.legalMoves(
      TileCoordinate.fromChessTileIndex(selectedTileIndex!),
      chessBoard,
    );

    return tiles.toSet();
  }

  bool isTileLightedUp(int tileIndex, Set<ChessMove>? legalMoves) {
    if (legalMoves == null) return false;
    return legalMoves.any(
      (t) => t.newPosition == TileCoordinate.fromChessTileIndex(tileIndex),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final dim = min(constraints.maxHeight, constraints.maxWidth) * 0.8;
        final legalMoves = _legalMovesForSelectedIndex();
        return Column(
          mainAxisAlignment: .center,
          children: [
            Container(
              height: dim,
              width: dim,
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Colors.black),
              ),
              child: GridView.count(
                reverse: orientationColor == .white,
                crossAxisCount: 8,
                physics: NeverScrollableScrollPhysics(),
                children: chessBoard.tiles.indexed.map((ie) {
                  return GestureDetector(
                    onTap: () => _onTapCallback(ie.$1, legalMoves),
                    child: ChessTileWidget(
                      tileIndex: ie.$1,
                      isSelected: selectedTileIndex == ie.$1,
                      isLightedUp: isTileLightedUp(ie.$1, legalMoves),
                      piece: ie.$2,
                    ),
                  );
                }).toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                crossAxisAlignment: .center,
                mainAxisAlignment: .center,
                children: [
                  King(pieceColor: playingColor).asWidget(),
                  Text("to play."),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
