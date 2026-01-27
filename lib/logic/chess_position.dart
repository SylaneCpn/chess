import 'package:chess/logic/piece.dart';
import 'package:chess/logic/tile_coordinate.dart';

class ChessPosition {

  final Piece piece;
  final TileCoordinate coordinate;

  const ChessPosition({required this.piece , required this.coordinate});

}