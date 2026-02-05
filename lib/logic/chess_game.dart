import 'dart:collection';

import 'package:chess/logic/chess_history_element.dart';
import 'package:chess/logic/chess_move.dart';
import 'package:chess/logic/game_status.dart';
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:chess/logic/tile_coordinate.dart';

class ChessGame {
  final List<ChessHistoryElement> _history;
  final List<Piece?> _tiles = List.filled(64, null);
  SideColor _playingSide;

  ChessGame() : this._();
  ChessGame._({
    List<Piece?>? tiles,
    List<ChessHistoryElement>? history,
    SideColor playingSide = .white,
  }) : _history = history?.toList() ?? [],
       _playingSide = playingSide {
    if (tiles != null) {
      for (int i = 0; i < 64; i++) {
        _tiles[i] = tiles[i];
      }
    } else {
      _generateTiles();
    }
  }

  ChessGame copy() {
    return ChessGame._(
      tiles: tiles,
      history: history,
      playingSide: playingSide,
    );
  }

  ChessGame copyWithMove(ChessMove move) {
    final newBoard = copy();

    move.updateTiles(newBoard._tiles);

    //Update History
    newBoard._history.add(
      ChessHistoryElement(lastMove: move, lastTiles: tiles),
    );

    //Update Playing Side
    newBoard._playingSide = _playingSide.other();

    return newBoard;
  }

  void resetBoard() {
    _generateTiles();
    _history.clear();
    _playingSide = .white;
  }

  UnmodifiableListView<Piece?> get tiles => UnmodifiableListView(_tiles);
  UnmodifiableListView<ChessHistoryElement> get history =>
      UnmodifiableListView(_history);

  SideColor get playingSide => _playingSide;

  TileCoordinate? needToPromote() {
    final startRange = switch (_playingSide.other()) {
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

  bool promote(Piece newPiece) {
    final promotionPawnPosition = needToPromote();
    if (promotionPawnPosition == null) return false;

    // Replace the pawn
    _setTile(promotionPawnPosition, newPiece);
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

  bool hasInsufficientMaterial() {
    // Check for white
    final whitePieces = _tiles.where((p) => p?.pieceColor == .white);
    final hasWhiteInsufficientMaterial =
        whitePieces.toList().length == 1 ||
        (whitePieces.toList().length == 2 &&
            whitePieces.where((p) => p is Knight || p is Bishop).isNotEmpty);

    // Check for black
    final blackPieces = _tiles.where((p) => p?.pieceColor == .black);
    final hasBlackInsufficientMaterial =
        blackPieces.toList().length == 1 ||
        (blackPieces.toList().length == 2 &&
            blackPieces.where((p) => p is Knight || p is Bishop).isNotEmpty);

    return hasBlackInsufficientMaterial && hasWhiteInsufficientMaterial;
  }

  bool hasRepeatedPosition(int count) {
    final previousTiles = _history.map((he) => he.lastTiles);
    return previousTiles.where((pt) => pt.isEqual(_tiles)).length >= count;
  }

  bool applyMove(ChessMove move) {
    // Move isn't legal , we can't make it;
    // Or it not right side playing
    if (!isMoveLegal(move) ||
        getTile(move.oldPosition)?.pieceColor != _playingSide) {
      return false;
    }
    move.updateTiles(_tiles);
    // Update history
    _history.add(ChessHistoryElement(lastMove: move, lastTiles: tiles));
    _playingSide = _playingSide.other();
    return true;
  }

  void _setTile(TileCoordinate coordinate, Piece? piece) {
    _tiles[coordinate.toChessTileIndex()] = piece;
  }

  Piece? getTile(TileCoordinate coordinate) {
    return _tiles[coordinate.toChessTileIndex()];
  }

  GameStatus gameStatus() {
    if (isCheckMate(_playingSide)) {
      return .checkMate;
    } else if (!hasLegalMoves(_playingSide) && !isCheck(_playingSide)) {
      return .staleMate;
    } else if (hasInsufficientMaterial()) {
      return .insufficientMaterial;
    } else if (hasRepeatedPosition(3)) {
      return .drawByRepetition;
    }
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
    _setTile(whiteQueenSideRookInitPosition, const Rook(pieceColor: .white));
    _setTile(whiteKingSideRookInitPosition, const Rook(pieceColor: .white));

    // Knights
    _setTile(
      whiteQueenSideKnightInitPosition,
      const Knight(pieceColor: .white),
    );
    _setTile(whiteKingSideKnightInitPosition, const Knight(pieceColor: .white));

    // Bishops
    _setTile(
      whiteQueenSideBishopInitPosition,
      const Bishop(pieceColor: .white),
    );
    _setTile(whiteKingSideBishopInitPosition, const Bishop(pieceColor: .white));

    // Queen
    _setTile(whiteQueenInitPosition, const Queen(pieceColor: .white));

    // King
    _setTile(whiteKingInitPosition, const King(pieceColor: .white));

    // Fill Black pawns
    for (int i = 48; i < 56; i++) {
      _tiles[i] = Pawn(pieceColor: .black);
    }

    // Other black pieces

    // Rooks
    _setTile(blackQueenSideRookInitPosition, const Rook(pieceColor: .black));
    _setTile(blackKingSideRookInitPosition, const Rook(pieceColor: .black));

    // Knights
    _setTile(
      blackQueenSideKnightInitPosition,
      const Knight(pieceColor: .black),
    );
    _setTile(blackKingSideKnightInitPosition, const Knight(pieceColor: .black));

    // Bishops
    _setTile(
      blackQueenSideBishopInitPosition,
      const Bishop(pieceColor: .black),
    );
    _setTile(blackKingSideBishopInitPosition, const Bishop(pieceColor: .black));

    // Queen
    _setTile(blackQueenInitPosition, const Queen(pieceColor: .black));

    // King
    _setTile(blackKingInitPosition, const King(pieceColor: .black));
  }
}

extension ChessTileEqual on List<Piece?> {
  bool isEqual(List<Piece?> other) {
    if (length != other.length) {
      return false;
    }
    return Iterable.generate(length, (i) => (this[i], other[i])).every((e) {
      if ((e.$1 == null) && (e.$2 == null)) {
        return true;
      }

      if ((e.$1 != null) && (e.$2 != null)) {
        return e.$1!.isEqual(e.$2!);
      }

      return false;
    });
  }
}
