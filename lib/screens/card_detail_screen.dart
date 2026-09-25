import 'package:flutter/material.dart' hide Card;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app/theme.dart';
import '../bloc/sync/sync_cubit.dart';
import '../bloc/sync/sync_state.dart';
import '../data/database.dart';
import '../widgets/card_thumb.dart';
import '../widgets/dual_price_chart.dart';
import '../widgets/economics_banner.dart';
import '../widgets/price_format.dart';
import '../widgets/ui_kit.dart';

class CardDetailScreen extends StatefulWidget {
  const CardDetailScreen({super.key, required this.cardId});

  final int cardId;

  @override
  State<CardDetailScreen> createState() => _CardDetailScreenState();
}

class _CardDetailScreenState extends State<CardDetailScreen> {
  int _refresh = 0;

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return BlocListener<SyncCubit, SyncState>(
      listenWhen: (p, n) => n.status == SyncStatus.success,
      listener: (context, state) => setState(() => _refresh++),
      child: FutureBuilder<Card?>(
        key: ValueKey(_refresh),
        future: db.getCard(widget.cardId),
        builder: (context, cardSnap) {
          final card = cardSnap.data;
          return AppBackdrop(
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                title: Text(card?.name ?? 'Card'),
                actions: [
                  BlocBuilder<SyncCubit, SyncState>(
                    builder: (context, sync) {
                      return SyncActionButton(
                        syncing: sync.isRunning,
                        onPressed: card == null
                            ? null
                            : () => context
                                .read<SyncCubit>()
                                .syncCard(widget.cardId),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              body: card == null
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<List<PriceSnapshot>>(
                      stream: db.watchSnapshotsForCard(widget.cardId),
                      builder: (context, snap) {
                      final all = snap.data ?? [];
                      final cm = all
                          .where((s) => s.source == 'cardmarket')
                          .toList();
                      final ct = all
                          .where((s) => s.source == 'cardtrader')
                          .toList();
                      final latestCm = cm.isEmpty ? null : cm.last;
                      final latestCt = ct.isEmpty ? null : ct.last;

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 28),
                        children: [
                          const EconomicsBanner(),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                            child: GlowCard(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CardThumb(
                                    url: card.imageUrl,
                                    width: 120,
                                    height: 168,
                                    heroTag: 'card-art-${card.id}',
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          card.name,
                                          style: Theme.of(context)
                                              .textTheme
                                              .headlineSmall
                                              ?.copyWith(
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: -0.4,
                                              ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          card.expansion.isEmpty
                                              ? 'Unknown set'
                                              : card.expansion,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                        const SizedBox(height: 10),
                                        FutureBuilder<WatchlistItem?>(
                                          future: db.getWatchlistItemForCard(
                                            card.id,
                                          ),
                                          builder: (context, itemSnap) {
                                            final item = itemSnap.data;
                                            if (item == null) {
                                              return const SizedBox.shrink();
                                            }
                                            final chips = <Widget>[
                                              if (item.foil == true)
                                                const FilterChipLabel(
                                                  text: 'Foil',
                                                  icon: Icons.auto_awesome,
                                                ),
                                              if (item.foil == false)
                                                const FilterChipLabel(
                                                  text: 'Non-foil',
                                                ),
                                              if (item.language != null &&
                                                  item.language!.isNotEmpty)
                                                FilterChipLabel(
                                                  text: item.language!
                                                      .toUpperCase(),
                                                ),
                                              if (item.minCondition != null)
                                                FilterChipLabel(
                                                  text:
                                                      'Min ${item.minCondition}',
                                                ),
                                              if (item.sellerName != null &&
                                                  item.sellerName!.isNotEmpty)
                                                FilterChipLabel(
                                                  text: item.sellerName!,
                                                  icon: Icons.storefront,
                                                ),
                                              if (item.minSellerQuantity !=
                                                  null)
                                                FilterChipLabel(
                                                  text:
                                                      'qty ≥${item.minSellerQuantity}',
                                                ),
                                            ];
                                            if (chips.isEmpty) {
                                              return Text(
                                                'Any language / foil / condition',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodySmall,
                                              );
                                            }
                                            return Wrap(
                                              spacing: 6,
                                              runSpacing: 6,
                                              children: chips,
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          [
                                            if (card.cardTraderBlueprintId !=
                                                null)
                                              'CT #${card.cardTraderBlueprintId}',
                                            if (card.cardmarketProductId !=
                                                null)
                                              'CM #${card.cardmarketProductId}',
                                          ].join(' · '),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _SourcePanel(
                                  title: 'Cardmarket',
                                  subtitle: 'Daily guide',
                                  accent: AppTheme.cmAmber,
                                  empty: latestCm == null,
                                  lines: [
                                    ('Trend', formatEurCents(latestCm?.cmTrendCents)),
                                    ('Low', formatEurCents(latestCm?.cmLowCents)),
                                    ('Avg', formatEurCents(latestCm?.cmAvgCents)),
                                    ('Avg7', formatEurCents(latestCm?.cmAvg7Cents)),
                                    ('Avg30', formatEurCents(latestCm?.cmAvg30Cents)),
                                  ],
                                  footnote:
                                      'Reference only — multi-seller shipping not included.',
                                ),
                                const SizedBox(height: 12),
                                _SourcePanel(
                                  title: 'CardTrader',
                                  subtitle: 'Live marketplace',
                                  accent: AppTheme.ctTeal,
                                  empty: latestCt == null,
                                  lines: [
                                    (
                                      'Zero min',
                                      formatEurCents(latestCt?.ctMinZeroCents)
                                    ),
                                    (
                                      'Direct min',
                                      formatEurCents(latestCt?.ctMinDirectCents)
                                    ),
                                    (
                                      'Listings',
                                      '${latestCt?.ctListingCount ?? '—'} (Zero ${latestCt?.ctZeroListingCount ?? '—'})'
                                    ),
                                  ],
                                  footnote:
                                      'Zero = hub-eligible listings (`can_sell_via_hub`).',
                                ),
                                const SizedBox(height: 20),
                                const SectionHeader(
                                  title: 'Last 30 days',
                                  subtitle: 'CM trend · CT best price slope',
                                ),
                                GlowCard(
                                  child: DualPriceChart(
                                    cmSnapshots: cm,
                                    ctSnapshots: ct,
                                    latestCm: latestCm,
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
        );
      },
    ),
    );
  }
}

class _SourcePanel extends StatelessWidget {
  const _SourcePanel({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.lines,
    required this.footnote,
    required this.empty,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final List<(String, String)> lines;
  final String footnote;
  final bool empty;

  @override
  Widget build(BuildContext context) {
    return GlowCard(
      accent: accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: accent,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (empty)
            Text(
              'No data — tap sync in the app bar.',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            )
          else
            ...lines.map(
              (line) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        line.$1,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ),
                    Text(
                      line.$2,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 6),
          Text(footnote, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
