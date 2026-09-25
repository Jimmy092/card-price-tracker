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
    int? onlyCardId,
  }) async {
    final runId = await db.startSyncRun('cardtrader');
    var count = 0;
    try {
      final entries = (await db.allPriceSyncTargets(onlyCardId: onlyCardId))
          .where((e) => e.card.cardTraderBlueprintId != null)
          .toList();
      onProgress?.call('Syncing ${entries.length} CardTrader blueprints…');

      for (final entry in entries) {
        final card = entry.card;
        final bp = card.cardTraderBlueprintId!;
        final minCond = CardCondition.tryParse(entry.minCondition);
        final foilLabel = entry.foil == true
            ? 'foil'
            : entry.foil == false
                ? 'non-foil'
                : 'any foil';
        onProgress?.call('CT: ${card.name} ($foilLabel)');

        final summary = await ct.marketplaceForBlueprint(
          bp,
          foil: entry.foil,
          language: entry.language,
          minCondition: minCond,
          sellerName: entry.sellerName,
          minQuantity: entry.minSellerQuantity,
        );

        // Backfill image from CT blueprint when missing.
        if (card.imageUrl == null || card.imageUrl!.isEmpty) {
          final expansionId = card.cardTraderExpansionId;
          if (expansionId != null) {
            try {
              final list = await ct.listBlueprints(expansionId);
              CtBlueprint? match;
              for (final b in list) {
                if (b.id == bp) {
                  match = b;
                  break;
                }
              }
              final url = match?.absoluteImageUrl;
              if (url != null && url.isNotEmpty) {
                await (db.update(db.cards)..where((t) => t.id.equals(card.id)))
                    .write(CardsCompanion(imageUrl: Value(url)));
              }
            } catch (_) {}
          }
        }

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
    int? onlyCardId,
  }) async {
    final runId = await db.startSyncRun('cardmarket');
    var count = 0;
    try {
      if (download && productsPath == null && priceGuidePath == null) {
        final status = await cm.cacheStatus();
        if (!status.ready) {
          await cm.downloadGuides(onProgress: onProgress);
        } else {
          onProgress?.call('Using cached Cardmarket guides…');
        }
      }

      onProgress?.call('Loading Cardmarket catalogue…');
      final products = await cm.loadProducts(overridePath: productsPath);
      onProgress?.call('Loading Cardmarket price guide…');
      final guides = await cm.loadPriceGuide(overridePath: priceGuidePath);

      final entries =
          await db.allPriceSyncTargets(onlyCardId: onlyCardId);

      // cardId -> entry (for foil preference when writing snapshots)
      final byCardId = {for (final e in entries) e.card.id: e};

      final byCmId = <int, Card>{
        for (final e in entries)
          if (e.card.cardmarketProductId != null)
            e.card.cardmarketProductId!: e.card,
      };

      // Link CM product ids by name when missing.
      for (final entry in entries) {
        final card = entry.card;
        if (card.cardmarketProductId != null) continue;
        CmProduct? match;
        final nameLower = card.name.toLowerCase();
        for (final p in products.values) {
          if (p.name.toLowerCase() == nameLower) {
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
      for (final mapEntry in byCmId.entries) {
        final productId = mapEntry.key;
        final card = mapEntry.value;
        final guide = guides[productId];
        if (guide == null) continue;
        final foilPref = byCardId[card.id]?.foil;
        final cents = guide.centsFor(foil: foilPref);
        await db.into(db.priceSnapshots).insert(
              PriceSnapshotsCompanion.insert(
                cardId: card.id,
                source: 'cardmarket',
                capturedAt: now,
                cmTrendCents: Value(cents.trend),
                cmLowCents: Value(cents.low),
                cmAvgCents: Value(cents.avg),
                cmAvg7Cents: Value(cents.avg7),
                cmAvg30Cents: Value(cents.avg30),
              ),
            );
        count++;
      }

      await db.finishSyncRun(
        runId,
        status: 'ok',
        message:
            'CM snapshots for $count cards (${products.length} products, ${guides.length} prices cached)',
        itemCount: count,
      );
      return SyncOutcome.ok(
        'Cardmarket: $count prices updated',
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

  /// Refresh CT + CM prices for one card (watchlist or tracking add).
  Future<SyncOutcome> syncWatchlistCard(
    int cardId, {
    void Function(String message)? onProgress,
  }) async {
    final ctResult = await syncCardTraderWatchlist(
      onProgress: onProgress,
      onlyCardId: cardId,
    );
    if (!ctResult.success) return ctResult;

    try {
      final cmResult = await syncCardmarketGuides(
        download: true,
        onProgress: onProgress,
        onlyCardId: cardId,
      );
      final portfolio = await syncPortfolioLots(
        onProgress: onProgress,
        onlyCardId: cardId,
      );
      if (!cmResult.success) {
        return SyncOutcome.ok(
          '${ctResult.message}; Cardmarket skipped: ${cmResult.message}',
        );
      }
      return SyncOutcome.ok(
        '${ctResult.message}; ${cmResult.message}; ${portfolio.message}',
      );
    } catch (e) {
      return SyncOutcome.ok('${ctResult.message}; Cardmarket skipped: $e');
    }
  }

  /// Value each portfolio lot with its own foil / language / condition.
  ///
  /// Writes lot-specific columns so foil purchases are never priced with
  /// non-foil guides or marketplace mins.
  Future<SyncOutcome> syncPortfolioLots({
    void Function(String message)? onProgress,
    int? onlyCardId,
  }) async {
    final runId = await db.startSyncRun('portfolio');
    var count = 0;
    try {
      final ready = await cm.ensureLookupReady();
      final lots = (await db.allTrackedEntries())
          .where((e) => onlyCardId == null || e.card.id == onlyCardId)
          .toList();
      onProgress?.call('Valuing ${lots.length} portfolio lots…');

      for (final entry in lots) {
        final card = entry.card;
        final lot = entry.item;
        final foilLabel = lot.foil == true
            ? 'foil'
            : lot.foil == false
                ? 'non-foil'
                : 'any';
        onProgress?.call('Portfolio: ${card.name} ($foilLabel)');

        int? cmTrend;
        int? cmLow;
        int? cmAvg;
        int? cmAvg7;
        int? cmAvg30;
        if (ready) {
          final productId = card.cardmarketProductId;
          final guide = productId == null
              ? null
              : cm.guideForProductId(productId);
          if (guide != null) {
            final cents = guide.centsFor(foil: lot.foil);
            cmTrend = cents.trend;
            cmLow = cents.low;
            cmAvg = cents.avg;
            cmAvg7 = cents.avg7;
            cmAvg30 = cents.avg30;
          } else {
            cmTrend = cm.trendCentsForPrinting(
              name: card.name,
              setName: card.expansion,
              foil: lot.foil,
              cardmarketId: card.cardmarketProductId,
            );
          }
        }

        int? ctZero;
        int? ctDirect;
        int? ctBest;
        final bp = card.cardTraderBlueprintId;
        if (bp != null) {
          final summary = await ct.marketplaceForBlueprint(
            bp,
            foil: lot.foil,
            language: lot.language,
            minCondition: CardCondition.tryParse(lot.condition),
          );
          ctZero = summary.minZeroCents;
          ctDirect = summary.minDirectCents;
          ctBest = summary.bestPriceCents;

          await db.into(db.priceSnapshots).insert(
                PriceSnapshotsCompanion.insert(
                  cardId: card.id,
                  source: 'cardtrader',
                  capturedAt: DateTime.now(),
                  ctMinDirectCents: Value(ctDirect),
                  ctMinZeroCents: Value(ctZero),
                  ctListingCount: Value(summary.listingCount),
                  ctZeroListingCount: Value(summary.zeroListingCount),
                ),
              );
        }

        if (cmTrend != null || cmLow != null) {
          await db.into(db.priceSnapshots).insert(
                PriceSnapshotsCompanion.insert(
                  cardId: card.id,
                  source: 'cardmarket',
                  capturedAt: DateTime.now(),
                  cmTrendCents: Value(cmTrend),
                  cmLowCents: Value(cmLow),
                  cmAvgCents: Value(cmAvg),
                  cmAvg7Cents: Value(cmAvg7),
                  cmAvg30Cents: Value(cmAvg30),
                ),
              );
        }

        await db.updateTrackedLotValuation(
          trackedItemId: lot.id,
          cmTrendCents: cmTrend,
          cmAvg7Cents: cmAvg7,
          cmAvg30Cents: cmAvg30,
          ctBestCents: ctBest,
          ctZeroCents: ctZero,
          ctDirectCents: ctDirect,
        );
        await db.insertTrackedLotSnapshot(
          trackedItemId: lot.id,
          cmTrendCents: cmTrend,
          cmAvg7Cents: cmAvg7,
          cmAvg30Cents: cmAvg30,
          ctBestCents: ctBest,
        );
        count++;
        await Future<void>.delayed(const Duration(milliseconds: 120));
      }

      await db.finishSyncRun(
        runId,
        status: 'ok',
        message: 'Valued $count portfolio lots',
        itemCount: count,
      );
      return SyncOutcome.ok('Portfolio: $count lots valued');
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
    final portfolio = await syncPortfolioLots(onProgress: onProgress);
    if (!portfolio.success) return portfolio;
    return SyncOutcome.ok(
      '${cmResult.message}; ${ctResult.message}; ${portfolio.message}',
    );
  }
}

class SyncOutcome {
  SyncOutcome._(this.success, this.message);
  factory SyncOutcome.ok(String message) => SyncOutcome._(true, message);
  factory SyncOutcome.error(String message) => SyncOutcome._(false, message);
  final bool success;
  final String message;
}
