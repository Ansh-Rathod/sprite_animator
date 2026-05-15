import 'dart:ui';

class SpritesheetSlice {
  int columns;
  int rows;
  Size cellSize;
  Size separation;
  Offset offset;

  SpritesheetSlice({
    this.columns = 1,
    this.rows = 1,
    Size? cellSize,
    Size? separation,
    Offset? offset,
  })  : cellSize = cellSize ?? const Size(256, 256),
        separation = separation ?? Size.zero,
        offset = offset ?? Offset.zero;

  double get _stepX => cellSize.width + separation.width;
  double get _stepY => cellSize.height + separation.height;

  Rect cellRect(int col, int row) {
    return Rect.fromLTWH(
      offset.dx + col * _stepX,
      offset.dy + row * _stepY,
      cellSize.width,
      cellSize.height,
    );
  }

  bool isValidCell(int col, int row) {
    return col >= 0 && col < columns && row >= 0 && row < rows;
  }

  ({int col, int row})? cellAtImagePoint(double x, double y) {
    if (x < offset.dx || y < offset.dy) return null;
    if (_stepX <= 0 || _stepY <= 0) return null;

    final col = ((x - offset.dx) / _stepX).floor();
    final row = ((y - offset.dy) / _stepY).floor();
    if (!isValidCell(col, row)) return null;

    final rect = cellRect(col, row);
    if (!rect.contains(Offset(x, y))) return null;
    return (col: col, row: row);
  }

  SpritesheetSlice copyWith({
    int? columns,
    int? rows,
    Size? cellSize,
    Size? separation,
    Offset? offset,
  }) {
    return SpritesheetSlice(
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
      cellSize: cellSize ?? this.cellSize,
      separation: separation ?? this.separation,
      offset: offset ?? this.offset,
    );
  }
}
