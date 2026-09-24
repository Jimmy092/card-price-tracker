import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      appBar: AppBar(title: const Text('Watchlist')),
      body: Column(
        children: [
          const EconomicsBanner(compact: true),
          Expanded(
            child: StreamBuilder<List<WatchlistRow>>(
              stream: db.watchWatchlist(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final rows = snapshot.data!;
                if (rows.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'No cards yet',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Search MTG blueprints on CardTrader and add them here.',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () => context.go('/search'),
                            child: const Text('Search cards'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    final cm = row.latestCm?.cmTrendCents;
                    final ctZero = row.latestCt?.ctMinZeroCents;
                    final ctDirect = row.latestCt?.ctMinDirectCents;
                    return ListTile(
                      title: Text(row.card.name),
                      subtitle: Text(
                        [
                          if (row.card.expansion.isNotEmpty) row.card.expansion,
                          'qty ${row.item.quantity}',
                          'CM ${formatEurCents(cm)}',
                          'CT Zero ${formatEurCents(ctZero)}',
                          if (ctDirect != null && ctDirect != ctZero)
                            'CT direct ${formatEurCents(ctDirect)}',
                          'Δ ${formatPct(row.cmTrendChangePct)}',
                        ].join(' · '),
                      ),
                      isThreeLine: true,
                      onTap: () => context.push('/card/${row.card.id}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => db.removeFromWatchlist(row.item.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
