import 'package:chess/logic/piece.dart';
import 'package:chess/logic/side_color.dart';
import 'package:chess/ui/chess_tile_widget.dart';
import 'package:flutter/material.dart';

class ChessBoardWidget extends StatelessWidget {
  final SideColor orientationColor;
  final void Function(int tappedIndex)? onTapCallback;
  final void Function(int panIndex)? onPanStartCallback;
  final void Function(DragUpdateDetails)? onPanUpdateCallback;
  final void Function(DragEndDetails)? onPanEndCallback;
  final Iterable<Piece?> tiles;
  final List<int>? hiddenTilesIndexes;
  final List<int>? lightedUpTilesIndexes;
  final List<int>? lastTilesIndexes;
  final int? selectedTileIndex;
  const ChessBoardWidget({
    super.key,
    required this.orientationColor,
    this.onTapCallback,
    required this.tiles,
    this.hiddenTilesIndexes,
    this.lightedUpTilesIndexes,
    required this.selectedTileIndex,
    this.lastTilesIndexes,
    this.onPanStartCallback, this.onPanUpdateCallback, this.onPanEndCallback,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      reverse: orientationColor == .white,
      crossAxisCount: 8,
      physics: NeverScrollableScrollPhysics(),
      children: tiles.indexed.map((ie) {
        return GestureDetector(
          onPanStart: (_) => onPanStartCallback?.call(ie.$1),
          onTap: () => onTapCallback?.call(ie.$1),
          onPanUpdate: onPanUpdateCallback ,
          onPanEnd: onPanEndCallback,
          child: ChessTileWidget(
            tileIndex: ie.$1,
            hidePiece: hiddenTilesIndexes?.contains(ie.$1) ?? false,
            isSelected: selectedTileIndex == ie.$1,
            isLightedUp: lightedUpTilesIndexes?.contains(ie.$1) ?? false,
            isLastMove: lastTilesIndexes?.contains(ie.$1) ?? false,
            piece: ie.$2,
          ),
        );
      }).toList(),
    );
  }
}
