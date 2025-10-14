import 'dart:math';
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final bool isPaused;

  WaveformPainter({
    required this.waveformData,
    required this.color,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) {
      _drawPlaceholder(canvas, size);
      return;
    }

    final paint = Paint()
      ..color = isPaused ? color.withOpacity(0.5) : color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final middle = size.height / 2;
    final spacing = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final x = i * spacing;
      final amplitude = waveformData[i] * middle * 0.8;

      if (i == 0) {
        path.moveTo(x, middle);
      }

      // Draw symmetric waveform
      final y1 = middle - amplitude;
      final y2 = middle + amplitude;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }

    // Draw progress line if recording is active
    if (!isPaused && waveformData.isNotEmpty) {
      final progressPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke;

      final progressX = (waveformData.length - 1) * spacing;
      canvas.drawLine(
        Offset(progressX, 0),
        Offset(progressX, size.height),
        progressPaint,
      );
    }
  }

  void _drawPlaceholder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final middle = size.height / 2;
    final random = Random();

    for (double x = 0; x < size.width; x += 4) {
      final amplitude = random.nextDouble() * 30;
      canvas.drawLine(
        Offset(x, middle - amplitude),
        Offset(x, middle + amplitude),
        paint,
      );
    }

    // Draw instruction text in the middle
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Mulai rekaman untuk melihat waveform',
        style: TextStyle(color: Colors.white54, fontSize: 14),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.isPaused != isPaused;
  }
}
