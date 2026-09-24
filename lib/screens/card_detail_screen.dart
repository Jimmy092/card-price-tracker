import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/sync_service.dart';
import '../widgets/card_thumb.dart';
import '../widgets/dual_price_chart.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';

class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final int cardId;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  bool _syncing = false;
  int _refresh = 0;

  Future<void> _refreshPrices() async {
    setState(() => _syncing = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final outcome = await context.read<SyncService>().syncWatchlistCard(
            widget.cardId,
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
      setState(() => _refresh++);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<Card?>(
      key: ValueKey(_refresh),
      future: db.getCard(widget.cardId),
      builder: (context, cardSnap) {
        final card = cardSnap.data;
        return Scaffold(
          appBar: AppBar(
            title: Text(card?.name ?? 'Card'),
            actions: [
              IconButton(
                tooltip: 'Refresh prices',
                onPressed: _syncing || card == null ? null : _refreshPrices,
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
          body: card == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<PriceSnapshot>>(
                  future: db.snapshotsForCard(widget.cardId),
                  builder: (context, snap) {
                    final all = snap.data ?? [];
                    final cm =
                        all.where((s) => s.source == 'cardmarket').toList();
                    final ct =
                        all.where((s) => s.source == 'cardtrader').toList();
                    final latestCm = cm.isEmpty ? null : cm.last;
                    final latestCt = ct.isEmpty ? null : ct.last;

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        const EconomicsBanner(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CardThumb(
                                url: card.imageUrl,
                                width: 120,
                                height: 168,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      card.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      [
                                        if (card.expansion.isEmpty)
                                          'Unknown set'
                                        else
                                          card.expansion,
                                      ].join(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    FutureBuilder<WatchlistItem?>(
                                      future: db
                                          .getWatchlistItemForCard(card.id),
                                      builder: (context, itemSnap) {
                                        final item = itemSnap.data;
                                        if (item == null) {
                                          return const SizedBox.shrink();
                                        }
                                        final bits = <String>[
                                          if (item.foil == true) 'Foil',
                                          if (item.foil == false) 'Non-foil',
                                          if (item.language != null &&
                                              item.language!.isNotEmpty)
                                            item.language!.toUpperCase(),
                                          if (item.minCondition != null)
                                            'Min ${item.minCondition}',
                                          if (item.sellerName != null &&
                                              item.sellerName!.isNotEmpty)
                                            'Seller ${item.sellerName}',
                                          if (item.minSellerQuantity != null)
                                            'Min qty ${item.minSellerQuantity}',
                                        ];
                                        if (bits.isEmpty) {
                                          return Text(
                                            'Filters: any language / foil / condition',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          );
                                        }
                                        return Text(
                                          bits.join(' · '),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      [
                                        if (card.cardTraderBlueprintId != null)
                                          'CT #${card.cardTraderBlueprintId}',
                                        if (card.cardmarketProductId != null)
                                          'CM #${card.cardmarketProductId}',
                                      ].join(' · '),
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    if (latestCm == null && latestCt == null) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        'No price snapshots yet. Tap sync ↻.',
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _PriceBlock(
                                title: 'Cardmarket (guide)',
                                lines: [
                                  'Trend ${formatEurCents(latestCm?.cmTrendCents)}',
                                  'Low ${formatEurCents(latestCm?.cmLowCents)}',
                                  'Avg ${formatEurCents(latestCm?.cmAvgCents)}',
                                  'Avg7 ${formatEurCents(latestCm?.cmAvg7Cents)}',
                                  'Avg30 ${formatEurCents(latestCm?.cmAvg30Cents)}',
                                ],
                                footnote:
                                    'Reference only — multi-seller shipping not included.',
                                empty: latestCm == null,
                              ),
                              const SizedBox(height: 12),
                              _PriceBlock(
                                title: 'CardTrader (live)',
                                lines: [
                                  'Zero min ${formatEurCents(latestCt?.ctMinZeroCents)}',
                                  'Direct min ${formatEurCents(latestCt?.ctMinDirectCents)}',
                                  'Listings ${latestCt?.ctListingCount ?? '—'} '
                                      '(Zero ${latestCt?.ctZeroListingCount ?? '—'})',
                                ],
                                footnote:
                                    'Zero = hub-eligible listings (`can_sell_via_hub`).',
                                empty: latestCt == null,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'History (labeled dual series)',
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              DualPriceChart(
                                cmSnapshots: cm,
                                ctSnapshots: ct,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.title,
    required this.lines,
    required this.footnote,
    this.empty = false,
  });

  final String title;
  final List<String> lines;
  final String footnote;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          if (empty)
            Text(
              'No data — tap sync in the app bar.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else
            ...lines.map((l) => Text(l)),
          const SizedBox(height: 8),
          Text(footnote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
