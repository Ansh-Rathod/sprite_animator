import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fluent_ui/fluent_ui.dart';
import 'package:letstry/models/spritesheet_slice.dart';

class SpritesheetPreview extends StatefulWidget {
  final String imagePath;
  final ui.Size imageSize;
  final SpritesheetSlice slice;
  final List<({int col, int row})> selection;
  final ValueChanged<({int col, int row})> onCellTapped;

  const SpritesheetPreview({
    super.key,
    required this.imagePath,
    required this.imageSize,
    required this.slice,
    required this.selection,
    required this.onCellTapped,
  });

  @override
  State<SpritesheetPreview> createState() => SpritesheetPreviewState();
}

class SpritesheetPreviewState extends State<SpritesheetPreview> {
  final TransformationController _transformController =
      TransformationController();
  double _scale = 1.0;

  double get scale => _scale;

  void zoomIn() => _setScale(_scale * 1.25);
  void zoomOut() => _setScale(_scale / 1.25);

  void fitToView(Size viewportSize) {
    if (widget.imageSize.width <= 0 || widget.imageSize.height <= 0) return;
    final fitScale = math.min(
      viewportSize.width / widget.imageSize.width,
      viewportSize.height / widget.imageSize.height,
    );
    _setScale(fitScale.clamp(0.01, 10.0));
    _transformController.value = Matrix4.identity();
  }

  void _setScale(double newScale) {
    setState(() {
      _scale = newScale.clamp(0.01, 10.0);
    });
  }

  int? _selectionIndex(int col, int row) {
    for (var i = 0; i < widget.selection.length; i++) {
      final cell = widget.selection[i];
      if (cell.col == col && cell.row == row) return i;
    }
    return null;
  }

  void _handleTapDown(TapDownDetails details, Size displaySize) {
    final local = details.localPosition;
    final imageX = local.dx / _scale;
    final imageY = local.dy / _scale;

    if (imageX < 0 ||
        imageY < 0 ||
        imageX > widget.imageSize.width ||
        imageY > widget.imageSize.height) {
      return;
    }

    final cell = widget.slice.cellAtImagePoint(imageX, imageY);
    if (cell != null) {
      widget.onCellTapped((col: cell.col, row: cell.row));
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FluentTheme.of(context);
    final displayW = widget.imageSize.width * _scale;
    final displayH = widget.imageSize.height * _scale;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            // Positioned(
            //   left: 12,
            //   top: 12,
            //   child: _ZoomToolbar(
            //     scale: _scale,
            //     onZoomIn: zoomIn,
            //     onZoomOut: zoomOut,
            //     onFit: () => fitToView(constraints.biggest),
            //   ),
            // ),
            InteractiveViewer(
              transformationController: _transformController,
              minScale: 0.05,
              maxScale: 10,
              constrained: false,
              alignment: Alignment.center,
              boundaryMargin: const EdgeInsets.all(500),
              child: GestureDetector(
                onTapDown: (details) =>
                    _handleTapDown(details, Size(displayW, displayH)),
                child: SizedBox(
                  width: displayW,
                  height: displayH,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Image.file(
                        File(widget.imagePath),
                        width: displayW,
                        height: displayH,
                        fit: BoxFit.fill,
                      ),
                      CustomPaint(
                        size: Size(displayW, displayH),
                        painter: _GridPainter(
                          slice: widget.slice,
                          scale: _scale,
                          gridColor: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      ..._buildSelectionOverlays(theme),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildSelectionOverlays(FluentThemeData theme) {
    final overlays = <Widget>[];

    for (var col = 0; col < widget.slice.columns; col++) {
      for (var row = 0; row < widget.slice.rows; row++) {
        final index = _selectionIndex(col, row);
        if (index == null) continue;

        final rect = widget.slice.cellRect(col, row);
        overlays.add(
          Positioned(
            left: rect.left * _scale,
            top: rect.top * _scale,
            width: rect.width * _scale,
            height: rect.height * _scale,
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: theme.accentColor, width: 2),
              ),
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: theme.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    '$index',
                    style: theme.typography.caption!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    return overlays;
  }
}

// class _ZoomToolbar extends StatelessWidget {
//   final double scale;
//   final VoidCallback onZoomIn;
//   final VoidCallback onZoomOut;
//   final VoidCallback onFit;

//   const _ZoomToolbar({
//     required this.scale,
//     required this.onZoomIn,
//     required this.onZoomOut,
//     required this.onFit,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = FluentTheme.of(context);
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//       decoration: BoxDecoration(
//         color: theme.cardColor.withValues(alpha: 0.9),
//         borderRadius: BorderRadius.circular(6),
//         border: Border.all(color: theme.resources.cardStrokeColorDefault),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           IconButton(
//             icon: const Icon(FluentIcons.remove, size: 14),
//             onPressed: onZoomOut,
//           ),
//           SizedBox(
//             width: 52,
//             child: Text(
//               '${(scale * 100).toStringAsFixed(1)}%',
//               textAlign: TextAlign.center,
//               style: theme.typography.caption,
//             ),
//           ),
//           IconButton(
//             icon: const Icon(FluentIcons.add, size: 14),
//             onPressed: onZoomIn,
//           ),
//           Tooltip(
//             message: 'Fit to view',
//             child: IconButton(
//               icon: const Icon(FluentIcons.fit_page, size: 14),
//               onPressed: onFit,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _GridPainter extends CustomPainter {
  final SpritesheetSlice slice;
  final double scale;
  final Color gridColor;

  _GridPainter({
    required this.slice,
    required this.scale,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = gridColor
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (var col = 0; col <= slice.columns; col++) {
      final x =
          (slice.offset.dx +
              col * slice.cellSize.width +
              col * slice.separation.width) *
          scale;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var row = 0; row <= slice.rows; row++) {
      final y =
          (slice.offset.dy +
              row * slice.cellSize.height +
              row * slice.separation.height) *
          scale;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) {
    return oldDelegate.slice != slice || oldDelegate.scale != scale;
  }
}
