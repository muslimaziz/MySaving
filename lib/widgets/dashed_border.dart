import 'package:flutter/material.dart';

/// Border putus-putus (dashed) melengkung — tidak tersedia
/// secara native di Flutter, digambar manual.
class DashedBorder extends StatelessWidget {
  final Widget child;
  final Color color;
  final double radius;
  final double dashWidth;
  final double gapWidth;
  final EdgeInsetsGeometry padding;

  const DashedBorder({
    super.key,
    required this.child,
    this.color = const Color(0xFFAEBDB7),
    this.radius = 22,
    this.dashWidth = 8,
    this.gapWidth = 8,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: color,
        radius: radius,
        dashWidth: dashWidth,
        gapWidth: gapWidth,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  final double dashWidth;
  final double gapWidth;

  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.dashWidth,
    required this.gapWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));

    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + gapWidth;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.radius != radius ||
      old.dashWidth != dashWidth ||
      old.gapWidth != gapWidth;
}
