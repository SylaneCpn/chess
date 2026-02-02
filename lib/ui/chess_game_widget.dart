import 'package:chess/logic/chess_game.dart';
import 'package:chess/logic/chess_move.dart';
import 'package:chess/logic/game_status.dart';
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/position.dart';
import 'package:chess/logic/side_color.dart';
import 'package:chess/logic/tile_coordinate.dart';
import 'package:chess/ui/chess_board_widget.dart';
import 'package:chess/ui/game_over_screen.dart';
import 'package:chess/ui/promote_wiget.dart';
import 'package:flutter/material.dart';

class ChessGameWidget extends StatefulWidget {
  const ChessGameWidget({super.key});

  @override
  State<ChessGameWidget> createState() => _ChessGameWidgetState();
}

class _ChessGameWidgetState extends State<ChessGameWidget>
    with TickerProviderStateMixin {
  final ChessGame chessBoard = .new();
  SideColor orientationColor = .white;
  bool autoFlip = false;
  int? selectedTileIndex;
  int? destinationIndex;
  late final AnimationController _animController = .new(
    vsync: this,
    duration: const Duration(milliseconds: 70),
  );
  late final Animation<double> _animation = _animController.drive(
    Tween(begin: 0.0, end: 1.0),
  );
  double _animationValue = 0.0;

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animation.addListener(() {
      setState(() {
        _animationValue = _animation.value;
      });
    });
    super.initState();
  }

  void _setSelected(int index) {
    final newIndex = switch (index == selectedTileIndex) {
      true => null,
      _ => index,
    };
    setState(() {
      selectedTileIndex = newIndex;
    });
  }

  Future<void> _handleIfGameEnded() async {
    final gameStatus = chessBoard.gameStatus();
    if (gameStatus != GameStatus.stillPlaying) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => GameOverScreen(
          gameStatus: gameStatus,
          winningSide: chessBoard.playingSide.other(),
        ),
      );
    }

    setState(() {});
  }

  Future<void> _handlePromotion() async {
    if (chessBoard.needToPromote() != null) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PromoteWiget(
          sideColor: chessBoard.playingSide.other(),
          promoteCallback: (piece) {
            chessBoard.promote(piece);
            Navigator.pop(context);
          },
        ),
      );
    }

    setState(() {});
  }

  void resetGame() {
    setState(() {
      chessBoard.resetBoard();
      orientationColor = .white;
    });
  }

  void flipBoard() {
    setState(() {
      orientationColor = orientationColor.other();
    });
  }

  void toggleAutoFlip() {
    if (autoFlip) {
      setState(() {
        autoFlip = false;
      });
    } else {
      setState(() {
        autoFlip = true;
        orientationColor = chessBoard.playingSide;
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

    //Sets the destination index to the one clicked
    destinationIndex = index;

    // Play the animation
    await _animController.forward();

    // Reset the selection
    setState(() {
      selectedTileIndex = null;
      destinationIndex = null;
      _animationValue = 0.0;
    });

    _animController.reset();

    chessBoard.applyMove(move);

    // Refresh the screen before promoting
    setState(() {});

    //Check if can promote
    await _handlePromotion();

    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      if (autoFlip) {
        orientationColor = chessBoard.playingSide;
      }
    });
    // Check if game has ended
    await _handleIfGameEnded();
  }

  Set<ChessMove>? _legalMovesForSelectedIndex() {
    if (selectedTileIndex == null) return null;
    final selectedPiece = chessBoard.tiles[selectedTileIndex!];

    // No selected piece or Not for the side playing
    if (selectedPiece == null ||
        selectedPiece.pieceColor != chessBoard.playingSide) {
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

  Position _calculatePiecePosition(BoxConstraints boardSize, int index) {
    final height = boardSize.maxHeight;
    final width = boardSize.maxWidth;

    final hTileSize = width / 8;
    final vTileSize = height / 8;

    final column = index % 8;
    final row = index ~/ 8;

    final l = column * vTileSize;
    final b = row * hTileSize;

    return switch (orientationColor) {
      .white => Position(left: l, bottom: b),
      .black => Position(left: l, bottom: height - b - hTileSize),
    };
  }

  Position _interpolatePosition({
    required Position basePosition,
    required Position finalPosition,
    required double progress,
  }) {
    final hm = finalPosition.bottom - basePosition.bottom;
    final vm = finalPosition.left - basePosition.left;

    final hp = basePosition.bottom;
    final vp = basePosition.left;

    return Position(bottom: hm * progress + hp, left: vm * progress + vp);
  }

  @override
  Widget build(BuildContext context) {
    final legalMoves = _legalMovesForSelectedIndex();

    return Column(
      mainAxisAlignment: .center,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(width: 2.0, color: Colors.black),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final piecePostion = _calculatePiecePosition(
                      constraints,
                      selectedTileIndex ?? 0,
                    );
                    final destinationPosition = _calculatePiecePosition(
                      constraints,
                      destinationIndex ?? 0,
                    );
                    final Position(:left, :bottom) = _interpolatePosition(
                      basePosition: piecePostion,
                      finalPosition: destinationPosition,
                      progress: _animationValue,
                    );
                    return Stack(
                      children: [
                        ChessBoardWidget(
                          tiles: chessBoard.tiles,
                          orientationColor: orientationColor,
                          selectedTileIndex: selectedTileIndex,
                          onTapCallback: (tappedIndex) =>
                              _onTapCallback(tappedIndex, legalMoves),
                          hiddenTilesIndexes: selectedTileIndex != null
                              ? [selectedTileIndex!]
                              : null,
                          lightedUpTilesIndexes: Iterable<int>.generate(64)
                              .where(
                                (index) => isTileLightedUp(index, legalMoves),
                              )
                              .toList(),
                        ),
                        if (selectedTileIndex != null)
                          Positioned(
                            left: left,
                            bottom: bottom,
                            height: constraints.maxHeight / 8,
                            width: constraints.maxWidth / 8,
                            child:
                                chessBoard.tiles
                                    .elementAt(selectedTileIndex!)
                                    ?.asWidget() ??
                                ColoredBox(color: Colors.transparent),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: .center,
            mainAxisAlignment: .center,
            children: [
              King(pieceColor: chessBoard.playingSide).asWidget(),
              Text("to play."),
            ],
          ),
        ),

        Row(
          mainAxisAlignment: .center,
          children: [
            Checkbox(value: autoFlip, onChanged: (_) => toggleAutoFlip()),
            Text("Autoflip"),
          ],
        ),

        Row(
          mainAxisAlignment: .spaceEvenly,
          children: [
            TextButton(onPressed: resetGame, child: Text("Reset Game")),
            TextButton(
              onPressed: !autoFlip ? flipBoard : null,
              child: Text("Flip Board"),
            ),
          ],
        ),
      ],
    );
  }
}
