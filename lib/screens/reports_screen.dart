import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../app/theme.dart';
import '../data/database.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';
import '../widgets/ui_kit.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton.filledTonal(
            tooltip: 'Share CSV',
            icon: const Icon(Icons.ios_share_rounded),
            onPressed: () => _shareCsv(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          const EconomicsBanner(compact: true),
          Expanded(
            child: StreamBuilder<List<WatchlistRow>>(
              stream: db.watchWatchlist(),
              builder: (context, snapshot) {
                final rows = snapshot.data ?? [];
                if (rows.isEmpty) {
                  return const EmptyState(
                    icon: Icons.candlestick_chart_outlined,
                    title: 'No report yet',
                    message: 'Add cards to the watchlist to unlock portfolio totals.',
                  );
                }

                var cmValue = 0;
                var ctZeroValue = 0;
                var cmCount = 0;
                var ctCount = 0;
                for (final r in rows) {
                  final qty = r.item.quantity;
                  final cm = r.latestCm?.cmTrendCents;
                  final ct = r.latestCt?.ctMinZeroCents;
                  if (cm != null) {
                    cmValue += cm * qty;
                    cmCount++;
                  }
                  if (ct != null) {
                    ctZeroValue += ct * qty;
                    ctCount++;
                  }
                }

                final movers = [...rows]
                  ..sort((a, b) {
                    final ap = a.cmTrendChangePct ?? 0;
                    final bp = b.cmTrendChangePct ?? 0;
                    return bp.compareTo(ap);
                  });
                final gainers =
                    movers.where((r) => (r.cmTrendChangePct ?? 0) > 0).take(5);
                final losers = movers
                    .where((r) => (r.cmTrendChangePct ?? 0) < 0)
                    .toList()
                    .reversed
                    .take(5);

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  children: [
                    const SectionHeader(
                      title: 'Portfolio by source',
                      subtitle: 'Totals stay separate — never blended',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            label: 'Cardmarket',
                            value: formatEurCents(cmValue),
                            detail: '$cmCount priced',
                            accent: AppTheme.cmAmber,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            label: 'CT Zero',
                            value: formatEurCents(ctZeroValue),
                            detail: '$ctCount priced',
                            accent: AppTheme.ctTeal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const SectionHeader(
                      title: 'CM movers',
                      subtitle: 'Latest vs previous distinct trend',
                    ),
                    GlowCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gainers',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.spreadUp,
                                ),
                          ),
                          const SizedBox(height: 6),
                          if (gainers.isEmpty)
                            const Text('No gainers yet.')
                          else
                            ...gainers.map(
                              (r) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(r.card.name),
                                trailing: PricePill(
                                  label: 'CM Δ',
                                  value: formatPct(r.cmTrendChangePct),
                                  tone: PriceTone.up,
                                  compact: true,
                                ),
                              ),
                            ),
                          const Divider(height: 20),
                          Text(
                            'Losers',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.spreadDown,
                                ),
                          ),
                          const SizedBox(height: 6),
                          if (losers.isEmpty)
                            const Text('No losers yet.')
                          else
                            ...losers.map(
                              (r) => ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                title: Text(r.card.name),
                                trailing: PricePill(
                                  label: 'CM Δ',
                                  value: formatPct(r.cmTrendChangePct),
                                  tone: PriceTone.down,
                                  compact: true,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareCsv(BuildContext context) async {
    final db = context.read<AppDatabase>();
    final rows = await db.watchWatchlist().first;
    final buf = StringBuffer(
      'name,expansion,qty,cm_trend_eur,ct_zero_min_eur,ct_direct_min_eur,cm_change_pct\n',
    );
    for (final r in rows) {
      final cm = (r.latestCm?.cmTrendCents ?? 0) / 100.0;
      final ctz = r.latestCt?.ctMinZeroCents;
      final ctd = r.latestCt?.ctMinDirectCents;
      buf.writeln(
        [
          _csv(r.card.name),
          _csv(r.card.expansion),
          r.item.quantity,
          r.latestCm?.cmTrendCents == null ? '' : cm.toStringAsFixed(2),
          ctz == null ? '' : (ctz / 100.0).toStringAsFixed(2),
          ctd == null ? '' : (ctd / 100.0).toStringAsFixed(2),
          r.cmTrendChangePct?.toStringAsFixed(2) ?? '',
        ].join(','),
      );
    }

    final dir = await getTemporaryDirectory();
    final file = File(p.join(dir.path, 'card_price_report.csv'));
    await file.writeAsString(buf.toString());
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Card price report (CM and CT separate columns)',
      ),
    );
  }

  String _csv(String v) {
    if (v.contains(',') || v.contains('"')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.detail,
    required this.accent,
  });

  final String label;
  final String value;
  final String detail;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
