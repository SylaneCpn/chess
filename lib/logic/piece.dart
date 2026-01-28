import 'package:chess/logic/chess_board.dart';
import 'package:chess/logic/chess_move.dart';
import 'package:chess/logic/side_color.dart';
import 'package:chess/logic/tile_coordinate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

sealed class Piece {
  String get assetImagePath;

  final SideColor pieceColor;
  const Piece({required this.pieceColor});

  Widget asWidget() => SvgPicture.asset(assetImagePath);
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board);
  List<ChessMove> legalMoves(TileCoordinate piecePosition, ChessBoard board) {
    return moves(piecePosition, board).where((m) {
      // See if the move leads to a check
      final boardWithMove = board.copyWithMove(m);

      // Can move only if the next position is not check
      return !boardWithMove.isCheck(pieceColor);
    }).toList();
  }
}

class Pawn extends Piece {
  const Pawn({required super.pieceColor});

  bool isInitTile(TileCoordinate piecePosition) {
    return switch (pieceColor) {
      .white => piecePosition.row == 2,
      .black => piecePosition.row == 7,
    };
  }

  @override
  String get assetImagePath {
    return switch (pieceColor) {
      .black => "assets/pieces-svg/pawn-b.svg",
      .white => "assets/pieces-svg/pawn-w.svg",
    };
  }

  @override
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <ChessMove>[];
    // Tile in front
    final frontTile = switch (pieceColor) {
      .white => piecePosition.addRow(1)!,
      .black => piecePosition.subRow(1)!,
    };
    if (!board.isTileOccupied(frontTile)) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: frontTile),
      );
    }

    // Two tile in front on the first move
    if (isInitTile(piecePosition)) {
      final twoTilesInFront = switch (pieceColor) {
        .white => piecePosition.addRow(2)!,
        .black => piecePosition.subRow(2)!,
      };
      // Cannot go if it's occupied
      if (!board.isTileOccupied(twoTilesInFront)) {
        positions.add(
          RegularMove(oldPosition: piecePosition, newPosition: twoTilesInFront),
        );
      }
    }

    // Check from for capture
    final capturesTiles = switch (pieceColor) {
      .white => [
        piecePosition.addColumn(1)?.addRow(1),
        piecePosition.subColumn(1)?.addRow(1),
      ],
      .black => [
        piecePosition.addColumn(1)?.subRow(1),
        piecePosition.subColumn(1)?.subRow(1),
      ],
    };

    // Filter tile that doesn't exist
    for (final tile in capturesTiles.where((t) => t != null)) {
      // If there is enemy pieces on capture tiles
      if (board.isEnemyPiece(tile!, pieceColor)) {
        positions.add(
          RegularMove(oldPosition: piecePosition, newPosition: tile),
        );
      }
    }

    // Check for en passant
    final lastMove = board.history.lastOrNull?.lastMove;
    if (lastMove case RegularMove(
      oldPosition: final lastPieceMovedOldPosition,
      newPosition: final lastPieceMovedNewPosition,
    )) {
      final lastPieceMoved = board.getTile(lastPieceMovedNewPosition);
      // A Pawn has moved two tiles
      if (lastPieceMoved is Pawn &&
          ((lastPieceMovedNewPosition.row - lastPieceMovedOldPosition.row)
                  .abs() ==
              2)) {
        // it is next to the selected piece tile
        if (piecePosition == lastPieceMovedNewPosition.subColumn(1) ||
            piecePosition == lastPieceMovedNewPosition.addColumn(1)) {
          // Calculate the row the selected piece should move
          final newRow =
              piecePosition.row +
              ((lastPieceMovedOldPosition.row -
                      lastPieceMovedNewPosition.row) ~/
                  2);
          // Create the position the piece will move to
          final newTile = TileCoordinate(
            column: lastPieceMovedNewPosition.column,
            row: newRow,
          );

          positions.add(
            EnPassant(oldPosition: piecePosition, newPosition: newTile),
          );
        }
      }
    }
    return positions;
  }
}

class Rook extends Piece {
  const Rook({required super.pieceColor});

  @override
  String get assetImagePath {
    return switch (pieceColor) {
      .black => "assets/pieces-svg/rook-b.svg",
      .white => "assets/pieces-svg/rook-w.svg",
    };
  }

  @override
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <ChessMove>[];
    // Positions over column on right
    // In the worst case, the piece is on the left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over column on left
    // In the worst case, the piece is on the right of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subColumn(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over row on top
    // In the worst case, the piece is on the bottom of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over row on top
    // In the worst case, the piece is on the bottom of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    return positions;
  }
}

class Knight extends Piece {
  const Knight({required super.pieceColor});

