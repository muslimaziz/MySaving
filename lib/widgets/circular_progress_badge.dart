import 'package:flutter/material.dart';

/// Badge progres bulatan dengan angka persen di tengahnya.
///
/// `progress` bernilai 0.0 hingga 1.0.
class CircularProgressBadge extends StatelessWidget {
  final double progress;
  final double size;
  final double strokeWidth;
  final double? fontSize;
  final Color color;
  final Color backgroundColor;

  const CircularProgressBadge({
    super.key,
    required this.progress,
    required this.color,
    this.size = 48,
    this.strokeWidth = 4,
    this.fontSize,
    this.backgroundColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: clamped,
              strokeWidth: strokeWidth,
              backgroundColor: backgroundColor,
              color: color,
            ),
          ),
          Text(
            '${(clamped * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: fontSize ?? size * 0.25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
