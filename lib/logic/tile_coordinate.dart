class TileCoordinate {
  final String column;
  final int row;

  static bool isRowValid(int rowNumber) => rowNumber >= 1 && rowNumber <= 8;
  static bool isColumnNumberValid(int columnNumber) =>
      columnNumber >= 0 && columnNumber <= 7;
  static bool isColumnValid(String column) {
    final cToLower = column.toLowerCase();
    return cToLower.codeUnitAt(0) >= "a".codeUnitAt(0) &&
        cToLower.codeUnitAt(0) <= "h".codeUnitAt(0);
  }

  factory TileCoordinate({required String column, required int row}) {
    if (!isColumnValid(column)) {
      throw ArgumentError(
        "Cannot get TileCoordinate from : \"$column$row\" , column must be a letter between a & h",
      );
    }
    if (!isRowValid(row)) {
      throw ArgumentError(
        "Cannot get TileCoordinate from : \"$column$row\" , row must be a int between 1 & 8",
      );
    }
    return TileCoordinate._unchecked(column: column.toLowerCase(), row: row);
  }

  // Be carefull, there is no arguments checking on this one, this can break the app 
  // if the provided arguments don't respect the constraints.
  const TileCoordinate._unchecked({required this.column, required this.row});

  @override
  bool operator ==(Object other) {
    if (other is! TileCoordinate) return false;
    return other.column == column && other.row == row;
  }

  @override
  int get hashCode => Object.hash(column, row);

  @override
  String toString() => "$column$row";

  TileCoordinate? addRow(int toAdd) {
    final newRow = row + toAdd;
    if (!isRowValid(newRow)) return null;
    return TileCoordinate(column: column, row: newRow);
  }

  TileCoordinate? subRow(int toSub) {
    final newRow = row - toSub;
    if (!isRowValid(newRow)) return null;
    return TileCoordinate(column: column, row: newRow);
  }

  TileCoordinate? addColumn(int toAdd) {
    final newColumnInt = columnLetterToInt() + toAdd;
    if (!isColumnNumberValid(newColumnInt)) return null;
    return TileCoordinate(column: intToColumnLetter(newColumnInt), row: row);
  }

  TileCoordinate? subColumn(int toSub) {
    final newColumnInt = columnLetterToInt() - toSub;
    if (!isColumnNumberValid(newColumnInt)) return null;
    return TileCoordinate(column: intToColumnLetter(newColumnInt), row: row);
  }

  int toChessTileIndex() => (row - 1) * 8 + columnLetterToInt();

  static TileCoordinate fromChessTileIndex(int index) {
    final row = (index ~/ 8) + 1;
    final column = TileCoordinate.intToColumnLetter(index % 8);
    return TileCoordinate(column: column, row: row);
  }

  // From 0 to 7
  int columnLetterToInt() => column.codeUnitAt(0) - "a".codeUnitAt(0);

  // From "a" to "h"
  static String intToColumnLetter(int column) {
    if (!isColumnNumberValid(column)) {
      throw ArgumentError("Column number should be between 0 and 7 included");
    }
    return String.fromCharCode("a".codeUnitAt(0) + column);
  }
}
