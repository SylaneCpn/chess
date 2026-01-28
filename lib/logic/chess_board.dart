import 'dart:collection';

import 'package:chess/logic/chess_history_element.dart';
import 'package:chess/logic/chess_move.dart';
import 'package:chess/logic/game_status.dart';
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:chess/logic/tile_coordinate.dart';

class ChessBoard {
  final List<ChessHistoryElement> _history;
  final List<Piece?> _tiles = List.filled(64, null);

  ChessBoard() : this._();
  ChessBoard._({List<Piece?>? tiles, List<ChessHistoryElement>? history})
    : _history = history?.toList() ?? [] {
    if (tiles != null) {
      for (int i = 0; i < 64; i++) {
        _tiles[i] = tiles[i];
      }
    } else {
      _generateTiles();
    }
  }

  ChessBoard copy() {
    return ChessBoard._(tiles: tiles, history: history);
  }

  ChessBoard copyWithMove(ChessMove move) {
    final newBoard = copy();

    move.applyToBoard(newBoard);

    //Update History
    newBoard._history.add(
      ChessHistoryElement(lastMove: move, lastTiles: tiles),
    );

    return newBoard;
  }

  void resetBoard() {
    _generateTiles();
    _history.clear();
  }

  UnmodifiableListView<Piece?> get tiles => UnmodifiableListView(_tiles);
  UnmodifiableListView<ChessHistoryElement> get history =>
      UnmodifiableListView(_history);

  TileCoordinate? needToPromote(SideColor color) {
    final startRange = switch (color) {
      .white => 56,
      .black => 0,
    };

    for (int i = startRange; i < startRange + 8; i++) {
      if (_tiles[i] is Pawn) {
        return TileCoordinate.fromChessTileIndex(i);
      }
    }

    return null;
  }

  bool isAlliedPiece(TileCoordinate coordinate, SideColor sideColor) {
    return (_tiles[coordinate.toChessTileIndex()]?.pieceColor ??
            sideColor.other()) ==
        sideColor;
  }

  bool isEnemyPiece(TileCoordinate coordinate, SideColor sideColor) {
    return (_tiles[coordinate.toChessTileIndex()]?.pieceColor ?? sideColor) !=
        sideColor;
  }

  bool isTileOccupied(TileCoordinate coordinate) {
    return _tiles[coordinate.toChessTileIndex()] != null;
  }

  bool promote(SideColor color, Piece newPiece) {
    final promotionPawnPosition = needToPromote(color);
    if (promotionPawnPosition == null) return false;

    // Replace the pawn
    _tiles[promotionPawnPosition.toChessTileIndex()] = newPiece;
    return true;
  }

  bool isMoveLegal(ChessMove move) {
    // Get the piece
    return _tiles[move.oldPosition.toChessTileIndex()]
            // Check it's moves
            ?.legalMoves(move.oldPosition, this)
            // Does it contains the move to make
            .any((m) => m.isEqual(move)) ??
        false;
  }

  bool applyMove(ChessMove move) {
    // Move isn't legal , we can't make it;
    if (!isMoveLegal(move)) return false;
    move.applyToBoard(this);
    // Update history
    _history.add(ChessHistoryElement(lastMove: move, lastTiles: tiles));
    return true;
  }

  void setTile(TileCoordinate coordinate, Piece? piece) {
    _tiles[coordinate.toChessTileIndex()] = piece;
  }

  Piece? getTile(TileCoordinate coordinate) {
    return _tiles[coordinate.toChessTileIndex()];
  }

  GameStatus gameStatus(SideColor playingSide) {
    if (isCheckMate(playingSide)) {
      return .checkMate;
    } else if (!hasLegalMoves(playingSide) && !isCheck(playingSide)) {
      return .staleMate;
    }

    //TODO IMPLEMENT DRAW BY REPETITION

    return .stillPlaying;
  }

  TileCoordinate findKing(SideColor kingColor) {
    final kingIndex = _tiles.indexWhere(
      (p) => p is King && p.pieceColor == kingColor,
    );
    return TileCoordinate.fromChessTileIndex(kingIndex);
  }

