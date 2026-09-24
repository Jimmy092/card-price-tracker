import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/sync_service.dart';
import '../widgets/card_thumb.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  bool _syncing = false;

  Future<void> _syncAll() async {
    setState(() => _syncing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final outcome = await context.read<SyncService>().syncAll(
            onProgress: (m) {
              if (!mounted) return;
              messenger
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(m)));
            },
          );
      if (!mounted) return;
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(outcome.message)));
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            tooltip: 'Refresh prices',
            onPressed: _syncing ? null : _syncAll,
            icon: _syncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sync),
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
                            'Search for a card, then tap + to add it. '
                            'Prices load automatically after you add.',
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: rows.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    final cm = row.latestCm?.cmTrendCents;
                    final ctZero = row.latestCt?.ctMinZeroCents;
                    final ctDirect = row.latestCt?.ctMinDirectCents;
                    final hasPrices = cm != null || ctZero != null || ctDirect != null;

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CardThumb(url: row.card.imageUrl),
                      title: Text(row.card.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 2),
                          Text(
                            [
                              if (row.card.expansion.isNotEmpty)
                                row.card.expansion,
                              if (row.item.foil == true) 'Foil',
                              if (row.item.foil == false) 'Non-foil',
                              if (row.item.language != null &&
                                  row.item.language!.isNotEmpty)
                                row.item.language!.toUpperCase(),
                              if (row.item.minCondition != null)
                                '≥ ${row.item.minCondition}',
                              'qty ${row.item.quantity}',
                            ].join(' · '),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          if (!hasPrices)
                            Text(
                              'No prices yet — tap sync ↻ or re-add the card',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            )
                          else
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _PriceTag(
                                  label: 'CM',
                                  value: formatEurCents(cm),
                                ),
                                _PriceTag(
                                  label: 'CT Zero',
                                  value: formatEurCents(ctZero),
                                ),
                                if (ctDirect != null && ctDirect != ctZero)
                                  _PriceTag(
                                    label: 'CT Direct',
                                    value: formatEurCents(ctDirect),
                                  ),
                                if (row.cmTrendChangePct != null)
                                  _PriceTag(
                                    label: 'Δ',
                                    value: formatPct(row.cmTrendChangePct),
                                  ),
                              ],
                            ),
                        ],
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

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}
