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
    this.cmTrendOverrideCents,
    this.cmAvg7OverrideCents,
    this.cmAvg30OverrideCents,
    this.ctBestOverrideCents,
    this.ctHistoryCents = const [],
    this.preferCmGuideSlope = false,
  });

  final List<PriceSnapshot> cmSnapshots;
  final List<PriceSnapshot> ctSnapshots;
  /// Used to synthesize a CM month slope from avg30 → avg7 → trend when
  /// local sync history is still thin.
  final PriceSnapshot? latestCm;
  /// Foil-aware CM values from a portfolio lot (preferred over [latestCm]).
  final int? cmTrendOverrideCents;
  final int? cmAvg7OverrideCents;
  final int? cmAvg30OverrideCents;
  /// Current CT best for this lot (always plotted on the CT series).
  final int? ctBestOverrideCents;
  /// Lot-specific CT samples `(capturedAt, cents)` for real CT history.
  final List<(DateTime at, int cents)> ctHistoryCents;
  /// When true (portfolio), CM chart + % always use guide avg30→trend for
  /// this lot instead of shared card sync history.
  final bool preferCmGuideSlope;
  final double height;

  static const window = Duration(days: 30);

  @override
  Widget build(BuildContext context) {
    final series = MonthPriceSeries.fromSnapshots(
      cmSnapshots: cmSnapshots,
      ctSnapshots: ctSnapshots,
      latestCm: latestCm,
      cmTrendOverrideCents: cmTrendOverrideCents,
      cmAvg7OverrideCents: cmAvg7OverrideCents,
      cmAvg30OverrideCents: cmAvg30OverrideCents,
      ctBestOverrideCents: ctBestOverrideCents,
      ctHistoryCents: ctHistoryCents,
      preferCmGuideSlope: preferCmGuideSlope ||
          cmTrendOverrideCents != null ||
          cmAvg30OverrideCents != null,
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
    final ctLabel = series.ctEstimated ? 'CT est.' : 'CT 30d';

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
                    barWidth: 2.2,
                    isStrokeCapRound: true,
                    dashArray: series.ctEstimated ? [6, 4] : null,
                    dotData: FlDotData(
                      show: series.ctSpots.length <= 3,
                      getDotPainter: (s, p, b, i) => FlDotCirclePainter(
                        radius: 2.6,
                        color: AppTheme.ctTeal,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.ctTeal.withValues(alpha: 0.12),
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
            _MiniLegend(color: AppTheme.ctTeal, label: ctLabel),
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
        if (series.ctEstimated)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'CT est. = current CT scaled by CM avg30→trend (CT has no public 30d sales API)',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
            ),
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
    this.ctEstimated = false,
  });

  final List<FlSpot> cmSpots;
  final List<FlSpot> ctSpots;
  final double spanMs;
  final double minY;
  final double maxY;
  final DateTime windowStart;
  final double? cmSlopePct;
  final double? ctSlopePct;
  /// True when CT 30d was estimated from CM guide shape × current CT.
  final bool ctEstimated;

  bool get hasAny => cmSpots.isNotEmpty || ctSpots.isNotEmpty;

  static MonthPriceSeries fromSnapshots({
    required List<PriceSnapshot> cmSnapshots,
    required List<PriceSnapshot> ctSnapshots,
    PriceSnapshot? latestCm,
    int? cmTrendOverrideCents,
    int? cmAvg7OverrideCents,
    int? cmAvg30OverrideCents,
    int? ctBestOverrideCents,
    List<(DateTime at, int cents)> ctHistoryCents = const [],
    bool preferCmGuideSlope = false,
    DateTime? now,
  }) {
    final end = now ?? DateTime.now();
    final start = end.subtract(MonthPriceSparkline.window);
    final spanMs = MonthPriceSparkline.window.inMilliseconds.toDouble();

    double xOf(DateTime at) {
      final ms = at.difference(start).inMilliseconds.toDouble();
      return ms.clamp(0, spanMs);
    }

    final trendCents = cmTrendOverrideCents ??
        latestCm?.cmTrendCents ??
        (cmSnapshots.isEmpty ? null : cmSnapshots.last.cmTrendCents);
    final avg7Cents = cmAvg7OverrideCents ??
        latestCm?.cmAvg7Cents ??
        (cmSnapshots.isEmpty ? null : cmSnapshots.last.cmAvg7Cents);
    final avg30Cents = cmAvg30OverrideCents ??
        latestCm?.cmAvg30Cents ??
        (cmSnapshots.isEmpty ? null : cmSnapshots.last.cmAvg30Cents);

    final guideSpots = _syntheticCmSpots(
      trendCents: trendCents,
      avg7Cents: avg7Cents,
      avg30Cents: avg30Cents,
      start: start,
      end: end,
      xOf: xOf,
    );
    // CM "30d %" = current trend vs 30-day average (Cardmarket guide fields).
    final guideSlopePct = _guideMonthSlopePct(
      trendCents: trendCents,
      avg30Cents: avg30Cents,
    );

    final cmInWindow = cmSnapshots
        .where((s) => !s.capturedAt.isBefore(start) && s.cmTrendCents != null)
        .toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));
    final historyCmSpots = _dedupeSpots([
      for (final s in cmInWindow)
        FlSpot(xOf(s.capturedAt), s.cmTrendCents! / 100.0),
    ]);
    final historySpanOk = _hasMeaningfulTimeSpan(cmInWindow);

    late final List<FlSpot> cmSpots;
    late final double? cmSlopePct;
    if (preferCmGuideSlope && guideSpots.isNotEmpty) {
      cmSpots = guideSpots;
      cmSlopePct = guideSlopePct;
    } else if (historyCmSpots.length >= 2 && historySpanOk) {
      cmSpots = historyCmSpots;
      cmSlopePct = _slopePct(historyCmSpots) ?? guideSlopePct;
    } else if (guideSpots.isNotEmpty) {
      cmSpots = guideSpots;
      cmSlopePct = guideSlopePct;
    } else {
      cmSpots = historyCmSpots;
      cmSlopePct = _slopePct(historyCmSpots);
    }

    // --- CT series: prefer lot history, then shared snapshots, then estimate ---
    final lotCt = [
      for (final p in ctHistoryCents)
        if (!p.$1.isBefore(start)) (p.$1, p.$2),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    final ctInWindow = ctSnapshots.where((s) {
      final cents = s.ctMinZeroCents ?? s.ctMinDirectCents;
      return cents != null && !s.capturedAt.isBefore(start);
    }).toList()
      ..sort((a, b) => a.capturedAt.compareTo(b.capturedAt));

    var ctSpots = _dedupeSpots([
      if (lotCt.isNotEmpty)
        for (final p in lotCt) FlSpot(xOf(p.$1), p.$2 / 100.0)
      else
        for (final s in ctInWindow)
          FlSpot(
            xOf(s.capturedAt),
            (s.ctMinZeroCents ?? s.ctMinDirectCents)! / 100.0,
          ),
    ]);

    // Always pin current lot CT at "now".
    if (ctBestOverrideCents != null) {
      final nowSpot = FlSpot(spanMs, ctBestOverrideCents / 100.0);
      if (ctSpots.isEmpty) {
        ctSpots = [nowSpot];
      } else if ((ctSpots.last.x - spanMs).abs() < 0.5) {
        ctSpots = [...ctSpots.sublist(0, ctSpots.length - 1), nowSpot];
      } else {
        ctSpots = [...ctSpots, nowSpot];
      }
    }

    final realCtTimes = lotCt.isNotEmpty
        ? lotCt.map((e) => e.$1).toList()
        : ctInWindow.map((e) => e.capturedAt).toList();
    final realCtSpanOk = realCtTimes.length >= 2 &&
        realCtTimes.last.difference(realCtTimes.first).inHours >= 12;

    var ctEstimated = false;
    double? ctSlopePct;
    if (ctSpots.length >= 2 && realCtSpanOk) {
      ctSlopePct = _slopePct(ctSpots);
    } else if (ctBestOverrideCents != null &&
        trendCents != null &&
        trendCents > 0 &&
        avg30Cents != null &&
        avg7Cents != null) {
      // CardTrader has no public 30d sales API — estimate shape from CM guide
      // ratios, anchored on this lot's current CT best.
      final est = _syntheticCtFromCmShape(
        ctNowCents: ctBestOverrideCents,
        cmTrendCents: trendCents,
        cmAvg7Cents: avg7Cents,
        cmAvg30Cents: avg30Cents,
        start: start,
        end: end,
        xOf: xOf,
      );
      if (est.isNotEmpty) {
        ctSpots = est;
        ctEstimated = true;
        ctSlopePct = _guideMonthSlopePct(
          trendCents: ctBestOverrideCents,
          avg30Cents: (ctBestOverrideCents * avg30Cents / trendCents).round(),
        );
      }
    } else if (ctSpots.length == 1) {
      // Show a short recent segment so CT is visible next to CM.
      final y = ctSpots.first.y;
      ctSpots = [
        FlSpot(spanMs * 0.85, y),
        FlSpot(spanMs, y),
      ];
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
      cmSlopePct: cmSlopePct,
      ctSlopePct: ctSlopePct,
      ctEstimated: ctEstimated,
    );
  }

  /// Scale CM avg30→avg7→trend shape onto current CT asking price.
  static List<FlSpot> _syntheticCtFromCmShape({
    required int ctNowCents,
    required int cmTrendCents,
    required int cmAvg7Cents,
    required int cmAvg30Cents,
    required DateTime start,
    required DateTime end,
    required double Function(DateTime) xOf,
  }) {
    if (cmTrendCents <= 0 || ctNowCents <= 0) return const [];
    final scale = ctNowCents / cmTrendCents;
    final ct30 = (cmAvg30Cents * scale).round() / 100.0;
    final ct7 = (cmAvg7Cents * scale).round() / 100.0;
    final ctNow = ctNowCents / 100.0;
    return _dedupeSpots([
      FlSpot(xOf(start), ct30),
      FlSpot(xOf(end.subtract(const Duration(days: 7))), ct7),
      FlSpot(xOf(end), ctNow),
    ]);
  }

  /// Current CM trend vs rolling 30-day average.
  static double? _guideMonthSlopePct({
    required int? trendCents,
    required int? avg30Cents,
  }) {
    if (trendCents == null || avg30Cents == null || avg30Cents == 0) {
      return null;
    }
    return ((trendCents - avg30Cents) / avg30Cents) * 100;
  }

  static bool _hasMeaningfulTimeSpan(List<PriceSnapshot> snaps) {
    if (snaps.length < 2) return false;
    final first = snaps.first.capturedAt;
    final last = snaps.last.capturedAt;
    return last.difference(first).inHours >= 12;
  }

  static List<FlSpot> _syntheticCmSpots({
    required int? trendCents,
    required int? avg7Cents,
    required int? avg30Cents,
    required DateTime start,
    required DateTime end,
    required double Function(DateTime) xOf,
  }) {
    if (trendCents == null) return const [];
    final avg7 = avg7Cents ?? trendCents;
    final avg30 = avg30Cents ?? avg7;

    final points = <FlSpot>[
      FlSpot(xOf(start), avg30 / 100.0),
      FlSpot(xOf(end.subtract(const Duration(days: 7))), avg7 / 100.0),
      FlSpot(xOf(end), trendCents / 100.0),
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
