import 'dart:ui';

import 'package:fl_chart/chart/base/fl_axis_chart/fl_axis_chart_data.dart';
import 'package:fl_chart/chart/base/fl_chart/fl_chart_data.dart';
import 'package:flutter/material.dart';

class LineChartData extends FlAxisChartData {
  final LineChartBarData barData;
  final BelowBarData belowBarData;

  LineChartData({
    this.barData = const LineChartBarData(),
    this.belowBarData = const BelowBarData(),
    List<AxisSpot> spots,
    FlGridData gridData,
    FlTitlesData titlesData,
    FlBorderData borderData,
    AxisDotData dotData,
  }) : super(
    spots: spots,
    gridData: gridData,
    dotData: dotData,
    titlesData: titlesData,
    borderData: borderData,
  );

}

// Bar Data
class LineChartBarData {
  final bool show;

  final Color barColor;
  final double barWidth;
  final bool isCurved;
  final double curveSmoothness;

  const LineChartBarData({
    this.show = true,
    this.barColor = Colors.redAccent,
    this.barWidth = 2.0,
    this.isCurved = false,
    this.curveSmoothness = 0.35,
  });
}

// Below Bar Data
class BelowBarData {
  final bool show;

  final List<Color> colors;
  final Offset from;
  final Offset to;
  final List<double> colorStops;

  const BelowBarData({
    this.show = true,
    this.colors = const [Colors.blueGrey],
    this.from = const Offset(0, 0),
    this.to = const Offset(1, 0),
    this.colorStops = const [1.0],
  });
}