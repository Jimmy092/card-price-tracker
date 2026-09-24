import 'package:drift/drift.dart';

import '../data/database.dart';
import 'cardmarket_ingest.dart';
import 'cardtrader_client.dart';

/// Orchestrates throttled manual sync. Never blends CM and CT into one figure.
class SyncService {
  SyncService({
    required this.db,
    required this.ct,
    required this.cm,
  });

  final AppDatabase db;
  final CardTraderClient ct;
  final CardmarketIngest cm;

  Future<SyncOutcome> syncCardTraderWatchlist({
    void Function(String message)? onProgress,
  }) async {
    final runId = await db.startSyncRun('cardtrader');
    var count = 0;
    try {
      final cards = await db.allWatchlistCards();
      final withBlueprint =
          cards.where((c) => c.cardTraderBlueprintId != null).toList();
      onProgress?.call('Syncing ${withBlueprint.length} CardTrader blueprints…');

      for (final card in withBlueprint) {
        final bp = card.cardTraderBlueprintId!;
        onProgress?.call('CT: ${card.name}');
        final summary = await ct.marketplaceForBlueprint(bp);
        await db.into(db.priceSnapshots).insert(
              PriceSnapshotsCompanion.insert(
                cardId: card.id,
                source: 'cardtrader',
                capturedAt: DateTime.now(),
                ctMinDirectCents: Value(summary.minDirectCents),
                ctMinZeroCents: Value(summary.minZeroCents),
                ctListingCount: Value(summary.listingCount),
                ctZeroListingCount: Value(summary.zeroListingCount),
              ),
            );
        count++;
        // Light throttle to be polite to the API.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }

      await db.finishSyncRun(
        runId,
        status: 'ok',
        message: 'Updated $count CardTrader cards',
        itemCount: count,
      );
      return SyncOutcome.ok('Updated $count CardTrader cards');
    } catch (e) {
      await db.finishSyncRun(
        runId,
        status: 'error',
        message: e.toString(),
        itemCount: count,
      );
      return SyncOutcome.error(e.toString());
    }
  }

  Future<SyncOutcome> syncCardmarketGuides({
    bool download = true,
    String? productsPath,
    String? priceGuidePath,
    void Function(String message)? onProgress,
  }) async {
    final runId = await db.startSyncRun('cardmarket');
    var count = 0;
    try {
      if (download && productsPath == null && priceGuidePath == null) {
        await cm.downloadGuides(onProgress: onProgress);
      }

      onProgress?.call('Loading Cardmarket catalogue…');
      final products = await cm.loadProducts(overridePath: productsPath);
      onProgress?.call('Loading Cardmarket price guide…');
      final guides = await cm.loadPriceGuide(overridePath: priceGuidePath);

      final watchCards = await db.allWatchlistCards();
      final byCmId = <int, Card>{
        for (final c in watchCards)
          if (c.cardmarketProductId != null) c.cardmarketProductId!: c,
      };

      // Link CM product ids by name when missing.
      for (final card in watchCards) {
        if (card.cardmarketProductId != null) continue;
        CmProduct? match;
        for (final p in products.values) {
          if (p.name.toLowerCase() == card.name.toLowerCase()) {
            match = p;
            break;
          }
        }
        if (match != null) {
          await (db.update(db.cards)..where((t) => t.id.equals(card.id))).write(
            CardsCompanion(cardmarketProductId: Value(match.idProduct)),
          );
          byCmId[match.idProduct] = card;
        }
      }

      final now = DateTime.now();
      for (final entry in byCmId.entries) {
        final productId = entry.key;
        final card = entry.value;
        final guide = guides[productId];
        if (guide == null) continue;
        await db.into(db.priceSnapshots).insert(
              PriceSnapshotsCompanion.insert(
                cardId: card.id,
                source: 'cardmarket',
                capturedAt: now,
                cmTrendCents: Value(guide.trendCents),
                cmLowCents: Value(guide.lowCents),
                cmAvgCents: Value(guide.avgCents),
                cmAvg7Cents: Value(guide.avg7Cents),
                cmAvg30Cents: Value(guide.avg30Cents),
              ),
            );
        count++;
      }

      await db.finishSyncRun(
        runId,
        status: 'ok',
        message:
            'CM snapshots for $count watchlist cards (${products.length} products, ${guides.length} prices cached)',
        itemCount: count,
      );
      return SyncOutcome.ok(
        'Cardmarket: $count watchlist prices updated',
      );
    } catch (e) {
      await db.finishSyncRun(
        runId,
        status: 'error',
        message: e.toString(),
        itemCount: count,
      );
      return SyncOutcome.error(e.toString());
    }
  }

  Future<SyncOutcome> syncAll({void Function(String message)? onProgress}) async {
    final cmResult = await syncCardmarketGuides(onProgress: onProgress);
    if (!cmResult.success) return cmResult;
    final ctResult = await syncCardTraderWatchlist(onProgress: onProgress);
    if (!ctResult.success) return ctResult;
    return SyncOutcome.ok('${cmResult.message}; ${ctResult.message}');
  }
}

class SyncOutcome {
  SyncOutcome._(this.success, this.message);
  factory SyncOutcome.ok(String message) => SyncOutcome._(true, message);
  factory SyncOutcome.error(String message) => SyncOutcome._(false, message);
  final bool success;
  final String message;
}
