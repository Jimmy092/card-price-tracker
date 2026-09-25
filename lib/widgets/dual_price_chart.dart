import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../data/database.dart';
import 'month_price_sparkline.dart';

final _axisDay = DateFormat.Md();
final _tooltipDay = DateFormat.yMMMd().add_Hm();

/// Last-month dual timeline: Cardmarket trend vs CardTrader best.
class DualPriceChart extends StatelessWidget {
  const DualPriceChart({
    super.key,
    required this.cmSnapshots,
    required this.ctSnapshots,
    this.latestCm,
  });

  final List<PriceSnapshot> cmSnapshots;
  final List<PriceSnapshot> ctSnapshots;
  final PriceSnapshot? latestCm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final series = MonthPriceSeries.fromSnapshots(
      cmSnapshots: cmSnapshots,
      ctSnapshots: ctSnapshots,
      latestCm: latestCm ?? (cmSnapshots.isEmpty ? null : cmSnapshots.last),
    );

    if (!series.hasAny) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No price history yet.\nSync this card to start the 30-day timeline.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    final start = series.windowStart;
    final end = start.add(MonthPriceSparkline.window);
    final spanMs = series.spanMs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _LegendDot(color: AppTheme.cmAmber, label: 'CM trend (30d)'),
            _LegendDot(color: AppTheme.ctTeal, label: 'CT best (30d)'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${_axisDay.format(start)} → ${_axisDay.format(end)}'
          '${series.cmSlopePct == null && series.ctSlopePct == null ? '' : ' · '}'
          '${[
            if (series.cmSlopePct != null)
              'CM ${series.cmSlopePct! >= 0 ? '+' : ''}${series.cmSlopePct!.toStringAsFixed(1)}%',
            if (series.ctSlopePct != null)
              'CT ${series.ctSlopePct! >= 0 ? '+' : ''}${series.ctSlopePct!.toStringAsFixed(1)}%',
          ].join(' · ')}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: spanMs,
              minY: series.minY,
              maxY: series.maxY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.min || value == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return Text(
                        '€${value.toStringAsFixed(value >= 10 ? 0 : 2)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: spanMs / 3,
                    getTitlesWidget: (value, meta) {
                      final at = start.add(
                        Duration(milliseconds: value.round()),
                      );
                      if (value <= meta.min + spanMs * 0.02 ||
                          value >= meta.max - spanMs * 0.02) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          _axisDay.format(at),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                handleBuiltInTouches: true,
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xFF1A2438),
                  tooltipBorder: BorderSide(
                    color: Colors.white.withValues(alpha: 0.12),
                  ),
                  getTooltipItems: (touched) {
                    return [
                      for (final t in touched)
                        LineTooltipItem(
                          '${t.bar.color == AppTheme.cmAmber ? 'CM' : 'CT'}'
                          '  €${t.y.toStringAsFixed(2)}\n'
                          '${_tooltipDay.format(start.add(Duration(milliseconds: t.x.round())))}',
                          TextStyle(
                            color: t.bar.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                    ];
                  },
                ),
              ),
              lineBarsData: [
                if (series.cmSpots.isNotEmpty)
                  LineChartBarData(
                    spots: series.cmSpots,
                    isCurved: series.cmSpots.length > 2,
                    preventCurveOverShooting: true,
                    color: AppTheme.cmAmber,
                    barWidth: 2.6,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: series.cmSpots.length <= 8,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: series.cmSpots.length <= 2 ? 5 : 3.2,
                        color: AppTheme.cmAmber,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF0B1220),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.cmAmber.withValues(alpha: 0.08),
                    ),
                  ),
                if (series.ctSpots.isNotEmpty)
                  LineChartBarData(
                    spots: series.ctSpots,
                    isCurved: series.ctSpots.length > 2,
                    preventCurveOverShooting: true,
                    color: AppTheme.ctTeal,
                    barWidth: 2.6,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: series.ctSpots.length <= 8,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: series.ctSpots.length <= 2 ? 5 : 3.2,
                        color: AppTheme.ctTeal,
                        strokeWidth: 2,
                        strokeColor: const Color(0xFF0B1220),
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.ctTeal.withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelMedium),
      ],
    );
  }
}
