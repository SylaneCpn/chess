import 'package:chess/logic/chess_move.dart';
import 'package:chess/logic/piece.dart';

class ChessHistoryElement {
  final ChessMove lastMove;
  final List<Piece?> lastTiles;


  ChessHistoryElement({required this.lastMove , required Iterable<Piece?> lastTiles }) : lastTiles = lastTiles.toList();
  

}