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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board);
  List<TileCoordinate> legalMoves(
    TileCoordinate piecePosition,
    ChessBoard board,
  ) {
    return moves(piecePosition, board).where((m) {
      // See if the move leads to a check
      final boardWithMove = board.copyWithMove(
        ChessMove(
          piece: this,
          oldPosition: piecePosition,
          newPosition: m,
        ),
      );

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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <TileCoordinate>[];
    // Tile in front
    final frontTile = switch (pieceColor) {
      .white => piecePosition.addRow(1)!,
      .black => piecePosition.subRow(1)!,
    };
    if (!board.isTileOccupied(frontTile)) {
      positions.add(frontTile);
    }

    // Two tile in front on the first move
    if (isInitTile(piecePosition)) {
      final twoTilesInFront = switch (pieceColor) {
        .white => piecePosition.addRow(2)!,
        .black => piecePosition.subRow(2)!,
      };
      // Cannot go if it's occupied
      if (!board.isTileOccupied(twoTilesInFront)) {
        positions.add(twoTilesInFront);
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
        positions.add(tile);
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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <TileCoordinate>[];
    // Positions over column on right
    // In the worst case, the piece is on the left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <TileCoordinate>[];

    // Top Right
    final topRightT = piecePosition.addRow(2)?.addColumn(1);
    final topRightB = piecePosition.addRow(1)?.addColumn(2);

    // if the Tile is not null and there is not an allied piece on it
    if (!(topRightT == null || board.isAlliedPiece(topRightT, pieceColor))) {
      positions.add(topRightT);
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(topRightB == null || board.isAlliedPiece(topRightB, pieceColor))) {
      positions.add(topRightB);
    }

    // Top left
    final topLeftT = piecePosition.addRow(2)?.subColumn(1);
    final topLeftB = piecePosition.addRow(1)?.subColumn(2);

    // if the Tile is not null and there is not an allied piece on it
    if (!(topLeftT == null || board.isAlliedPiece(topLeftT, pieceColor))) {
      positions.add(topLeftT);
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(topLeftB == null || board.isAlliedPiece(topLeftB, pieceColor))) {
      positions.add(topLeftB);
    }

    // Bottom left
    final bottomLeftT = piecePosition.subRow(1)?.subColumn(2);
    final bottomLeftB = piecePosition.subRow(2)?.subColumn(1);

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomLeftT == null ||
        board.isAlliedPiece(bottomLeftT, pieceColor))) {
      positions.add(bottomLeftT);
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomLeftB == null ||
        board.isAlliedPiece(bottomLeftB, pieceColor))) {
      positions.add(bottomLeftB);
    }

    // Bottom right
    final bottomRightT = piecePosition.subRow(1)?.addColumn(2);
    final bottomRightB = piecePosition.subRow(2)?.addColumn(1);

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomRightT == null ||
        board.isAlliedPiece(bottomRightT, pieceColor))) {
      positions.add(bottomRightT);
    }

    // if the Tile is not null and there is not an allied piece on it
    if (!(bottomRightB == null ||
        board.isAlliedPiece(bottomRightB, pieceColor))) {
      positions.add(bottomRightB);
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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <TileCoordinate>[];
    // Positions over top right diagonal
    // In the worst case, the piece is on the bottom left of the board
    for (int i = 1; i < 8; i++) {
      // Tile doesn't exist so we exit the loop
      // Or There is an allied piece on the tile
      final newTile = piecePosition.addColumn(i)?.addRow(i);
      if (newTile == null || board.isAlliedPiece(newTile, pieceColor)) {
        break;
      }

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <TileCoordinate>[];

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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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

      positions.add(newTile);
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
  List<TileCoordinate> moves(TileCoordinate piecePosition, ChessBoard board) {
    final positions = <TileCoordinate>[];
    for (int i = -1; i <= 1; i++) {
      for (int j = -1; j <= 1; j++) {
        // Exclude initial positions
        if (i == 0 && j == 0) continue;
        final newTile = piecePosition.addRow(i)?.addColumn(j);
        if (newTile != null && !board.isAlliedPiece(newTile, pieceColor)) {
          positions.add(newTile);
        }
      }
    }
    return positions;
  }
}
