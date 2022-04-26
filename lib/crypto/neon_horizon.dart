import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Widget that paints an animated neon-light horizon.
class NeonHorizon extends StatefulWidget {
  const NeonHorizon({
    Key? key,
    required this.color,
    this.animate = true,
  }) : super(key: key);

  /// The color of the neon lines and highlights.
  final Color color;

  /// Whether to animate the horizon lines.
  final bool animate;

  @override
  _NeonHorizonState createState() => _NeonHorizonState();
}

class _NeonHorizonState extends State<NeonHorizon> with SingleTickerProviderStateMixin {
  late Ticker _ticker;

  double _distancePercent = 0.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsedTime) {
    setState(() {
      _distancePercent = elapsedTime.inMilliseconds / const Duration(seconds: 5).inMilliseconds;
      _distancePercent = _distancePercent > 1.0 ? _distancePercent - _distancePercent.floor() : _distancePercent;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ShaderMask(
        shaderCallback: (rect) {
          return LinearGradient(
            colors: [
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.7),
              Colors.white.withOpacity(0.7),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [
              0.1,
              0.4,
              1.0,
            ],
          ).createShader(rect);
        },
        child: CustomPaint(
          painter: _NeonHorizonPainter(
            distancePercent: _distancePercent,
            lineColor: widget.color,
          ),
        ),
      ),
    );
  }
}

/// Paints a neon-line horizon.
class _NeonHorizonPainter extends CustomPainter {
  _NeonHorizonPainter({
    required this.distancePercent,
    required Color lineColor,
  })  : _backgroundPaint = Paint(),
        _linePaint = Paint()..color = lineColor;

  /// Distance traveled across the plane, with 100% meaning
  /// that a horizontal line at the nearest edge of the plane
  /// has traveled to the farthest edge of the plane.
  final double distancePercent;

  final Paint _backgroundPaint;
  final Paint _linePaint;

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);

    final centerX = size.width / 2;
    const spacing = 35.0;
    double deltaX = spacing;

    _drawVerticalLine(canvas, size, centerX, centerX);
    while (centerX - deltaX >= 0) {
      _drawVerticalLine(canvas, size, centerX - deltaX, centerX - (2.5 * deltaX));
      _drawVerticalLine(canvas, size, centerX + deltaX, centerX + (2.5 * deltaX));

      deltaX += spacing;
    }

    final baseLineY = _horizontalLineAtTime(size, distancePercent);
    _drawHorizontalLine(canvas, size, baseLineY);

    double t = distancePercent + 0.1;
    while (_horizontalLineAtTime(size, t) > 0) {
      final y = _horizontalLineAtTime(size, t);
      _drawHorizontalLine(canvas, size, y);
      t += 0.1;
    }

    t = distancePercent - 0.1;
    while (_horizontalLineAtTime(size, t) < size.height) {
      final y = _horizontalLineAtTime(size, t);
      _drawHorizontalLine(canvas, size, y);
      t -= 0.1;
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    _backgroundPaint.shader = ui.Gradient.linear(
      Offset.zero,
      Offset(0, size.height),
      [
        _linePaint.color.withOpacity(0.15),
        _linePaint.color.withOpacity(0.4),
      ],
    );

    canvas.drawRect(Offset.zero & size, _backgroundPaint);
  }

  double _horizontalLineAtTime(Size size, double t) {
    return (1.5 * size.height) - ((1.5 * size.height) * sqrt(t));
  }

  void _drawHorizontalLine(Canvas canvas, Size size, double y) {
    final linePath = Path()
      ..moveTo(0, y)
      ..lineTo(size.width, y)
      ..lineTo(size.width, y + 2)
      ..lineTo(0, y + 2)
      ..close();

    canvas.drawPath(linePath, _linePaint);
  }

  void _drawVerticalLine(Canvas canvas, Size size, double topX, double bottomX) {
    final linePath = Path()
      ..moveTo(bottomX, size.height)
      ..lineTo(topX, 0)
      ..lineTo(topX + 2, 0)
      ..lineTo(bottomX + 2, size.height)
      ..close();

    canvas.drawPath(linePath, _linePaint);
  }

  @override
  bool shouldRepaint(_NeonHorizonPainter oldDelegate) {
    return distancePercent != oldDelegate.distancePercent;
  }
}
