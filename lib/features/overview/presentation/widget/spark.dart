import 'dart:math' as math;

import 'package:auren_connect/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class Spark extends StatelessWidget {
  const Spark(this.values, this.color, {super.key, this.height = 44});
  final List<double> values;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: CustomPaint(
      painter: LinePainter(series: [values], colors: [color], zeroBased: false),
    ),
  );
}

class LinePainter extends CustomPainter {
  LinePainter({
    required this.series,
    required this.colors,
    this.zeroBased = true,
  }) : grid = false;
  final List<List<double>> series;
  final List<Color> colors;
  final bool grid;
  final bool zeroBased;

  @override
  void paint(Canvas canvas, Size size) {
    final all = series.expand((e) => e);
    final maxV = all.reduce(math.max);
    final minV = zeroBased ? 0.0 : all.reduce(math.min);
    final range = (maxV - minV) == 0 ? 1 : (maxV - minV);
    const pad = 6.0;

    if (grid) {
      final gp = Paint()
        ..color = AppColors.border.withValues(alpha: .7)
        ..strokeWidth = 1;
      for (var i = 0; i <= 4; i++) {
        final y = size.height / 4 * i;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
      }
    }

    for (var s = 0; s < series.length; s++) {
      final data = series[s];
      final pts = [
        for (var i = 0; i < data.length; i++)
          Offset(
            size.width / (data.length - 1) * i,
            pad + (size.height - pad * 2) * (1 - (data[i] - minV) / range),
          ),
      ];
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 0; i < pts.length - 1; i++) {
        final mx = (pts[i].dx + pts[i + 1].dx) / 2;
        path.cubicTo(
          mx,
          pts[i].dy,
          mx,
          pts[i + 1].dy,
          pts[i + 1].dx,
          pts[i + 1].dy,
        );
      }
      final fill = Path.from(path)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height)
        ..close();
      canvas.drawPath(
        fill,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors[s].withValues(alpha: s == 0 ? .28 : .12),
              colors[s].withValues(alpha: 0),
            ],
          ).createShader(Offset.zero & size),
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = colors[s]
          ..style = PaintingStyle.stroke
          ..strokeWidth = grid ? 2.6 : 2
          ..strokeCap = StrokeCap.round,
      );
      if (grid) {
        canvas.drawCircle(pts.last, 5, Paint()..color = AppColors.background);
        canvas.drawCircle(
          pts.last,
          5,
          Paint()
            ..color = colors[s]
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.4,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant LinePainter old) => true;
}
