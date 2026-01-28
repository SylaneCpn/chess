import 'package:chess/logic/chess_board.dart';
import 'package:chess/logic/tile_coordinate.dart';

sealed class ChessMove {
  const ChessMove({required this.oldPosition, required this.newPosition});

  final TileCoordinate oldPosition;
  final TileCoordinate newPosition;

  void applyToBoard(ChessBoard board);
  bool isEqual(ChessMove other);
}

class RegularMove extends ChessMove {
  RegularMove({required super.oldPosition, required super.newPosition});

  @override
  void applyToBoard(ChessBoard board) {
    // Get the original piece
    final piece = board.tiles[oldPosition.toChessTileIndex()];

    // Remove it from it's original position
    board.setTile(oldPosition, null);

    // Place it on the newTile
    board.setTile(newPosition, piece);
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
  void applyToBoard(ChessBoard board) {
    // Get the original piece
    final piece = board.tiles[oldPosition.toChessTileIndex()];

    // Remove it from it's original position
    board.setTile(oldPosition, null);

    // Place it on the newTile
    board.setTile(newPosition, piece);

    // Remove the captured piece
    final capturePiecePosition = TileCoordinate(column: newPosition.column, row: oldPosition.row);
    board.setTile(capturePiecePosition, null);
  }

  @override
  bool isEqual(ChessMove other) =>
    other is EnPassant && oldPosition == other.oldPosition && newPosition == other.newPosition;
  

}

// TODO : IMPLEMENT CASTLING
