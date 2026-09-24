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
      final entries = (await db.allWatchlistEntries())
          .where((e) => e.card.cardTraderBlueprintId != null)
          .where((e) => onlyCardId == null || e.card.id == onlyCardId)
          .toList();
      onProgress?.call('Syncing ${entries.length} CardTrader blueprints…');

      for (final entry in entries) {
        final card = entry.card;
        final item = entry.item;
        final bp = card.cardTraderBlueprintId!;
        final minCond = CardCondition.tryParse(item.minCondition);
        final foilLabel = item.foil == true
            ? 'foil'
            : item.foil == false
                ? 'non-foil'
                : 'any foil';
        onProgress?.call('CT: ${card.name} ($foilLabel)');

        final summary = await ct.marketplaceForBlueprint(
          bp,
          foil: item.foil,
          language: item.language,
          minCondition: minCond,
          sellerName: item.sellerName,
          minQuantity: item.minSellerQuantity,
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

      final entries = (await db.allWatchlistEntries())
          .where((e) => onlyCardId == null || e.card.id == onlyCardId)
          .toList();

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
        final foilPref = byCardId[card.id]?.item.foil;
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

  /// Refresh CT + CM prices for one watchlist card (used right after Add).
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
      if (!cmResult.success) {
        return SyncOutcome.ok(
          '${ctResult.message}; Cardmarket skipped: ${cmResult.message}',
        );
      }
      return SyncOutcome.ok('${ctResult.message}; ${cmResult.message}');
    } catch (e) {
      return SyncOutcome.ok('${ctResult.message}; Cardmarket skipped: $e');
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
