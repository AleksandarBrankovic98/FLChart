import 'dart:ui' as ui;

import 'package:fl_chart/chart/base/fl_axis_chart/fl_axis_chart_data.dart';
import 'package:fl_chart/chart/base/fl_axis_chart/fl_axis_chart_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'line_chart_data.dart';

class LineChartPainter extends FlAxisChartPainter {
  final LineChartData data;

  Paint barPaint, belowBarPaint, dotPaint;

  LineChartPainter(
    this.data,
  ) : super(data) {
    barPaint = Paint()
      ..color = data.barData.barColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = data.barData.barWidth;

    belowBarPaint = Paint()..style = PaintingStyle.fill;

    dotPaint = Paint()
      ..color = data.dotData.dotColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size viewSize) {
    super.paint(canvas, viewSize);
    if (data.spots.length == 0) {
      return;
    }

    Path barPath = _generateBarPath(viewSize);
    drawBelowBar(canvas, viewSize, barPath);
    drawBar(canvas, viewSize, barPath);
    drawTitles(canvas, viewSize);
    drawDots(canvas, viewSize);
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
      FlSpot p = data.spots[i];
      double px = getPixelX(p.x, viewSize);
      double py = getPixelY(p.y, viewSize);

      // previous spot
      FlSpot p0 = data.spots[i - 1];
      double p0x = getPixelX(p0.x, viewSize);
      double p0y = getPixelY(p0.y, viewSize);

      double x1 = p0x + lX;
      double y1 = p0y + lY;

      // next point
      FlSpot p1 = data.spots[i + 1 < size ? i + 1 : i];
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

  /*
  barPath Ends in Top Right
   */
  void drawBelowBar(Canvas canvas, Size viewSize, Path barPath) {
    if (!data.belowBarData.show) {
      return;
    }

    var belowBarPath = Path.from(barPath);

    Size chartViewSize = getChartUsableDrawSize(viewSize);

    // Line To Bottom Right
    double x = getPixelX(data.spots[data.spots.length - 1].x, chartViewSize);
    double y = chartViewSize.height - getTopOffsetDrawSize();
    belowBarPath.lineTo(x, y);

    // Line To Bottom Left
    x = getPixelX(data.spots[0].x, chartViewSize);
    y = chartViewSize.height - getTopOffsetDrawSize();
    belowBarPath.lineTo(x, y);

    // Line To Top Left
    x = getPixelX(data.spots[0].x, chartViewSize);
    y = getPixelY(data.spots[0].y, chartViewSize);
    belowBarPath.lineTo(x, y);
    belowBarPath.close();

    if (data.belowBarData.colors.length == 1) {
      belowBarPaint.color = data.belowBarData.colors[0];
      belowBarPaint.shader = null;
    } else {
      var from = data.belowBarData.gradientFrom;
      var to = data.belowBarData.gradientTo;
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
        data.belowBarData.gradientColorStops,
      );
    }

    canvas.drawPath(belowBarPath, belowBarPaint);
  }

  void drawBar(Canvas canvas, Size viewSize, Path barPath) {
    if (!data.barData.show) {
      return;
    }
    canvas.drawPath(barPath, barPaint);
  }

  void drawTitles(Canvas canvas, Size viewSize) {
    if (!data.titlesData.show) {
      return;
    }
    viewSize = getChartUsableDrawSize(viewSize);

    // Vertical Titles
    if (data.titlesData.showVerticalTitles) {
      int verticalCounter = 0;
      while (data.gridData.verticalInterval * verticalCounter <= data.maxY) {
        double x = 0 + getLeftOffsetDrawSize();
        double y = getPixelY(data.gridData.verticalInterval * verticalCounter, viewSize) +
            getTopOffsetDrawSize();

        String text =
            data.titlesData.getVerticalTitles(data.gridData.verticalInterval * verticalCounter);

        TextSpan span = new TextSpan(style: data.titlesData.verticalTitlesTextStyle, text: text);
        TextPainter tp = new TextPainter(
            text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout(maxWidth: getExtraNeededHorizontalSpace());
        x -= tp.width + data.titlesData.verticalTitleMargin;
        y -= (tp.height / 2);
        tp.paint(canvas, new Offset(x, y));

        verticalCounter++;
      }
    }

    // Horizontal titles
    if (data.titlesData.showHorizontalTitles) {
      int horizontalCounter = 0;
      while (data.gridData.horizontalInterval * horizontalCounter <= data.maxX) {
        double x = getPixelX(data.gridData.horizontalInterval * horizontalCounter, viewSize);
        double y = viewSize.height + getTopOffsetDrawSize();

        String text = data.titlesData
            .getHorizontalTitles(data.gridData.horizontalInterval * horizontalCounter);

        TextSpan span = new TextSpan(style: data.titlesData.horizontalTitlesTextStyle, text: text);
        TextPainter tp = new TextPainter(
            text: span, textAlign: TextAlign.center, textDirection: TextDirection.ltr);
        tp.layout();

        x -= (tp.width / 2);
        y += data.titlesData.horizontalTitleMargin;

        tp.paint(canvas, Offset(x, y));

        horizontalCounter++;
      }
    }
  }

  void drawDots(Canvas canvas, Size viewSize) {
    if (!data.dotData.show) {
      return;
    }
    viewSize = getChartUsableDrawSize(viewSize);
    data.spots.forEach((spot) {
      if (data.dotData.checkToShowDot(spot)) {
        double x = getPixelX(spot.x, viewSize);
        double y = getPixelY(spot.y, viewSize);
        canvas.drawCircle(Offset(x, y), data.dotData.dotSize, dotPaint);
      }
    });
  }

  @override
  double getExtraNeededHorizontalSpace() {
    double parentNeeded = super.getExtraNeededHorizontalSpace();
    if (data.titlesData.show && data.titlesData.showVerticalTitles) {
      return parentNeeded +
        data.titlesData.verticalTitlesReservedWidth +
        data.titlesData.verticalTitleMargin;
    }
    return parentNeeded;
  }

  @override
  double getExtraNeededVerticalSpace() {
    double parentNeeded = super.getExtraNeededVerticalSpace();
    if (data.titlesData.show && data.titlesData.showHorizontalTitles) {
      return parentNeeded +
        data.titlesData.horizontalTitlesReservedHeight +
        data.titlesData.horizontalTitleMargin;
    }
    return parentNeeded;
  }

  double getLeftOffsetDrawSize() {
    double parentNeeded = super.getLeftOffsetDrawSize();
    if (data.titlesData.show && data.titlesData.showVerticalTitles) {
      return parentNeeded +
        data.titlesData.verticalTitlesReservedWidth +
        data.titlesData.verticalTitleMargin;
    }
    return parentNeeded;
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}