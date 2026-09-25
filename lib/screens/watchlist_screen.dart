import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../app/theme.dart';
import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';
import '../bloc/sync/sync_cubit.dart';
import '../bloc/sync/sync_state.dart';
import '../bloc/watchlist/watchlist_cubit.dart';
import '../bloc/watchlist/watchlist_state.dart';
import '../data/database.dart';
import '../widgets/card_thumb.dart';
import '../widgets/deal_widgets.dart';
import '../widgets/economics_banner.dart';
import '../widgets/lot_sheets.dart';
import '../widgets/month_price_sparkline.dart';
import '../widgets/price_format.dart';
import '../widgets/track_purchase_sheet.dart';
import '../widgets/ui_kit.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  Future<void> _setTargets(BuildContext context, WatchlistRow row) async {
    final result = await showWatchlistTargetsSheet(
      context,
      cardName: row.card.name,
      targetBuyCents: row.item.targetBuyCents,
      targetSellCents: row.item.targetSellCents,
    );
    if (result == null || !context.mounted) return;
    await context.read<WatchlistCubit>().setTargets(
          watchlistItemId: row.item.id,
          targetBuyCents: result.$1,
          targetSellCents: result.$2,
        );
  }

  Future<void> _addToPortfolio(BuildContext context, WatchlistRow row) async {
    final draft = await showTrackPurchaseSheet(
      context,
      cardName: row.card.name,
      expansion: row.card.expansion,
      initialFoil: row.item.foil,
      initialLanguage: row.item.language,
      initialCondition: row.item.minCondition,
      suggestedPaidCents: row.ctBestCents ?? row.latestCm?.cmTrendCents,
    );
    if (draft == null || !context.mounted) return;
    await context.read<WatchlistCubit>().addToPortfolio(
          row: row,
          paidCents: draft.paidCents,
          purchasedAt: draft.purchasedAt,
          foil: draft.foil,
          language: draft.language,
          condition: draft.condition,
          quantity: draft.quantity,
          notes: draft.notes,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<WatchlistCubit, WatchlistState>(
          listenWhen: (p, n) => n.snackMessage != null && n.snackMessage != p.snackMessage,
          listener: (context, state) {
            final msg = state.snackMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () => context.go('/portfolio'),
                ),
              ),
            );
            context.read<WatchlistCubit>().clearSnack();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Watchlist'),
          actions: [
            BlocBuilder<SyncCubit, SyncState>(
              builder: (context, sync) {
                return SyncActionButton(
                  syncing: sync.isRunning,
                  onPressed: () => context.read<SyncCubit>().syncAll(),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            const EconomicsBanner(compact: true),
            Expanded(
              child: BlocBuilder<WatchlistCubit, WatchlistState>(
                builder: (context, state) {
                  if (state.status == WatchlistStatus.error) {
                    return Center(child: Text('Error: ${state.error}'));
                  }
                  if (state.status == WatchlistStatus.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final rows = state.rows;
                  if (rows.isEmpty) {
                    return EmptyState(
                      icon: Icons.style_outlined,
                      title: 'Your vault is empty',
                      message:
                          'Search a card, set foil/language filters, then tap + '
                          'to track live CT against CM guides.',
                      actionLabel: 'Search cards',
                      onAction: () => context.go('/search'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: rows.length + 1,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return SectionHeader(
                          title: '${rows.length} tracked',
                          subtitle: 'Tap a card for history · pull sync anytime',
                        );
                      }
                      final row = rows[i - 1];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration:
                            Duration(milliseconds: 280 + (i * 28).clamp(0, 220)),
                        curve: Curves.easeOutCubic,
                        builder: (context, t, child) {
                          return Opacity(
                            opacity: t,
                            child: Transform.translate(
                              offset: Offset(0, (1 - t) * 16),
                              child: child,
                            ),
                          );
                        },
                        child: _WatchlistCard(
                          row: row,
                          onOpen: () => context.push('/card/${row.card.id}'),
                          onDelete: () => context
                              .read<WatchlistCubit>()
                              .remove(row.item.id),
                          onTargets: () => _setTargets(context, row),
                          onPortfolio: () => _addToPortfolio(context, row),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WatchlistCard extends StatelessWidget {
  const _WatchlistCard({
    required this.row,
    required this.onOpen,
    required this.onDelete,
    required this.onTargets,
    required this.onPortfolio,
  });

  final WatchlistRow row;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onTargets;
  final VoidCallback onPortfolio;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cm = row.latestCm?.cmTrendCents;
    final ctZero = row.latestCt?.ctMinZeroCents;
    final ctDirect = row.latestCt?.ctMinDirectCents;
    final hasPrices = cm != null || ctZero != null || ctDirect != null;
    final spread = row.ctVsCmSpreadCents;
    final accent = spread == null
        ? null
        : spread >= 0
            ? AppTheme.spreadDown
            : AppTheme.spreadUp;

    final filters = <Widget>[
      if (row.item.foil == true)
        const FilterChipLabel(text: 'Foil', icon: Icons.auto_awesome),
      if (row.item.foil == false) const FilterChipLabel(text: 'Non-foil'),
      if (row.item.language != null && row.item.language!.isNotEmpty)
        FilterChipLabel(text: row.item.language!.toUpperCase()),
      if (row.item.minCondition != null)
        FilterChipLabel(text: '≥ ${row.item.minCondition}'),
      if (row.item.sellerName != null && row.item.sellerName!.isNotEmpty)
        FilterChipLabel(text: row.item.sellerName!, icon: Icons.storefront),
      if (row.item.minSellerQuantity != null)
        FilterChipLabel(text: 'qty ≥${row.item.minSellerQuantity}'),
    ];

    return GlowCard(
      margin: const EdgeInsets.only(bottom: 12),
      accent: accent,
      onTap: onOpen,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CardThumb(
            url: row.card.imageUrl,
            width: 68,
            height: 94,
            heroTag: 'card-art-${row.card.id}',
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        row.card.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Price targets',
                      onPressed: onTargets,
                      icon: Icon(
                        Icons.notifications_active_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Add to Portfolio',
                      onPressed: onPortfolio,
                      icon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Remove',
                      onPressed: onDelete,
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  [
                    if (row.card.expansion.isNotEmpty) row.card.expansion,
                    '×${row.item.quantity}',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (filters.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: filters),
                ],
                if (row.item.targetBuyCents != null ||
                    row.item.targetSellCents != null) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      if (row.item.targetBuyCents != null)
                        PricePill(
                          label: 'Buy ≤',
                          value: formatEurCents(row.item.targetBuyCents),
                          tone: PriceTone.up,
                          compact: true,
                        ),
                      if (row.item.targetSellCents != null)
                        PricePill(
                          label: 'Sell ≥',
                          value: formatEurCents(row.item.targetSellCents),
                          tone: PriceTone.down,
                          compact: true,
                        ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                if (!hasPrices)
                  Text(
                    'No prices yet — tap sync',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      PricePill(
                        label: 'CM',
                        value: formatEurCents(cm),
                        tone: PriceTone.cm,
                        compact: true,
                      ),
                      PricePill(
                        label: 'CT Zero',
                        value: formatEurCents(ctZero),
                        tone: PriceTone.ct,
                        compact: true,
                      ),
                      if (ctDirect != null && ctDirect != ctZero)
                        PricePill(
                          label: 'Direct',
                          value: formatEurCents(ctDirect),
                          tone: PriceTone.ct,
                          compact: true,
                        ),
                      if (spread != null)
                        PricePill(
                          label: 'CT−CM',
                          value:
                              '${formatSignedEurCents(spread)}'
                              '${row.ctVsCmSpreadPct == null ? '' : ' (${formatPct(row.ctVsCmSpreadPct)})'}',
                          tone: spread >= 0 ? PriceTone.down : PriceTone.up,
                          compact: true,
                        ),
                      if (row.cmTrendChangePct != null)
                        PricePill(
                          label: 'CM Δ',
                          value: formatPct(row.cmTrendChangePct),
                          tone: (row.cmTrendChangePct ?? 0) >= 0
                              ? PriceTone.up
                              : PriceTone.down,
                          compact: true,
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  BlocBuilder<SettingsCubit, SettingsState>(
                    builder: (context, settings) {
                      return LandedCostPills(
                        zeroListCents: ctZero,
                        directListCents: ctDirect,
                        zeroFeeCents: settings.zeroFeeCents,
                        directShippingCents: settings.directShippingCents,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  MonthPriceSparkline(
                    cmSnapshots: row.cmMonth,
                    ctSnapshots: row.ctMonth,
                    latestCm: row.latestCm,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
