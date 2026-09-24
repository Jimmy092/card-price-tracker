import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../data/database.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            tooltip: 'Share CSV',
            icon: const Icon(Icons.ios_share),
            onPressed: () => _shareCsv(context),
          ),
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
                  return const Center(child: Text('Add cards to see reports.'));
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
                final gainers = movers.where((r) => (r.cmTrendChangePct ?? 0) > 0).take(5);
                final losers = movers.where((r) => (r.cmTrendChangePct ?? 0) < 0).toList().reversed.take(5);

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Portfolio value by source',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Cardmarket trend total: ${formatEurCents(cmValue)} ($cmCount priced)'),
                    Text('CardTrader Zero total: ${formatEurCents(ctZeroValue)} ($ctCount priced)'),
                    const SizedBox(height: 4),
                    Text(
                      'Totals are separate — do not add them together as one portfolio number.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'CM movers (latest vs previous snapshot)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text('Gainers', style: Theme.of(context).textTheme.titleSmall),
                    ...gainers.map(
                      (r) => ListTile(
                        dense: true,
                        title: Text(r.card.name),
                        trailing: Text(formatPct(r.cmTrendChangePct)),
                      ),
                    ),
                    if (gainers.isEmpty) const Text('No gainers yet.'),
                    const SizedBox(height: 8),
                    Text('Losers', style: Theme.of(context).textTheme.titleSmall),
                    ...losers.map(
                      (r) => ListTile(
                        dense: true,
                        title: Text(r.card.name),
                        trailing: Text(formatPct(r.cmTrendChangePct)),
                      ),
                    ),
                    if (losers.isEmpty) const Text('No losers yet.'),
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
      ShareParams(files: [XFile(file.path)], text: 'Card price report (CM and CT separate columns)'),
    );
  }

  String _csv(String v) {
    if (v.contains(',') || v.contains('"')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }
}
