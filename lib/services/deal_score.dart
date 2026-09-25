/// CT asking vs CM reference → simple under/over market badge.
enum DealTier { steal, good, fair, rich, unknown }

class DealScore {
  DealScore({
    required this.tier,
    required this.pct,
    required this.label,
    this.ctCents,
    this.cmCents,
  });

  final DealTier tier;
  final double? pct;
  final String label;
  final int? ctCents;
  final int? cmCents;

  /// Prefer CM From (low); fall back to trend.
  factory DealScore.fromPrices({
    required int? ctBestCents,
    int? cmFromCents,
    int? cmTrendCents,
  }) {
    final cm = cmFromCents ?? cmTrendCents;
    final ct = ctBestCents;
    if (cm == null || ct == null || cm == 0) {
      return DealScore(
        tier: DealTier.unknown,
        pct: null,
        label: 'No deal score',
        ctCents: ct,
        cmCents: cm,
      );
    }
    final pct = ((ct - cm) / cm) * 100;
    if (pct <= -12) {
      return DealScore(
        tier: DealTier.steal,
        pct: pct,
        label: 'Steal',
        ctCents: ct,
        cmCents: cm,
      );
    }
    if (pct <= -5) {
      return DealScore(
        tier: DealTier.good,
        pct: pct,
        label: 'Good deal',
        ctCents: ct,
        cmCents: cm,
      );
    }
    if (pct <= 5) {
      return DealScore(
        tier: DealTier.fair,
        pct: pct,
        label: 'Fair',
        ctCents: ct,
        cmCents: cm,
      );
    }
    return DealScore(
      tier: DealTier.rich,
      pct: pct,
      label: 'Rich',
      ctCents: ct,
      cmCents: cm,
    );
  }
}
