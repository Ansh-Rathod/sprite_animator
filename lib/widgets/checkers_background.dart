import 'package:fluent_ui/fluent_ui.dart';

/// A checkerboard pattern widget, like the one used to indicate transparency
/// in image editors (e.g. Photoshop, Figma).
///
/// Use this as a background behind images with alpha channels.
class CheckersBackground extends StatelessWidget {
  const CheckersBackground({
    super.key,
    this.squareSize = 6.0,
    this.lightColor = const Color.fromARGB(255, 162, 162, 162),
    this.darkColor = const Color.fromARGB(255, 125, 125, 125),
    this.child,
  });

  /// Size of each individual square in the grid.
  final double squareSize;

  /// Color of the light squares.
  final Color lightColor;

  /// Color of the dark squares.
  final Color darkColor;

  /// Optional child widget to render on top of the checkerboard.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: CustomPaint(
        painter: _CheckersPainter(
          squareSize: squareSize,
          lightColor: lightColor,
          darkColor: darkColor,
        ),
        child: child,
      ),
    );
  }
}

class _CheckersPainter extends CustomPainter {
  _CheckersPainter({
    required this.squareSize,
    required this.lightColor,
    required this.darkColor,
  });

  final double squareSize;
  final Color lightColor;
  final Color darkColor;

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()..color = lightColor;
    final darkPaint = Paint()..color = darkColor;

    // Clip to widget bounds so edge squares don't overflow.
    canvas.clipRect(Offset.zero & size);

    // Fill background with light color first.
    canvas.drawRect(Offset.zero & size, lightPaint);

    // Draw dark squares in a checkerboard pattern.
    final cols = (size.width / squareSize).ceil();
    final rows = (size.height / squareSize).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        if ((row + col).isOdd) {
          final rect = Rect.fromLTWH(
            col * squareSize,
            row * squareSize,
            squareSize,
            squareSize,
          );
          canvas.drawRect(rect, darkPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_CheckersPainter oldDelegate) {
    return oldDelegate.squareSize != squareSize ||
        oldDelegate.lightColor != lightColor ||
        oldDelegate.darkColor != darkColor;
  }
}
