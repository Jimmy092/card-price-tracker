import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Games, Cards, WatchlistItems, PriceSnapshots, SyncRuns])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'card_price_tracker'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await into(games).insert(
            GamesCompanion.insert(
              id: 'mtg',
              name: 'Magic: The Gathering',
              cardTraderGameId: const Value(1),
              cardmarketGameId: const Value(1),
            ),
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(cards, cards.imageUrl);
          }
          if (from < 3) {
            await m.addColumn(watchlistItems, watchlistItems.foil);
            await m.addColumn(watchlistItems, watchlistItems.language);
            await m.addColumn(watchlistItems, watchlistItems.minCondition);
          }
        },
      );

  // --- Watchlist ---

  Stream<List<WatchlistRow>> watchWatchlist() {
    final query = select(watchlistItems).join([
      innerJoin(cards, cards.id.equalsExp(watchlistItems.cardId)),
    ])
      ..orderBy([OrderingTerm.asc(cards.name)]);

    return query.watch().asyncMap((rows) async {
      final result = <WatchlistRow>[];
      for (final row in rows) {
        final item = row.readTable(watchlistItems);
        final card = row.readTable(cards);
        final latestCm = await _latestSnapshot(card.id, 'cardmarket');
        final latestCt = await _latestSnapshot(card.id, 'cardtrader');
        final prevCm = await _previousSnapshot(card.id, 'cardmarket');
        result.add(
          WatchlistRow(
            item: item,
            card: card,
            latestCm: latestCm,
            latestCt: latestCt,
            previousCm: prevCm,
          ),
        );
      }
      return result;
    });
  }

  Future<PriceSnapshot?> _latestSnapshot(int cardId, String source) {
    return (select(priceSnapshots)
          ..where(
            (t) => t.cardId.equals(cardId) & t.source.equals(source),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<PriceSnapshot?> _previousSnapshot(int cardId, String source) {
    return (select(priceSnapshots)
          ..where(
            (t) => t.cardId.equals(cardId) & t.source.equals(source),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
          ..limit(1, offset: 1))
        .getSingleOrNull();
  }

  Future<List<PriceSnapshot>> snapshotsForCard(int cardId, {String? source}) {
    final q = select(priceSnapshots)
      ..where((t) {
        if (source == null) return t.cardId.equals(cardId);
        return t.cardId.equals(cardId) & t.source.equals(source);
      })
      ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]);
    return q.get();
  }

  Future<Card?> findCardByCtBlueprint(int blueprintId) {
    return (select(cards)
          ..where((t) => t.cardTraderBlueprintId.equals(blueprintId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<Card?> findCardByCmProduct(int productId) {
    return (select(cards)
          ..where((t) => t.cardmarketProductId.equals(productId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> upsertWatchlistCard({
    required String name,
    required String expansion,
    int? cardTraderBlueprintId,
    int? cardTraderExpansionId,
    int? cardmarketProductId,
    String? imageUrl,
    bool? foil,
    String? language,
    String? minCondition,
    int quantity = 1,
    String notes = '',
  }) async {
    final existing = cardTraderBlueprintId != null
        ? await findCardByCtBlueprint(cardTraderBlueprintId)
        : cardmarketProductId != null
            ? await findCardByCmProduct(cardmarketProductId)
            : null;

    late final int cardId;
    if (existing != null) {
      cardId = existing.id;
      await (update(cards)..where((t) => t.id.equals(cardId))).write(
        CardsCompanion(
          name: Value(name),
          expansion: Value(expansion),
          imageUrl: imageUrl != null && imageUrl.isNotEmpty
              ? Value(imageUrl)
              : const Value.absent(),
          cardTraderBlueprintId: cardTraderBlueprintId != null
              ? Value(cardTraderBlueprintId)
              : const Value.absent(),
          cardTraderExpansionId: cardTraderExpansionId != null
              ? Value(cardTraderExpansionId)
              : const Value.absent(),
          cardmarketProductId: cardmarketProductId != null
              ? Value(cardmarketProductId)
              : const Value.absent(),
        ),
      );
    } else {
      cardId = await into(cards).insert(
        CardsCompanion.insert(
          gameId: 'mtg',
          name: name,
          expansion: Value(expansion),
          imageUrl: Value(imageUrl),
          cardTraderBlueprintId: Value(cardTraderBlueprintId),
          cardTraderExpansionId: Value(cardTraderExpansionId),
          cardmarketProductId: Value(cardmarketProductId),
        ),
      );
    }

    final existingItem = await (select(watchlistItems)
          ..where((t) => t.cardId.equals(cardId))
          ..limit(1))
        .getSingleOrNull();
    if (existingItem == null) {
      await into(watchlistItems).insert(
        WatchlistItemsCompanion.insert(
          cardId: cardId,
          quantity: Value(quantity),
          notes: Value(notes),
          foil: Value(foil),
          language: Value(language),
          minCondition: Value(minCondition),
        ),
      );
    } else {
      // Update listing preferences when re-adding the same printing.
      await (update(watchlistItems)..where((t) => t.id.equals(existingItem.id)))
          .write(
        WatchlistItemsCompanion(
          foil: Value(foil),
          language: Value(language),
          minCondition: Value(minCondition),
        ),
      );
    }
    return cardId;
  }

  /// Watchlist cards joined with their listing filter preferences.
  Future<List<WatchlistEntry>> allWatchlistEntries() async {
    final q = select(watchlistItems).join([
      innerJoin(cards, cards.id.equalsExp(watchlistItems.cardId)),
    ]);
    final rows = await q.get();
    return rows
        .map(
          (r) => WatchlistEntry(
            card: r.readTable(cards),
            item: r.readTable(watchlistItems),
          ),
        )
        .toList();
  }

  Future<Card?> getCard(int id) {
    return (select(cards)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<WatchlistItem?> getWatchlistItemForCard(int cardId) {
    return (select(watchlistItems)
          ..where((t) => t.cardId.equals(cardId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> removeFromWatchlist(int watchlistItemId) async {
    await (delete(watchlistItems)..where((t) => t.id.equals(watchlistItemId)))
        .go();
  }

  Future<int> startSyncRun(String source) {
    return into(syncRuns).insert(
      SyncRunsCompanion.insert(
        source: source,
        startedAt: DateTime.now(),
        status: 'running',
      ),
    );
  }

  Future<void> finishSyncRun(
    int id, {
    required String status,
    String message = '',
    int itemCount = 0,
  }) {
    return (update(syncRuns)..where((t) => t.id.equals(id))).write(
      SyncRunsCompanion(
        finishedAt: Value(DateTime.now()),
        status: Value(status),
        message: Value(message),
        itemCount: Value(itemCount),
      ),
    );
  }

  Stream<List<SyncRun>> watchRecentSyncRuns({int limit = 10}) {
    return (select(syncRuns)
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(limit))
        .watch();
  }

  Future<List<Card>> allWatchlistCards() async {
    final q = select(cards).join([
      innerJoin(watchlistItems, watchlistItems.cardId.equalsExp(cards.id)),
    ]);
    final rows = await q.get();
    return rows.map((r) => r.readTable(cards)).toList();
  }

  Future<Map<int, Card>> cardsByCmProductIds(Iterable<int> ids) async {
    final idList = ids.toList();
    if (idList.isEmpty) return {};
    final rows = await (select(cards)
          ..where((t) => t.cardmarketProductId.isIn(idList)))
        .get();
    return {
      for (final c in rows)
        if (c.cardmarketProductId != null) c.cardmarketProductId!: c,
    };
  }
}

class WatchlistRow {
  WatchlistRow({
    required this.item,
    required this.card,
    this.latestCm,
    this.latestCt,
    this.previousCm,
  });

  final WatchlistItem item;
  final Card card;
  final PriceSnapshot? latestCm;
  final PriceSnapshot? latestCt;
  final PriceSnapshot? previousCm;

  double? get cmTrendChangePct {
    final cur = latestCm?.cmTrendCents;
    final prev = previousCm?.cmTrendCents;
    if (cur == null || prev == null || prev == 0) return null;
    return ((cur - prev) / prev) * 100;
  }
}

class WatchlistEntry {
  WatchlistEntry({required this.card, required this.item});
  final Card card;
  final WatchlistItem item;
}
