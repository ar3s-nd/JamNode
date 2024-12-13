import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    const segmentWidth = 3.0;
    const gap = 2.0;
    final segments = (width / (segmentWidth + gap)).floor();

    for (var i = 0; i < segments; i++) {
      final x = i * (segmentWidth + gap);
      final normalizedHeight = _generateRandomHeight(height);
      final startY = (height - normalizedHeight) / 2;
      final endY = startY + normalizedHeight;

      canvas.drawLine(
        Offset(x, startY),
        Offset(x, endY),
        paint,
      );
    }
  }

  double _generateRandomHeight(double maxHeight) {
    // This is a simplified version - you would want to use actual audio data
    return maxHeight * (0.3 + (DateTime.now().millisecond % 7) / 10);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
