
import 'package:chess/logic/piece.dart';
import 'package:chess/logic/tile_coordinate.dart';

class ChessMove {
  final TileCoordinate oldPosition;
  final TileCoordinate newPosition;
  final Piece piece;

  const ChessMove({required this.piece, required this.oldPosition, required this.newPosition});
}