  @override
  String get assetImagePath {
    return switch (pieceColor) {
      .black => "assets/pieces-svg/knight-b.svg",
      .white => "assets/pieces-svg/knight-w.svg",
    };
  }

  @override
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <ChessMove>[];

    // Top Right
    final topRightT = piecePosition.addRow(2)?.addColumn(1);
    final topRightB = piecePosition.addRow(1)?.addColumn(2);

    // if the Tile is not null and there is not an allied piece on it
    if (!(topRightT == null || board.isAlliedPiece(topRightT, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: topRightT),
      );
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(topRightB == null || board.isAlliedPiece(topRightB, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: topRightB),
      );
    }

    // Top left
    final topLeftT = piecePosition.addRow(2)?.subColumn(1);
    final topLeftB = piecePosition.addRow(1)?.subColumn(2);

    // if the Tile is not null and there is not an allied piece on it
    if (!(topLeftT == null || board.isAlliedPiece(topLeftT, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: topLeftT),
      );
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(topLeftB == null || board.isAlliedPiece(topLeftB, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: topLeftB),
      );
    }

    // Bottom left
    final bottomLeftT = piecePosition.subRow(1)?.subColumn(2);
    final bottomLeftB = piecePosition.subRow(2)?.subColumn(1);

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomLeftT == null ||
        board.isAlliedPiece(bottomLeftT, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: bottomLeftT),
      );
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomLeftB == null ||
        board.isAlliedPiece(bottomLeftB, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: bottomLeftB),
      );
    }

    // Bottom right
    final bottomRightT = piecePosition.subRow(1)?.addColumn(2);
    final bottomRightB = piecePosition.subRow(2)?.addColumn(1);

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomRightT == null ||
        board.isAlliedPiece(bottomRightT, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: bottomRightT),
      );
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomRightB == null ||
        board.isAlliedPiece(bottomRightB, pieceColor))) {
      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: bottomRightB),
      );
    }

    return positions;
  }
}

class Bishop extends Piece {
  const Bishop({required super.pieceColor});

  @override
  String get assetImagePath {
    return switch (pieceColor) {
      .black => "assets/pieces-svg/bishop-b.svg",
      .white => "assets/pieces-svg/bishop-w.svg",
    };
  }

  @override
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <ChessMove>[];
    // Positions over top right diagonal
    // In the worst case, the piece is on the bottom left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i)?.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over top left diagonal
    // In the worst case, the piece is on the bottom right of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subColumn(i)?.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over bottom right diagonal
    // In the worst case, the piece is on the top left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i)?.subRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over the bottom left diagonal
    // In the worst case, the piece is on the top right of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subColumn(i)?.subRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    return positions;
  }
}

class Queen extends Piece {
  const Queen({required super.pieceColor});

  @override
  String get assetImagePath {
    return switch (pieceColor) {
      .black => "assets/pieces-svg/queen-b.svg",
      .white => "assets/pieces-svg/queen-w.svg",
    };
  }

  @override
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <ChessMove>[];

    // Rooklike positions

    // Positions over column on right
    // In the worst case, the piece is on the left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over column on left
    // In the worst case, the piece is on the right of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subColumn(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over row on top
    // In the worst case, the piece is on the bottom of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over row on top
    // In the worst case, the piece is on the bottom of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //Bishoplike position

    // Positions over top right diagonal
    // In the worst case, the piece is on the bottom left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i)?.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over top left diagonal
    // In the worst case, the piece is on the bottom right of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subColumn(i)?.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over bottom right diagonal
    // In the worst case, the piece is on the top left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i)?.subRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    // Positions over the bottom left diagonal
    // In the worst case, the piece is on the top right of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.subColumn(i)?.subRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(
        RegularMove(oldPosition: piecePosition, newPosition: newTile),
      );
      // If it's an opposing piece it can capture but can't
      // go after that
      if (board.isEnemyPiece(newTile, pieceColor)) {
        break;
      }
    }

    return positions;
  }
}

class King extends Piece {
  King({required super.pieceColor});

  @override
  String get assetImagePath {
    return switch (pieceColor) {
      .black => "assets/pieces-svg/king-b.svg",
      .white => "assets/pieces-svg/king-w.svg",
    };
  }

  @override
  List<ChessMove> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <ChessMove>[];
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        // Exclude initial positions
        if (i == 0 && j == 0) continue;
        final newTile = piecePosition.addRow(i)?.addColumn(j);
        if (newTile != null && !board.isAlliedPiece(newTile, pieceColor)) {
          positions.add(
            RegularMove(oldPosition: piecePosition, newPosition: newTile),
          );
        }
      }
    }
    return positions;
  }
}
