/// Rough EU landed-cost helpers for CardTrader (not official fee schedule).
class LandedCost {
  LandedCost._();

  /// Default Zero hub add-on per order (EUR cents).
  static const defaultZeroFeeCents = 50;

  /// Default direct single-seller shipping estimate (EUR cents).
  static const defaultDirectShippingCents = 180;

  static int? zeroLandedCents(
    int? listCents, {
    int feeCents = defaultZeroFeeCents,
  }) {
    if (listCents == null) return null;
    return listCents + feeCents;
  }

  static int? directLandedCents(
    int? listCents, {
    int shippingCents = defaultDirectShippingCents,
  }) {
    if (listCents == null) return null;
    return listCents + shippingCents;
  }

  static String explain({
    int zeroFeeCents = defaultZeroFeeCents,
    int directShippingCents = defaultDirectShippingCents,
  }) {
    final z = (zeroFeeCents / 100).toStringAsFixed(2);
    final d = (directShippingCents / 100).toStringAsFixed(2);
    return 'Estimates only: Zero +€$z hub fee · Direct +€$d shipping. '
        'Real postage varies by seller.';
  }
}
