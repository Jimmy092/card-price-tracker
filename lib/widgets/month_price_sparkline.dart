import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/database.dart';

/// Compact dual sparkline for the last ~30 days (CM amber + CT teal).
class MonthPriceSparkline extends StatelessWidget {
  const MonthPriceSparkline({
    super.key,
    required this.cmSnapshots,
    required this.ctSnapshots,
    this.height = 44,
    this.latestCm,
  });

  final List<PriceSnapshot> cmSnapshots;
  final List<PriceSnapshot> ctSnapshots;
  /// Used to synthesize a CM month slope from avg30 → avg7 → trend when
  /// local sync history is still thin.
  final PriceSnapshot? latestCm;
  final double height;

  static const window = Duration(days: 30);

  @override
  Widget build(BuildContext context) {
    final series = MonthPriceSeries.fromSnapshots(
      cmSnapshots: cmSnapshots,
      ctSnapshots: ctSnapshots,
      latestCm: latestCm,
    );
    if (!series.hasAny) {
      return SizedBox(
        height: height,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'No 30-day history yet',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    final minY = series.minY;
    final maxY = series.maxY;
    final span = series.spanMs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: height,
          width: double.infinity,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: span,
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: const FlTitlesData(show: false),
              lineTouchData: const LineTouchData(enabled: false),
              lineBarsData: [
                if (series.cmSpots.isNotEmpty)
                  LineChartBarData(
                    spots: series.cmSpots,
                    isCurved: series.cmSpots.length > 2,
                    preventCurveOverShooting: true,
                    color: AppTheme.cmAmber,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: series.cmSpots.length <= 2,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 2.4,
                        color: AppTheme.cmAmber,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.cmAmber.withValues(alpha: 0.10),
                    ),
                  ),
                if (series.ctSpots.isNotEmpty)
                  LineChartBarData(
                    spots: series.ctSpots,
                    isCurved: series.ctSpots.length > 2,
                    preventCurveOverShooting: true,
                    color: AppTheme.ctTeal,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: series.ctSpots.length <= 2,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 2.4,
                        color: AppTheme.ctTeal,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.ctTeal.withValues(alpha: 0.10),
                    ),
                  ),
              ],
            ),
            duration: Duration.zero,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            _MiniLegend(color: AppTheme.cmAmber, label: 'CM 30d'),
            const SizedBox(width: 10),
            _MiniLegend(color: AppTheme.ctTeal, label: 'CT 30d'),
            const Spacer(),
            if (series.cmSlopePct != null)
              Text(
                'CM ${series.cmSlopePct! >= 0 ? '▲' : '▼'} '
                '${series.cmSlopePct!.abs().toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: series.cmSlopePct! >= 0
                          ? AppTheme.spreadUp
                          : AppTheme.spreadDown,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            if (series.cmSlopePct != null && series.ctSlopePct != null)
              const SizedBox(width: 8),
            if (series.ctSlopePct != null)
              Text(
                'CT ${series.ctSlopePct! >= 0 ? '▲' : '▼'} '
                '${series.ctSlopePct!.abs().toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: series.ctSlopePct! >= 0
                          ? AppTheme.spreadUp
                          : AppTheme.spreadDown,
                      fontWeight: FontWeight.w700,
                    ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniLegend extends StatelessWidget {
  const _MiniLegend({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

/// Shared last-month series builder for list sparklines and detail charts.
class MonthPriceSeries {
  MonthPriceSeries({
    required this.cmSpots,
    required this.ctSpots,
    required this.spanMs,
    required this.minY,
    required this.maxY,
    required this.windowStart,
    this.cmSlopePct,
    this.ctSlopePct,
  });

  final List<FlSpot> cmSpots;
  final List<FlSpot> ctSpots;
  final double spanMs;
  final double minY;
  final double maxY;
  final DateTime windowStart;
  final double? cmSlopePct;
  final double? ctSlopePct;

  bool get hasAny => cmSpots.isNotEmpty || ctSpots.isNotEmpty;

  static MonthPriceSeries fromSnapshots({
    required List<PriceSnapshot> cmSnapshots,
    required List<PriceSnapshot> ctSnapshots,
    PriceSnapshot? latestCm,
    DateTime? now,
  }) {
    final end = now ?? DateTime.now();
    final start = end.subtract(MonthPriceSparkline.window);
    final spanMs = MonthPriceSparkline.window.inMilliseconds.toDouble();

    double xOf(DateTime at) {
      final ms = at.difference(start).inMilliseconds.toDouble();
      return ms.clamp(0, spanMs);
    }

    final cmInWindow = cmSnapshots
        .where((s) => !s.capturedAt.isBefore(start) && s.cmTrendCents != null)
        .toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final ctInWindow = ctSnapshots.where((s) {
      final cents = s.ctMinZeroCents ?? s.ctMinDirectCents;
      return cents != null && !s.capturedAt.isBefore(start);
    }).toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    var cmSpots = <FlSpot>[
      for (final s in cmInWindow) FlSpot(xOf(s.capturedAt), s.cmTrendCents! / 100.0),
    ];
    // Deduplicate same-x points (keep last).
    cmSpots = _dedupeSpots(cmSpots);

    // Synthesize CM month slope from guide rolling averages when history is thin.
    if (cmSpots.length < 2) {
      final guide = latestCm ?? (cmSnapshots.isEmpty ? null : cmSnapshots.last);
      final synthetic = _syntheticCmSpots(guide, start, end, xOf);
      if (synthetic.length >= cmSpots.length) {
        cmSpots = synthetic;
      }
    }

    var ctSpots = <FlSpot>[
      for (final s in ctInWindow)
        FlSpot(
          xOf(s.capturedAt),
          (s.ctMinZeroCents ?? s.ctMinDirectCents)! / 100.0,
        ),
    ];
    ctSpots = _dedupeSpots(ctSpots);

    // Single CT point: stretch a flat segment so the slope line is visible.
    if (ctSpots.length == 1) {
      final y = ctSpots.first.y;
      ctSpots = [FlSpot(0, y), FlSpot(spanMs, y)];
    }

    final allY = <double>[
      ...cmSpots.map((s) => s.y),
      ...ctSpots.map((s) => s.y),
    ];
    var minY = allY.isEmpty ? 0.0 : allY.reduce(math.min);
    var maxY = allY.isEmpty ? 1.0 : allY.reduce(math.max);
    if ((maxY - minY).abs() < 0.01) {
      final pad = math.max(maxY.abs() * 0.05, 0.25);
      minY -= pad;
      maxY += pad;
    } else {
      final pad = (maxY - minY) * 0.15;
      minY = math.max(0, minY - pad);
      maxY += pad;
    }

    return MonthPriceSeries(
      cmSpots: cmSpots,
      ctSpots: ctSpots,
      spanMs: spanMs,
      minY: minY,
      maxY: maxY,
      windowStart: start,
      cmSlopePct: _slopePct(cmSpots),
      ctSlopePct: _slopePct(ctSpots),
    );
  }

  static List<FlSpot> _syntheticCmSpots(
    PriceSnapshot? guide,
    DateTime start,
    DateTime end,
    double Function(DateTime) xOf,
  ) {
    if (guide == null) return const [];
    final trend = guide.cmTrendCents;
    if (trend == null) return const [];
    final avg7 = guide.cmAvg7Cents ?? trend;
    final avg30 = guide.cmAvg30Cents ?? avg7;

    final points = <FlSpot>[
      FlSpot(xOf(start), avg30 / 100.0),
      FlSpot(xOf(end.subtract(const Duration(days: 7))), avg7 / 100.0),
      FlSpot(xOf(end), trend / 100.0),
    ];
    return _dedupeSpots(points);
  }

  static List<FlSpot> _dedupeSpots(List<FlSpot> spots) {
    if (spots.isEmpty) return spots;
    final out = <FlSpot>[spots.first];
    for (var i = 1; i < spots.length; i++) {
      if ((spots[i].x - out.last.x).abs() < 0.5) {
        out[out.length - 1] = spots[i];
      } else {
        out.add(spots[i]);
      }
    }
    return out;
  }

  static double? _slopePct(List<FlSpot> spots) {
    if (spots.length < 2) return null;
    final first = spots.first.y;
    final last = spots.last.y;
    if (first == 0) return null;
    return ((last - first) / first) * 100;
  }
}
