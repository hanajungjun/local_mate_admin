import 'package:flutter/material.dart';

class MiniSparkline extends StatelessWidget {
  final List<int> values;
  final Color color;

  const MiniSparkline({
    super.key,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (values.length < 2) {
      return const SizedBox(width: 90, height: 36);
    }

    return SizedBox(
      width: 90,
      height: 36,
      child: CustomPaint(
        painter: _SparklinePainter(values, color),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color color;

  _SparklinePainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minVal = values.reduce((a, b) => a < b ? a : b).toDouble();
    final range = (maxVal - minVal) == 0 ? 1 : (maxVal - minVal);

    final path = Path();

    for (int i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1));
      final y = size.height - ((values[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
