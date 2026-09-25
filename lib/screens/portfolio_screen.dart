import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../app/theme.dart';
import '../bloc/portfolio/portfolio_cubit.dart';
import '../bloc/portfolio/portfolio_state.dart';
import '../bloc/settings/settings_cubit.dart';
import '../bloc/settings/settings_state.dart';
import '../bloc/sync/sync_cubit.dart';
import '../bloc/sync/sync_state.dart';
import '../data/database.dart';
import '../services/landed_cost.dart';
import '../widgets/card_thumb.dart';
import '../widgets/deal_widgets.dart';
import '../widgets/lot_sheets.dart';
import '../widgets/month_price_sparkline.dart';
import '../widgets/price_format.dart';
import '../widgets/ui_kit.dart';

final _day = DateFormat.yMMMd();

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  Future<void> _edit(BuildContext context, TrackedRow row) async {
    final draft = await showEditLotSheet(
      context,
      cardName: row.card.name,
      paidCents: row.item.paidCents,
      purchasedAt: row.item.purchasedAt,
      quantity: row.item.quantity,
      foil: row.item.foil,
      language: row.item.language,
      condition: row.item.condition,
      notes: row.item.notes,
    );
    if (draft == null || !context.mounted) return;
    await context.read<PortfolioCubit>().updateLot(
          trackedItemId: row.item.id,
          paidCents: draft.paidCents,
          purchasedAt: draft.purchasedAt,
          quantity: draft.quantity,
          foil: draft.foil,
          language: draft.language,
          condition: draft.condition,
          notes: draft.notes,
        );
  }

  Future<void> _sell(BuildContext context, TrackedRow row) async {
    final draft = await showSellLotSheet(
      context,
      cardName: row.card.name,
      suggestedCents: row.ctNowCents ?? row.cmNowCents,
    );
    if (draft == null || !context.mounted) return;
    await context.read<PortfolioCubit>().markSold(
          trackedItemId: row.item.id,
          soldCents: draft.soldCents,
          soldAt: draft.soldAt,
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PortfolioCubit, PortfolioState>(
          listenWhen: (p, n) =>
              n.snackMessage != null && n.snackMessage != p.snackMessage,
          listener: (context, state) {
            final msg = state.snackMessage;
            if (msg == null) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () => context.go('/watchlist'),
                ),
              ),
            );
            context.read<PortfolioCubit>().clearSnack();
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Portfolio'),
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
        body: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return BlocBuilder<PortfolioCubit, PortfolioState>(
              builder: (context, state) {
                if (state.status == PortfolioStatus.error) {
                  return Center(child: Text('Error: ${state.error}'));
                }
                if (state.status == PortfolioStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = state.rows;
                if (all.isEmpty) {
                  return EmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Portfolio is empty',
                    message:
                        'From Search, tap the wallet icon on a printing, enter what '
                        'you paid, and see if you are up or down vs CM trend / CT.',
                    actionLabel: 'Search cards',
                    onAction: () => context.go('/search'),
                  );
                }

                final rows = state.visible;
                final open = all.where((r) => !r.isSold).toList();
                final sold = all.where((r) => r.isSold).toList();
                final invested =
                    open.fold<int>(0, (s, r) => s + r.costBasisCents);
                final realized = sold.fold<int>(
                  0,
                  (s, r) => s + (r.realizedPnlCents ?? 0),
                );
                var cmValue = 0;
                var ctValue = 0;
                var cmKnown = true;
                var ctKnown = true;
                for (final r in open) {
                  final cm = r.cmValueCents;
                  final ct = r.ctValueCents;
                  if (cm == null) {
                    cmKnown = false;
                  } else {
                    cmValue += cm;
                  }
                  if (ct == null) {
                    ctKnown = false;
                  } else {
                    ctValue += ct;
                  }
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: rows.length + 3,
                  itemBuilder: (context, i) {
                    if (i == 0) {
                      return _PortfolioSummary(
                        openCount: open.length,
                        soldCount: sold.length,
                        investedCents: invested,
                        cmValueCents: cmKnown ? cmValue : null,
                        ctValueCents: ctKnown ? ctValue : null,
                        cmPnlCents: cmKnown ? cmValue - invested : null,
                        ctPnlCents: ctKnown ? ctValue - invested : null,
                        realizedPnlCents: sold.isEmpty ? null : realized,
                      );
                    }
                    if (i == 1) {
                      return _FilterBar(
                        sort: state.sort,
                        filter: state.filter,
                        onSort: (s) =>
                            context.read<PortfolioCubit>().setSort(s),
                        onFilter: (f) =>
                            context.read<PortfolioCubit>().setFilter(f),
                      );
                    }
                    if (i == 2) {
                      return SectionHeader(
                        title:
                            '${rows.length} lot${rows.length == 1 ? '' : 's'}',
                        subtitle: LandedCost.explain(
                          zeroFeeCents: settings.zeroFeeCents,
                          directShippingCents: settings.directShippingCents,
                        ),
                      );
                    }
                    final row = rows[i - 3];
                    final cubit = context.read<PortfolioCubit>();
                    return _TrackedCard(
                      row: row,
                      zeroFeeCents: settings.zeroFeeCents,
                      directShippingCents: settings.directShippingCents,
                      onOpen: () => context.push('/card/${row.card.id}'),
                      onEdit: () => _edit(context, row),
                      onSell: row.isSold ? null : () => _sell(context, row),
                      onWatchlist: () => cubit.addToWatchlist(row),
                      onDelete: () => cubit.remove(row.item.id),
                      onReopen: row.isSold
                          ? () => cubit.reopen(row.item.id)
                          : null,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.sort,
    required this.filter,
    required this.onSort,
    required this.onFilter,
  });

  final PortfolioSort sort;
  final PortfolioFilter filter;
  final ValueChanged<PortfolioSort> onSort;
  final ValueChanged<PortfolioFilter> onFilter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final f in PortfolioFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(switch (f) {
                        PortfolioFilter.open => 'Open',
                        PortfolioFilter.sold => 'Sold',
                        PortfolioFilter.all => 'All',
                        PortfolioFilter.foil => 'Foil',
                        PortfolioFilter.thisMonth => 'This month',
                      }),
                      selected: filter == f,
                      onSelected: (_) => onFilter(f),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: DropdownButton<PortfolioSort>(
              value: sort,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(
                  value: PortfolioSort.newest,
                  child: Text('Sort: newest'),
                ),
                DropdownMenuItem(
                  value: PortfolioSort.biggestLoser,
                  child: Text('Sort: biggest loser'),
                ),
                DropdownMenuItem(
                  value: PortfolioSort.biggestWinner,
                  child: Text('Sort: biggest winner'),
                ),
                DropdownMenuItem(
                  value: PortfolioSort.name,
                  child: Text('Sort: name'),
                ),
              ],
              onChanged: (v) {
                if (v != null) onSort(v);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.openCount,
    required this.soldCount,
    required this.investedCents,
    required this.cmValueCents,
    required this.ctValueCents,
    required this.cmPnlCents,
    required this.ctPnlCents,
    required this.realizedPnlCents,
  });

  final int openCount;
  final int soldCount;
  final int investedCents;
  final int? cmValueCents;
  final int? ctValueCents;
  final int? cmPnlCents;
  final int? ctPnlCents;
  final int? realizedPnlCents;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GlowCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Portfolio',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            '$openCount open · $soldCount sold',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PricePill(
                label: 'Invested',
                value: formatEurCents(investedCents),
                compact: true,
              ),
              PricePill(
                label: 'CM now',
                value: formatEurCents(cmValueCents),
                tone: PriceTone.cm,
                compact: true,
              ),
              PricePill(
                label: 'CT now',
                value: formatEurCents(ctValueCents),
                tone: PriceTone.ct,
                compact: true,
              ),
              PricePill(
                label: 'CM P&L',
                value: formatSignedEurCents(cmPnlCents),
                tone: (cmPnlCents ?? 0) >= 0 ? PriceTone.up : PriceTone.down,
                compact: true,
              ),
              PricePill(
                label: 'CT P&L',
                value: formatSignedEurCents(ctPnlCents),
                tone: (ctPnlCents ?? 0) >= 0 ? PriceTone.up : PriceTone.down,
                compact: true,
              ),
              if (realizedPnlCents != null)
                PricePill(
                  label: 'Realized',
                  value: formatSignedEurCents(realizedPnlCents),
                  tone: (realizedPnlCents ?? 0) >= 0
                      ? PriceTone.up
                      : PriceTone.down,
                  compact: true,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrackedCard extends StatelessWidget {
  const _TrackedCard({
    required this.row,
    required this.zeroFeeCents,
    required this.directShippingCents,
    required this.onOpen,
    required this.onEdit,
    required this.onSell,
    required this.onWatchlist,
    required this.onDelete,
    this.onReopen,
  });

  final TrackedRow row;
  final int zeroFeeCents;
  final int directShippingCents;
  final VoidCallback onOpen;
  final VoidCallback onEdit;
  final VoidCallback? onSell;
  final VoidCallback onWatchlist;
  final VoidCallback onDelete;
  final VoidCallback? onReopen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pnl = row.ctPnlCents ?? row.cmPnlCents;
    final accent = pnl == null
        ? null
        : pnl >= 0
            ? AppTheme.spreadUp
            : AppTheme.spreadDown;

    final meta = <Widget>[
      if (row.isSold)
        const FilterChipLabel(text: 'Sold', icon: Icons.check_circle),
      if (row.item.foil == true)
        const FilterChipLabel(text: 'Foil', icon: Icons.auto_awesome),
      if (row.item.foil == false) const FilterChipLabel(text: 'Non-foil'),
      if (row.item.language != null && row.item.language!.isNotEmpty)
        FilterChipLabel(text: row.item.language!.toUpperCase()),
      if (row.item.condition != null && row.item.condition!.isNotEmpty)
        FilterChipLabel(text: row.item.condition!),
      FilterChipLabel(
        text: _day.format(row.item.purchasedAt),
        icon: Icons.event,
      ),
      if (row.isSold && row.item.soldAt != null)
        FilterChipLabel(
          text: 'Sold ${_day.format(row.item.soldAt!)}',
          icon: Icons.sell,
        ),
    ];

    return GlowCard(
      margin: const EdgeInsets.only(bottom: 12),
      accent: accent,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CardThumb(
                url: row.card.imageUrl,
                width: 68,
                height: 94,
                heroTag: 'tracked-art-${row.item.id}',
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.card.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      [
                        if (row.card.expansion.isNotEmpty) row.card.expansion,
                        '×${row.item.quantity}',
                        'paid ${formatEurCents(row.item.paidCents)}/ea',
                        if (row.isSold)
                          'sold ${formatEurCents(row.item.soldCents)}/ea',
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(spacing: 6, runSpacing: 6, children: meta),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        PricePill(
                          label: row.isSold ? 'Proceeds' : 'Paid',
                          value: formatEurCents(
                            row.isSold
                                ? row.saleProceedsCents
                                : row.costBasisCents,
                          ),
                          compact: true,
                        ),
                        if (!row.isSold) ...[
                          PricePill(
                            label: 'CM',
                            value: formatEurCents(row.cmNowCents),
                            tone: PriceTone.cm,
                            compact: true,
                          ),
                          PricePill(
                            label: 'CT',
                            value: formatEurCents(row.ctNowCents),
                            tone: PriceTone.ct,
                            compact: true,
                          ),
                        ],
                        if (row.cmPnlCents != null)
                          PricePill(
                            label: row.isSold ? 'Realized' : 'CM Δ',
                            value:
                                '${formatSignedEurCents(row.cmPnlCents)}'
                                '${row.cmPnlPct == null ? '' : ' (${formatPct(row.cmPnlPct)})'}',
                            tone: (row.cmPnlCents ?? 0) >= 0
                                ? PriceTone.up
                                : PriceTone.down,
                            compact: true,
                          ),
                        if (!row.isSold && row.ctPnlCents != null)
                          PricePill(
                            label: 'CT Δ',
                            value:
                                '${formatSignedEurCents(row.ctPnlCents)}'
                                '${row.ctPnlPct == null ? '' : ' (${formatPct(row.ctPnlPct)})'}',
                            tone: (row.ctPnlCents ?? 0) >= 0
                                ? PriceTone.up
                                : PriceTone.down,
                            compact: true,
                          ),
                      ],
                    ),
                    if (!row.isSold) ...[
                      const SizedBox(height: 8),
                      LandedCostPills(
                        zeroListCents: row.item.lastCtZeroCents,
                        directListCents: row.item.lastCtDirectCents,
                        zeroFeeCents: zeroFeeCents,
                        directShippingCents: directShippingCents,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (!row.isSold) ...[
            const SizedBox(height: 10),
            MonthPriceSparkline(
              cmSnapshots: row.cmMonth,
              ctSnapshots: row.ctMonth,
              latestCm: row.latestCm,
              cmTrendOverrideCents: row.item.lastCmTrendCents,
              cmAvg7OverrideCents: row.item.lastCmAvg7Cents,
              cmAvg30OverrideCents: row.item.lastCmAvg30Cents,
              ctBestOverrideCents: row.ctNowCents,
              ctHistoryCents: [
                for (final s in row.lotSnapshots)
                  if (s.ctBestCents != null) (s.capturedAt, s.ctBestCents!),
              ],
              preferCmGuideSlope: true,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Edit'),
              ),
              if (onSell != null)
                TextButton.icon(
                  onPressed: onSell,
                  icon: const Icon(Icons.sell_outlined, size: 18),
                  label: const Text('Sell'),
                ),
              if (onReopen != null)
                TextButton.icon(
                  onPressed: onReopen,
                  icon: const Icon(Icons.undo, size: 18),
                  label: const Text('Reopen'),
                ),
              TextButton.icon(
                onPressed: onWatchlist,
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('Watch'),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Delete'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
