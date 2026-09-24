import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../widgets/dual_price_chart.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';

class CardDetailScreen extends StatelessWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final int cardId;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<AppDatabase>();
    return FutureBuilder<Card?>(
      future: db.getCard(cardId),
      builder: (context, cardSnap) {
        final card = cardSnap.data;
        return Scaffold(
          appBar: AppBar(title: Text(card?.name ?? 'Card')),
          body: card == null
              ? const Center(child: CircularProgressIndicator())
              : FutureBuilder<List<PriceSnapshot>>(
                  future: db.snapshotsForCard(cardId),
                  builder: (context, snap) {
                    final all = snap.data ?? [];
                    final cm = all.where((s) => s.source == 'cardmarket').toList();
                    final ct = all.where((s) => s.source == 'cardtrader').toList();
                    final latestCm = cm.isEmpty ? null : cm.last;
                    final latestCt = ct.isEmpty ? null : ct.last;

                    return ListView(
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        const EconomicsBanner(),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card.expansion.isEmpty ? 'Unknown set' : card.expansion,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                [
                                  if (card.cardTraderBlueprintId != null)
                                    'CT blueprint ${card.cardTraderBlueprintId}',
                                  if (card.cardmarketProductId != null)
                                    'CM product ${card.cardmarketProductId}',
                                ].join(' · '),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 16),
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
                              ),
                              const SizedBox(height: 24),
                              Text(
                                'History (labeled dual series)',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              DualPriceChart(cmSnapshots: cm, ctSnapshots: ct),
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
  });

  final String title;
  final List<String> lines;
  final String footnote;

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
          ...lines.map((l) => Text(l)),
          const SizedBox(height: 8),
          Text(footnote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
