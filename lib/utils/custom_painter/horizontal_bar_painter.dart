import 'package:flutter/material.dart';

class HorizontalBarPainter extends CustomPainter {
  final double percentage;
  final Color barColor;
  final Color backgroundColor;

  HorizontalBarPainter({
    required this.percentage,
    required this.barColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Paint for the background track
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    // Paint for the filled value
    final fillPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    // 1. Draw the background track across the full width
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2), // Gives rounded corners
    );
    canvas.drawRRect(bgRect, bgPaint);

    // 2. Draw the filled bar based on the percentage
    if (percentage > 0) {
      final fillWidth = size.width * percentage;
      final fillRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, fillWidth, size.height),
        Radius.circular(size.height / 2),
      );
      canvas.drawRRect(fillRect, fillPaint);
    }
  }

  @override
  bool shouldRepaint(covariant HorizontalBarPainter oldDelegate) {
    // Only redraw if the data or colors actually change
    return oldDelegate.percentage != percentage ||
        oldDelegate.barColor != barColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