  bool hasLegalMoves(SideColor sideColor) {
    return _tiles.indexed
        // Get pieces of opposing color
        .where((ip) => ip.$2?.pieceColor == sideColor)
        // Get all of the legal moves for a given color
        .expand<ChessMove>(
          (ip) =>
              ip.$2!.legalMoves(TileCoordinate.fromChessTileIndex(ip.$1), this),
        )
        // No legal moves
        .isNotEmpty;
  }

  bool isCheck(SideColor sideColor) {
    final kingPosition = findKing(sideColor);
    return _tiles.indexed
        // Check for other color pieces
        .where((ip) => ip.$2?.pieceColor == sideColor.other())
        // Can they capture the king ?
        .any(
          (ip) => ip.$2!
              // Get the position a given opposing piece can reach
              .moves(TileCoordinate.fromChessTileIndex(ip.$1), this)
              // If any of the position is the king , then it's a check
              .any((move) => move.newPosition == kingPosition),
        );
  }

  bool isCheckMate(SideColor sideColor) {
    return
    // No legal moves
    !hasLegalMoves(sideColor) && isCheck(sideColor);
  }

  void _generateTiles() {
    //Reset
    _tiles.fillRange(0, 64);
    // Fill white pawns
    for (int i = 8; i < 16; i++) {
      _tiles[i] = Pawn(pieceColor: .white);
    }

    // Other white pieces

    // Rooks
    _tiles[TileCoordinate(column: "a", row: 1).toChessTileIndex()] = Rook(
      pieceColor: .white,
    );
    _tiles[TileCoordinate(column: "h", row: 1).toChessTileIndex()] = Rook(
      pieceColor: .white,
    );

    // Knights
    _tiles[TileCoordinate(column: "b", row: 1).toChessTileIndex()] = Knight(
      pieceColor: .white,
    );
    _tiles[TileCoordinate(column: "g", row: 1).toChessTileIndex()] = Knight(
      pieceColor: .white,
    );

    // Bishops
    _tiles[TileCoordinate(column: "c", row: 1).toChessTileIndex()] = Bishop(
      pieceColor: .white,
    );
    _tiles[TileCoordinate(column: "f", row: 1).toChessTileIndex()] = Bishop(
      pieceColor: .white,
    );

    // Queen
    _tiles[TileCoordinate(column: "d", row: 1).toChessTileIndex()] = Queen(
      pieceColor: .white,
    );

    // King
    _tiles[TileCoordinate(column: "e", row: 1).toChessTileIndex()] = King(
      pieceColor: .white,
    );

    // Fill Black pawns
    for (int i = 48; i < 56; i++) {
      _tiles[i] = Pawn(pieceColor: .black);
    }

    // Other black pieces

    // Rooks
    _tiles[TileCoordinate(column: "a", row: 8).toChessTileIndex()] = Rook(
      pieceColor: .black,
    );
    _tiles[TileCoordinate(column: "h", row: 8).toChessTileIndex()] = Rook(
      pieceColor: .black,
    );

    // Knights
    _tiles[TileCoordinate(column: "b", row: 8).toChessTileIndex()] = Knight(
      pieceColor: .black,
    );
    _tiles[TileCoordinate(column: "g", row: 8).toChessTileIndex()] = Knight(
      pieceColor: .black,
    );

    // Bishops
    _tiles[TileCoordinate(column: "c", row: 8).toChessTileIndex()] = Bishop(
      pieceColor: .black,
    );
    _tiles[TileCoordinate(column: "f", row: 8).toChessTileIndex()] = Bishop(
      pieceColor: .black,
    );

    // Queen
    _tiles[TileCoordinate(column: "d", row: 8).toChessTileIndex()] = Queen(
      pieceColor: .black,
    );

    // King
    _tiles[TileCoordinate(column: "e", row: 8).toChessTileIndex()] = King(
      pieceColor: .black,
    );
  }
}
