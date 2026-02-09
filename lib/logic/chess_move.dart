
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/tile_coordinate.dart';

sealed class ChessMove {
  const ChessMove({required this.oldPosition, required this.newPosition});

  final TileCoordinate oldPosition;
  final TileCoordinate newPosition;

  void updateTiles(List<Piece?> tiles);
  bool isEqual(ChessMove other);
}

class RegularMove extends ChessMove {
  RegularMove({required super.oldPosition, required super.newPosition});

  @override
  void updateTiles(List<Piece?> tiles) {
    // Get the original piece
    final piece = tiles[oldPosition.toChessTileIndex()];

    // Remove it from it's original position
    tiles[oldPosition.toChessTileIndex()] = null;

    // Place it on the newTile
    tiles[newPosition.toChessTileIndex()] = piece;
  }

  @override
  bool isEqual(ChessMove other) =>
      other is RegularMove &&
      other.oldPosition == oldPosition &&
      other.newPosition == newPosition;
}

class EnPassant extends ChessMove {
  EnPassant({required super.oldPosition, required super.newPosition});

  @override
  void updateTiles(List<Piece?> tiles) {
    // Get the original piece
    final piece = tiles[oldPosition.toChessTileIndex()];

    // Remove it from it's original position
    tiles[oldPosition.toChessTileIndex()] = null;

    // Place it on the newTile
    tiles[newPosition.toChessTileIndex()] = piece;

    // Remove the captured piece
    tiles[capturedPawnTile().toChessTileIndex()] = null;
  }

  @override
  bool isEqual(ChessMove other) =>
      other is EnPassant &&
      oldPosition == other.oldPosition &&
      newPosition == other.newPosition;

  TileCoordinate capturedPawnTile() => TileCoordinate(
      column: newPosition.column,
      row: oldPosition.row,
    );
}


class Castling extends ChessMove {
  Castling({required super.oldPosition, required super.newPosition});

  @override
  void updateTiles(List<Piece?> tiles) {
    // Get the original piece
    final piece = tiles[oldPosition.toChessTileIndex()];

    // Remove it from it's original position
    tiles[oldPosition.toChessTileIndex()] = null;

    // Place it on the newTile
    tiles[newPosition.toChessTileIndex()] = piece;

    // Pop the rook
    // "g" is the king side castling column tile
    final rookTile = TileCoordinate(column: newPosition.column == "g" ? "h" : "a", row: oldPosition.row);
    final rook = tiles[rookTile.toChessTileIndex()];
    tiles[rookTile.toChessTileIndex()] = null;

    // Put the rook next to the rook
    final newRookTile = TileCoordinate(column: newPosition.column == "g" ? "f" : "d", row: oldPosition.row);
   tiles[newRookTile.toChessTileIndex()] = rook;

  }

  @override
  bool isEqual(ChessMove other) =>
      other is Castling &&
      oldPosition == other.oldPosition &&
      newPosition == other.newPosition;
}
