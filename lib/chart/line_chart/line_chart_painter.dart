import 'dart:ui' as ui;

import 'package:fl_chart/chart/base/fl_axis_chart/fl_axis_chart_data.dart';
import 'package:fl_chart/chart/base/fl_axis_chart/fl_axis_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'line_chart_data.dart';

class LineChartPainter extends FlAxisChartPainter {
  final LineChartData data;

  Paint barPaint, belowBarPaint;

  LineChartPainter(
    this.data,
  ) : super(data) {
    barPaint = Paint()
      ..color = data.barData.barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.barData.barWidth;

    belowBarPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size viewSize) {
    if (data.spots.length == 0) {
      return;
    }
    super.paint(canvas, viewSize);

    Path barPath = _generateBarPath(viewSize);
    _drawBelowBar(canvas, viewSize, Path.from(barPath));
    _drawBar(canvas, viewSize, Path.from(barPath));
  }

  /*
  barPath Ends in Top Right
   */
  void _drawBelowBar(Canvas canvas, Size viewSize, Path barPath) {
    if (!data.belowBarData.show) {
      return;
    }

    Size chartViewSize = getChartUsableDrawSize(viewSize);

    // Line To Bottom Right
    double x = getPixelX(data.spots[data.spots.length - 1].x, chartViewSize);
    double y = chartViewSize.height - getTopOffsetDrawSize();
    barPath.lineTo(x, y);

    // Line To Bottom Left
    x = getPixelX(data.spots[0].x, chartViewSize);
    y = chartViewSize.height - getTopOffsetDrawSize();
    barPath.lineTo(x, y);

    // Line To Top Left
    x = getPixelX(data.spots[0].x, chartViewSize);
    y = getPixelY(data.spots[0].y, chartViewSize);
    barPath.lineTo(x, y);
    barPath.close();

    if (data.belowBarData.colors.length == 1) {
      belowBarPaint.color = data.belowBarData.colors[0];
      belowBarPaint.shader = null;
    } else {
      var from = data.belowBarData.from;
      var to = data.belowBarData.to;
      belowBarPaint.shader = ui.Gradient.linear(
        Offset(
          getLeftOffsetDrawSize() + (chartViewSize.width * from.dx),
          getTopOffsetDrawSize() + (chartViewSize.height * from.dy),
        ),
        Offset(
          getLeftOffsetDrawSize() + (chartViewSize.width * to.dx),
          getTopOffsetDrawSize() + (chartViewSize.height * to.dy),
        ),
        data.belowBarData.colors,
        data.belowBarData.colorStops,
      );
    }

    canvas.drawPath(barPath, belowBarPaint);
  }

  void _drawBar(Canvas canvas, Size viewSize, Path barPath) {
    if (!data.barData.show) {
      return;
    }
    canvas.drawPath(barPath, barPaint);
  }

  Path _generateBarPath(Size viewSize) {
    viewSize = getChartUsableDrawSize(viewSize);
    Path path = Path();
    int size = data.spots.length;
    path.reset();

    double lX = 0.0, lY = 0.0;

    double x = getPixelX(data.spots[0].x, viewSize);
    double y = getPixelY(data.spots[0].y, viewSize);
    path.moveTo(x, y);
    for (int i = 1; i < size; i++) {
      // CurrentSpot
      AxisSpot p = data.spots[i];
      double px = getPixelX(p.x, viewSize);
      double py = getPixelY(p.y, viewSize);

      // previous spot
      AxisSpot p0 = data.spots[i - 1];
      double p0x = getPixelX(p0.x, viewSize);
      double p0y = getPixelY(p0.y, viewSize);

      double x1 = p0x + lX;
      double y1 = p0y + lY;

      // next point
      AxisSpot p1 = data.spots[i + 1 < size ? i + 1 : i];
      double p1x = getPixelX(p1.x, viewSize);
      double p1y = getPixelY(p1.y, viewSize);

      double smoothness = data.barData.isCurved ? data.barData.curveSmoothness : 0.0;
      lX = ((p1x - p0x) / 2) * smoothness;
      lY = ((p1y - p0y) / 2) * smoothness;
      double x2 = px - lX;
      double y2 = py - lY;

      path.cubicTo(x1, y1, x2, y2, px, py);
    }

    return path;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
