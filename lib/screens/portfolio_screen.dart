import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../app/theme.dart';
import '../data/database.dart';
import '../services/sync_service.dart';
import '../widgets/card_thumb.dart';
import '../widgets/month_price_sparkline.dart';
import '../widgets/price_format.dart';
import '../widgets/ui_kit.dart';

final _day = DateFormat.yMMMd();

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Portfolio'),
        actions: [
          SyncActionButton(syncing: _syncing, onPressed: _syncAll),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<TrackedRow>>(
        stream: db.watchTracked(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final rows = snapshot.data!;
          if (rows.isEmpty) {
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

          final invested = rows.fold<int>(0, (s, r) => s + r.costBasisCents);
          var cmValue = 0;
          var ctValue = 0;
          var cmKnown = true;
          var ctKnown = true;
          for (final r in rows) {
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
          final cmPnl = cmKnown ? cmValue - invested : null;
          final ctPnl = ctKnown ? ctValue - invested : null;

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: rows.length + 2,
            itemBuilder: (context, i) {
              if (i == 0) {
                return _PortfolioSummary(
                  lotCount: rows.length,
                  investedCents: invested,
                  cmValueCents: cmKnown ? cmValue : null,
                  ctValueCents: ctKnown ? ctValue : null,
                  cmPnlCents: cmPnl,
                  ctPnlCents: ctPnl,
                );
              }
              if (i == 1) {
                return SectionHeader(
                  title: '${rows.length} lot${rows.length == 1 ? '' : 's'}',
                  subtitle: 'Paid vs current CM trend · CT best',
                );
              }
              final row = rows[i - 2];
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
                child: _TrackedCard(
                  row: row,
                  onOpen: () => context.push('/card/${row.card.id}'),
                  onDelete: () => db.removeTrackedItem(row.item.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PortfolioSummary extends StatelessWidget {
  const _PortfolioSummary({
    required this.lotCount,
    required this.investedCents,
    required this.cmValueCents,
    required this.ctValueCents,
    required this.cmPnlCents,
    required this.ctPnlCents,
  });

  final int lotCount;
  final int investedCents;
  final int? cmValueCents;
  final int? ctValueCents;
  final int? cmPnlCents;
  final int? ctPnlCents;

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
          const SizedBox(height: 4),
          Text(
            '$lotCount purchase lot${lotCount == 1 ? '' : 's'}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
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
    required this.onOpen,
    required this.onDelete,
  });

  final TrackedRow row;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

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
    ];

    final hasPrices = row.cmNowCents != null || row.ctNowCents != null;

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
            heroTag: 'tracked-art-${row.item.id}',
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
                    'paid ${formatEurCents(row.item.paidCents)}/ea',
                  ].join(' · '),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, runSpacing: 6, children: meta),
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
                        label: 'Paid',
                        value: formatEurCents(row.costBasisCents),
                        compact: true,
                      ),
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
                      if (row.cmPnlCents != null)
                        PricePill(
                          label: 'CM Δ',
                          value:
                              '${formatSignedEurCents(row.cmPnlCents)}'
                              '${row.cmPnlPct == null ? '' : ' (${formatPct(row.cmPnlPct)})'}',
                          tone: (row.cmPnlCents ?? 0) >= 0
                              ? PriceTone.up
                              : PriceTone.down,
                          compact: true,
                        ),
                      if (row.ctPnlCents != null)
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
