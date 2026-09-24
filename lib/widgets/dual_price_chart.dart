import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../data/database.dart';

/// Dual-series chart: Cardmarket trend vs CardTrader Zero min (separate series).
class DualPriceChart extends StatelessWidget {
  const DualPriceChart({
    super.key,
    required this.cmSnapshots,
    required this.ctSnapshots,
  });

  final List<PriceSnapshot> cmSnapshots;
  final List<PriceSnapshot> ctSnapshots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cmSpots = <FlSpot>[];
    final ctSpots = <FlSpot>[];

    for (var i = 0; i < cmSnapshots.length; i++) {
      final cents = cmSnapshots[i].cmTrendCents;
      if (cents != null) {
        cmSpots.add(FlSpot(i.toDouble(), cents / 100.0));
      }
    }
    for (var i = 0; i < ctSnapshots.length; i++) {
      final cents = ctSnapshots[i].ctMinZeroCents ?? ctSnapshots[i].ctMinDirectCents;
      if (cents != null) {
        ctSpots.add(FlSpot(i.toDouble(), cents / 100.0));
      }
    }

    if (cmSpots.isEmpty && ctSpots.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No price history yet. Run Sync in Settings.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          children: [
            _LegendDot(color: theme.colorScheme.primary, label: 'CM trend'),
            _LegendDot(color: theme.colorScheme.tertiary, label: 'CT Zero min'),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: true, drawVerticalLine: false),
              titlesData: const FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                if (cmSpots.isNotEmpty)
                  LineChartBarData(
                    spots: cmSpots,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                  ),
                if (ctSpots.isNotEmpty)
                  LineChartBarData(
                    spots: ctSpots,
                    isCurved: true,
                    color: theme.colorScheme.tertiary,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
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
