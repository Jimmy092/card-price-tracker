import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Games,
    Cards,
    WatchlistItems,
    TrackedItems,
    PriceSnapshots,
    SyncRuns,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'card_price_tracker'));

  @override
  int get schemaVersion => 6;

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
          if (from < 4) {
            await m.addColumn(watchlistItems, watchlistItems.sellerName);
            await m.addColumn(watchlistItems, watchlistItems.minSellerQuantity);
          }
          if (from < 5) {
            await m.createTable(trackedItems);
          }
          if (from < 6) {
            await m.addColumn(trackedItems, trackedItems.lastCmTrendCents);
            await m.addColumn(trackedItems, trackedItems.lastCmAvg7Cents);
            await m.addColumn(trackedItems, trackedItems.lastCmAvg30Cents);
            await m.addColumn(trackedItems, trackedItems.lastCtBestCents);
            await m.addColumn(trackedItems, trackedItems.lastCtZeroCents);
            await m.addColumn(trackedItems, trackedItems.lastCtDirectCents);
            await m.addColumn(trackedItems, trackedItems.valuedAt);
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
      final cardsList = [
        for (final row in rows) row.readTable(cards),
      ];
      final historyByCard = await _monthHistoryByCardIds(
        cardsList.map((c) => c.id),
      );

      final result = <WatchlistRow>[];
      for (final row in rows) {
        final item = row.readTable(watchlistItems);
        final card = row.readTable(cards);
        final hist = historyByCard[card.id] ?? (<PriceSnapshot>[], <PriceSnapshot>[]);
        final latestCm = hist.$1.isEmpty
            ? await _latestSnapshot(card.id, 'cardmarket')
            : hist.$1.last;
        final latestCt = hist.$2.isEmpty
            ? await _latestSnapshot(card.id, 'cardtrader')
            : hist.$2.last;
        final prevCm = await _previousDistinctCmTrend(card.id, latestCm);
        result.add(
          WatchlistRow(
            item: item,
            card: card,
            latestCm: latestCm,
            latestCt: latestCt,
            previousCm: prevCm,
            cmMonth: hist.$1,
            ctMonth: hist.$2,
          ),
        );
      }
      return result;
    });
  }

  /// CM / CT snapshots from the last 30 days, plus the latest older ones so
  /// charts always have an anchor point.
  Future<Map<int, (List<PriceSnapshot>, List<PriceSnapshot>)>>
      _monthHistoryByCardIds(Iterable<int> cardIds) async {
    final ids = cardIds.toList();
    if (ids.isEmpty) return {};

    final since = DateTime.now().subtract(const Duration(days: 30));
    final recent = await (select(priceSnapshots)
          ..where(
            (t) =>
                t.cardId.isIn(ids) & t.capturedAt.isBiggerOrEqualValue(since),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
        .get();

    final cm = <int, List<PriceSnapshot>>{};
    final ct = <int, List<PriceSnapshot>>{};
    for (final s in recent) {
      if (s.source == 'cardmarket') {
        (cm[s.cardId] ??= []).add(s);
      } else if (s.source == 'cardtrader') {
        (ct[s.cardId] ??= []).add(s);
      }
    }

    // Ensure every card has at least the absolute latest snapshot per source.
    for (final id in ids) {
      if (cm[id] == null || cm[id]!.isEmpty) {
        final latest = await _latestSnapshot(id, 'cardmarket');
        if (latest != null) cm[id] = [latest];
      }
      if (ct[id] == null || ct[id]!.isEmpty) {
        final latest = await _latestSnapshot(id, 'cardtrader');
        if (latest != null) ct[id] = [latest];
      }
    }

    return {
      for (final id in ids) id: (cm[id] ?? <PriceSnapshot>[], ct[id] ?? <PriceSnapshot>[]),
    };
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

  /// Older CM snapshot with a different trend than [latest], for real history Δ.
  Future<PriceSnapshot?> _previousDistinctCmTrend(
    int cardId,
    PriceSnapshot? latest,
  ) async {
    if (latest?.cmTrendCents == null) return null;
    final rows = await (select(priceSnapshots)
          ..where(
            (t) => t.cardId.equals(cardId) & t.source.equals('cardmarket'),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
          ..limit(30))
        .get();
    for (final row in rows) {
      if (row.id == latest!.id) continue;
      if (row.cmTrendCents != null &&
          row.cmTrendCents != latest.cmTrendCents) {
        return row;
      }
    }
    return null;
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

  Stream<List<PriceSnapshot>> watchSnapshotsForCard(int cardId) {
    return (select(priceSnapshots)
          ..where((t) => t.cardId.equals(cardId))
          ..orderBy([(t) => OrderingTerm.asc(t.capturedAt)]))
        .watch();
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
    String? sellerName,
    int? minSellerQuantity,
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

    final seller = sellerName?.trim();
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
          sellerName: Value(
            seller == null || seller.isEmpty ? null : seller,
          ),
          minSellerQuantity: Value(minSellerQuantity),
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
          sellerName: Value(
            seller == null || seller.isEmpty ? null : seller,
          ),
          minSellerQuantity: Value(minSellerQuantity),
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

  // --- Portfolio tracking (purchase lots) ---

  Stream<List<TrackedRow>> watchTracked() {
    final query = select(trackedItems).join([
      innerJoin(cards, cards.id.equalsExp(trackedItems.cardId)),
    ])
      ..orderBy([OrderingTerm.desc(trackedItems.purchasedAt)]);

    return query.watch().asyncMap((rows) async {
      final cardsList = [
        for (final row in rows) row.readTable(cards),
      ];
      final historyByCard = await _monthHistoryByCardIds(
        cardsList.map((c) => c.id),
      );

      final result = <TrackedRow>[];
      for (final row in rows) {
        final item = row.readTable(trackedItems);
        final card = row.readTable(cards);
        final hist = historyByCard[card.id] ?? (<PriceSnapshot>[], <PriceSnapshot>[]);
        final latestCm = hist.$1.isEmpty
            ? await _latestSnapshot(card.id, 'cardmarket')
            : hist.$1.last;
        final latestCt = hist.$2.isEmpty
            ? await _latestSnapshot(card.id, 'cardtrader')
            : hist.$2.last;
        result.add(
          TrackedRow(
            item: item,
            card: card,
            latestCm: latestCm,
            latestCt: latestCt,
            cmMonth: hist.$1,
            ctMonth: hist.$2,
          ),
        );
      }
      return result;
    });
  }

  Future<List<TrackedEntry>> allTrackedEntries() async {
    final q = select(trackedItems).join([
      innerJoin(cards, cards.id.equalsExp(trackedItems.cardId)),
    ]);
    final rows = await q.get();
    return rows
        .map(
          (r) => TrackedEntry(
            card: r.readTable(cards),
            item: r.readTable(trackedItems),
          ),
        )
        .toList();
  }

  /// Cards that need CM/CT price sync (watchlist ∪ tracking).
  ///
  /// When the same printing is on both lists, prefer an **explicit** finish
  /// (foil/non-foil) from a portfolio lot over a watchlist "any" filter, so
  /// portfolio foil lots are not valued with non-foil guides.
  Future<List<PriceSyncTarget>> allPriceSyncTargets({int? onlyCardId}) async {
    final byCard = <int, PriceSyncTarget>{};

    for (final e in await allWatchlistEntries()) {
      if (onlyCardId != null && e.card.id != onlyCardId) continue;
      byCard[e.card.id] = PriceSyncTarget(
        card: e.card,
        foil: e.item.foil,
        language: e.item.language,
        minCondition: e.item.minCondition,
        sellerName: e.item.sellerName,
        minSellerQuantity: e.item.minSellerQuantity,
      );
    }

    for (final e in await allTrackedEntries()) {
      if (onlyCardId != null && e.card.id != onlyCardId) continue;
      final existing = byCard[e.card.id];
      if (existing == null) {
        byCard[e.card.id] = PriceSyncTarget(
          card: e.card,
          foil: e.item.foil,
          language: e.item.language,
          minCondition: e.item.condition,
          sellerName: null,
          minSellerQuantity: null,
        );
        continue;
      }
      // Portfolio explicit foil/language/condition fills watchlist "any" gaps.
      byCard[e.card.id] = PriceSyncTarget(
        card: e.card,
        foil: existing.foil ?? e.item.foil,
        language: (existing.language == null || existing.language!.isEmpty)
            ? e.item.language
            : existing.language,
        minCondition:
            (existing.minCondition == null || existing.minCondition!.isEmpty)
                ? e.item.condition
                : existing.minCondition,
        sellerName: existing.sellerName,
        minSellerQuantity: existing.minSellerQuantity,
      );
    }

    return byCard.values.toList();
  }

  Future<void> updateTrackedLotValuation({
    required int trackedItemId,
    int? cmTrendCents,
    int? cmAvg7Cents,
    int? cmAvg30Cents,
    int? ctBestCents,
    int? ctZeroCents,
    int? ctDirectCents,
  }) {
    return (update(trackedItems)..where((t) => t.id.equals(trackedItemId)))
        .write(
      TrackedItemsCompanion(
        lastCmTrendCents: Value(cmTrendCents),
        lastCmAvg7Cents: Value(cmAvg7Cents),
        lastCmAvg30Cents: Value(cmAvg30Cents),
        lastCtBestCents: Value(ctBestCents),
        lastCtZeroCents: Value(ctZeroCents),
        lastCtDirectCents: Value(ctDirectCents),
        valuedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Ensure a [Cards] row exists, then insert a purchase lot.
  Future<int> addTrackedCard({
    required String name,
    required String expansion,
    required int paidCents,
    required DateTime purchasedAt,
    int? cardTraderBlueprintId,
    int? cardTraderExpansionId,
    int? cardmarketProductId,
    String? imageUrl,
    bool? foil,
    String? language,
    String? condition,
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

    await into(trackedItems).insert(
      TrackedItemsCompanion.insert(
        cardId: cardId,
        paidCents: paidCents,
        purchasedAt: purchasedAt,
        quantity: Value(quantity < 1 ? 1 : quantity),
        foil: Value(foil),
        language: Value(language),
        condition: Value(condition),
        notes: Value(notes),
      ),
    );
    return cardId;
  }

  Future<void> removeTrackedItem(int trackedItemId) async {
    await (delete(trackedItems)..where((t) => t.id.equals(trackedItemId))).go();
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
    this.cmMonth = const [],
    this.ctMonth = const [],
  });

  final WatchlistItem item;
  final Card card;
  final PriceSnapshot? latestCm;
  final PriceSnapshot? latestCt;
  final PriceSnapshot? previousCm;
  final List<PriceSnapshot> cmMonth;
  final List<PriceSnapshot> ctMonth;

  double? get cmTrendChangePct {
    final cur = latestCm?.cmTrendCents;
    final prev = previousCm?.cmTrendCents;
    if (cur == null || prev == null || prev == 0) return null;
    return ((cur - prev) / prev) * 100;
  }

  /// CT best (Zero, else Direct) minus CM trend — what users usually mean by Δ.
  int? get ctVsCmSpreadCents {
    final cm = latestCm?.cmTrendCents;
    final ct = latestCt?.ctMinZeroCents ?? latestCt?.ctMinDirectCents;
    if (cm == null || ct == null) return null;
    return ct - cm;
  }

  double? get ctVsCmSpreadPct {
    final cm = latestCm?.cmTrendCents;
    final spread = ctVsCmSpreadCents;
    if (cm == null || spread == null || cm == 0) return null;
    return (spread / cm) * 100;
  }
}

class WatchlistEntry {
  WatchlistEntry({required this.card, required this.item});
  final Card card;
  final WatchlistItem item;
}

class TrackedEntry {
  TrackedEntry({required this.card, required this.item});
  final Card card;
  final TrackedItem item;
}

/// Unified target for CM/CT price sync (watchlist or tracking).
class PriceSyncTarget {
  PriceSyncTarget({
    required this.card,
    this.foil,
    this.language,
    this.minCondition,
    this.sellerName,
    this.minSellerQuantity,
  });

  final Card card;
  final bool? foil;
  final String? language;
  final String? minCondition;
  final String? sellerName;
  final int? minSellerQuantity;
}

class TrackedRow {
  TrackedRow({
    required this.item,
    required this.card,
    this.latestCm,
    this.latestCt,
    this.cmMonth = const [],
    this.ctMonth = const [],
  });

  final TrackedItem item;
  final Card card;
  final PriceSnapshot? latestCm;
  final PriceSnapshot? latestCt;
  final List<PriceSnapshot> cmMonth;
  final List<PriceSnapshot> ctMonth;

  int get costBasisCents => item.paidCents * item.quantity;

  /// Prefer lot-specific foil-aware valuation over shared card snapshots.
  int? get cmNowCents => item.lastCmTrendCents ?? latestCm?.cmTrendCents;
  int? get ctNowCents =>
      item.lastCtBestCents ??
      latestCt?.ctMinZeroCents ??
      latestCt?.ctMinDirectCents;

  int? get cmValueCents {
    final u = cmNowCents;
    if (u == null) return null;
    return u * item.quantity;
  }

  int? get ctValueCents {
    final u = ctNowCents;
    if (u == null) return null;
    return u * item.quantity;
  }

  /// Market now − paid (per-copy), times quantity. Positive = up.
  int? get cmPnlCents {
    final now = cmNowCents;
    if (now == null) return null;
    return (now - item.paidCents) * item.quantity;
  }

  int? get ctPnlCents {
    final now = ctNowCents;
    if (now == null) return null;
    return (now - item.paidCents) * item.quantity;
  }

  double? get cmPnlPct {
    final paid = costBasisCents;
    final pnl = cmPnlCents;
    if (pnl == null || paid == 0) return null;
    return (pnl / paid) * 100;
  }

  double? get ctPnlPct {
    final paid = costBasisCents;
    final pnl = ctPnlCents;
    if (pnl == null || paid == 0) return null;
    return (pnl / paid) * 100;
  }
}
