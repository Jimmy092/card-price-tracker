import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../services/deal_score.dart';
import '../services/landed_cost.dart';
import 'price_format.dart';
import 'ui_kit.dart';

class DealScoreBadge extends StatelessWidget {
  const DealScoreBadge({super.key, required this.score});

  final DealScore score;

  @override
  Widget build(BuildContext context) {
    if (score.tier == DealTier.unknown) {
      return const SizedBox.shrink();
    }
    final color = switch (score.tier) {
      DealTier.steal => AppTheme.spreadUp,
      DealTier.good => AppTheme.ctTeal,
      DealTier.fair => Colors.blueGrey,
      DealTier.rich => AppTheme.spreadDown,
      DealTier.unknown => Colors.grey,
    };
    final pct = score.pct;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        pct == null
            ? score.label
            : '${score.label} · ${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(0)}%',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class LandedCostPills extends StatelessWidget {
  const LandedCostPills({
    super.key,
    required this.zeroListCents,
    required this.directListCents,
    this.zeroFeeCents = LandedCost.defaultZeroFeeCents,
    this.directShippingCents = LandedCost.defaultDirectShippingCents,
  });

  final int? zeroListCents;
  final int? directListCents;
  final int zeroFeeCents;
  final int directShippingCents;

  @override
  Widget build(BuildContext context) {
    final zero = LandedCost.zeroLandedCents(zeroListCents, feeCents: zeroFeeCents);
    final direct = LandedCost.directLandedCents(
      directListCents,
      shippingCents: directShippingCents,
    );
    if (zero == null && direct == null) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        if (zero != null)
          PricePill(
            label: 'Zero landed',
            value: formatEurCents(zero),
            tone: PriceTone.ct,
            compact: true,
          ),
        if (direct != null)
          PricePill(
            label: 'Direct landed',
            value: formatEurCents(direct),
            tone: PriceTone.neutral,
            compact: true,
          ),
      ],
    );
  }
}
