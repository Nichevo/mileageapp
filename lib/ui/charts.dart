/// Small chart widgets shared by the cost pages.
library;

import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'insights_page.dart' show ChartScale;

class StackPart {
  final String name;
  final Color color;
  final List<double> values; // one per bar
  const StackPart(this.name, this.color, this.values);
}

Widget chartLegend(List<(String, Color)> items) => Wrap(spacing: 12, runSpacing: 2, children: [
      for (final (name, c) in items)
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 4),
          Text(name, style: const TextStyle(fontSize: 11)),
        ]),
    ]);

/// Stacked bars in real units (dollars), a scale on the left, a legend
/// below, scrolling sideways when there are many bars. Tap a bar for its
/// breakdown.
class StackedBars extends StatelessWidget {
  final List<String> labels, tips;
  final List<StackPart> parts;
  final String Function(double) fmt;
  const StackedBars({super.key, required this.labels, required this.tips, required this.parts, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final shown = parts.where((p) => p.values.any((v) => v > 0)).toList();
    final totals = [for (var i = 0; i < labels.length; i++) shown.fold(0.0, (a, p) => a + math.max(0, p.values[i]))];
    final maxV = totals.isEmpty ? 0.0 : totals.reduce(math.max);
    final scale = ChartScale.of(maxV <= 0 ? 1 : maxV);
    const labelStyle = TextStyle(fontSize: 10);
    final rotate = labels.any((l) => l.length > 3);
    final bottomH = rotate ? 46.0 : 20.0;
    return Column(children: [
      Expanded(
        child: LayoutBuilder(builder: (context, box) {
          const axisW = 44.0;
          final room = box.maxWidth - axisW;
          final width = math.max(room, labels.length * (rotate ? 22.0 : 16.0));
          final barW = (width / math.max(1, labels.length) * 0.6).clamp(3.0, 22.0);
          final plotH = box.maxHeight - bottomH;
          final chart = BarChart(BarChartData(
            minY: 0,
            maxY: scale.top,
            alignment: BarChartAlignment.spaceAround,
            gridData: FlGridData(
              drawVerticalLine: false,
              checkToShowHorizontalLine: (y) => scale.ticks.any((t) => (t.$2 - y).abs() < 1e-6),
              horizontalInterval: scale.top / 200,
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: bottomH,
                  getTitlesWidget: (v, m) {
                    final i = v.toInt();
                    if (i < 0 || i >= labels.length) return const SizedBox();
                    final text = Text(labels[i], style: labelStyle, maxLines: 1, softWrap: false);
                    return Padding(padding: const EdgeInsets.only(top: 4), child: rotate ? RotatedBox(quarterTurns: 3, child: text) : text);
                  },
                ),
              ),
            ),
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                getTooltipItem: (g, gi, rod, ri) => BarTooltipItem(
                  [
                    '${tips[g.x]}: ${fmt(totals[g.x])}',
                    for (final p in shown)
                      if (p.values[g.x] != 0) '${p.name} ${fmt(p.values[g.x])}',
                  ].join('\n'),
                  const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
            barGroups: [
              for (var i = 0; i < labels.length; i++)
                () {
                  var y = 0.0;
                  final items = <BarChartRodStackItem>[];
                  for (final p in shown) {
                    final v = math.max(0.0, p.values[i]);
                    if (v <= 0) continue;
                    items.add(BarChartRodStackItem(y, y + v, p.color));
                    y += v;
                  }
                  return BarChartGroupData(x: i, barRods: [
                    BarChartRodData(toY: y, width: barW, rodStackItems: items, color: Colors.transparent, borderRadius: BorderRadius.zero),
                  ]);
                }(),
            ],
          ));
          return Row(children: [
            SizedBox(
              width: axisW,
              height: box.maxHeight,
              child: Stack(children: [
                for (final (v, pos) in scale.ticks)
                  Positioned(
                    left: 0,
                    right: 6,
                    top: (plotH * (1 - pos / scale.top) - 7).clamp(0.0, plotH),
                    child: Text(scale.label(v), style: labelStyle, textAlign: TextAlign.right),
                  ),
              ]),
            ),
            Expanded(
              child: width <= room
                  ? chart
                  : SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: SizedBox(width: width, height: box.maxHeight, child: chart)),
            ),
          ]);
        }),
      ),
      const SizedBox(height: 4),
      chartLegend([for (final p in shown) (p.name, p.color)]),
    ]);
  }
}

/// A value over time: solid through known values, dashed where estimated,
/// with a dot on each known value.
class ValueLine extends StatelessWidget {
  final List<({DateTime at, double value})> known;
  final List<({DateTime at, double value})> estimated; // after the last known value
  final String Function(double) fmt;
  const ValueLine({super.key, required this.known, required this.estimated, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final all = [...known, ...estimated];
    if (all.isEmpty) return const SizedBox.shrink();
    final t0 = all.first.at;
    double x(DateTime d) => d.difference(t0).inDays / 365.25;
    final maxV = all.map((p) => p.value).reduce(math.max);
    final scale = ChartScale.of(maxV <= 0 ? 1 : maxV);
    final maxX = math.max(0.1, x(all.last.at));
    const labelStyle = TextStyle(fontSize: 10);
    return LineChart(LineChartData(
      minY: 0,
      maxY: scale.top,
      minX: 0,
      maxX: maxX,
      gridData: FlGridData(drawVerticalLine: false, horizontalInterval: scale.step),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(),
        rightTitles: const AxisTitles(),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, reservedSize: 44, interval: scale.step, getTitlesWidget: (v, m) => Text(scale.label(v), style: labelStyle)),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 20,
            interval: math.max(1, (maxX / 6).ceilToDouble()),
            getTitlesWidget: (v, m) => Text('${t0.year + v.round()}', style: labelStyle),
          ),
        ),
      ),
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (spots) => [
            for (final s in spots)
              LineTooltipItem('${(t0.year + s.x).toStringAsFixed(1)}: ${fmt(s.y)}', const TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
      lineBarsData: [
        if (known.isNotEmpty)
          LineChartBarData(
            spots: [for (final p in known) FlSpot(x(p.at), p.value)],
            color: cs.primary,
            barWidth: 2.5,
            dotData: const FlDotData(show: true),
          ),
        if (estimated.isNotEmpty)
          LineChartBarData(
            spots: [if (known.isNotEmpty) FlSpot(x(known.last.at), known.last.value), for (final p in estimated) FlSpot(x(p.at), p.value)],
            color: cs.primary.withValues(alpha: 0.6),
            barWidth: 2,
            dashArray: [6, 4],
            dotData: const FlDotData(show: false),
          ),
      ],
    ));
  }
}
