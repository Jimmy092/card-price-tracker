import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/database.dart';
import '../../services/sync_service.dart';
import 'portfolio_state.dart';

class PortfolioCubit extends Cubit<PortfolioState> {
  PortfolioCubit({
    required this._db,
    required this._sync,
  }) : super(const PortfolioState()) {
    _sub = _db.watchTracked().listen(
      (rows) {
        final visible = _apply(rows, state.sort, state.filter);
        emit(
          state.copyWith(
            status: PortfolioStatus.ready,
            rows: rows,
            visible: visible,
            clearError: true,
          ),
        );
      },
      onError: (Object e) => emit(
        state.copyWith(status: PortfolioStatus.error, error: e.toString()),
      ),
    );
  }

  final AppDatabase _db;
  final SyncService _sync;
  StreamSubscription<List<TrackedRow>>? _sub;

  void setSort(PortfolioSort sort) {
    emit(
      state.copyWith(
        sort: sort,
        visible: _apply(state.rows, sort, state.filter),
      ),
    );
  }

  void setFilter(PortfolioFilter filter) {
    emit(
      state.copyWith(
        filter: filter,
        visible: _apply(state.rows, state.sort, filter),
      ),
    );
  }

  Future<void> updateLot({
    required int trackedItemId,
    required int paidCents,
    required DateTime purchasedAt,
    required int quantity,
    bool? foil,
    String? language,
    String? condition,
    String notes = '',
  }) async {
    final before = await (_db.select(_db.trackedItems)
          ..where((t) => t.id.equals(trackedItemId)))
        .getSingleOrNull();

    await _db.updateTrackedLot(
      trackedItemId: trackedItemId,
      paidCents: paidCents,
      purchasedAt: purchasedAt,
      quantity: quantity,
      foil: foil,
      language: language,
      condition: condition,
      notes: notes,
    );

    // Foil / language / condition (and paid) need a fresh CT+CM lot valuation.
    final cardId = before?.cardId;
    if (cardId != null) {
      await _sync.syncPortfolioLots(onlyCardId: cardId);
    }
  }

  Future<void> markSold({
    required int trackedItemId,
    required int soldCents,
    required DateTime soldAt,
  }) {
    return _db.markTrackedLotSold(
      trackedItemId: trackedItemId,
      soldCents: soldCents,
      soldAt: soldAt,
    );
  }

  Future<void> reopen(int trackedItemId) async {
    final item = await (_db.select(_db.trackedItems)
          ..where((t) => t.id.equals(trackedItemId)))
        .getSingleOrNull();
    await _db.reopenTrackedLot(trackedItemId);
    final cardId = item?.cardId;
    if (cardId != null) {
      await _sync.syncPortfolioLots(onlyCardId: cardId);
    }
  }

  Future<void> remove(int trackedItemId) => _db.removeTrackedItem(trackedItemId);

  Future<void> addToWatchlist(TrackedRow row) async {
    await _db.upsertWatchlistCard(
      name: row.card.name,
      expansion: row.card.expansion,
      cardTraderBlueprintId: row.card.cardTraderBlueprintId,
      cardTraderExpansionId: row.card.cardTraderExpansionId,
      cardmarketProductId: row.card.cardmarketProductId,
      imageUrl: row.card.imageUrl,
      foil: row.item.foil,
      language: row.item.language,
      minCondition: row.item.condition,
      quantity: 1,
    );
    if (!isClosed) {
      emit(state.copyWith(snackMessage: 'Added ${row.card.name} to Watchlist'));
    }
  }

  void clearSnack() => emit(state.copyWith(clearSnack: true));

  static List<TrackedRow> _apply(
    List<TrackedRow> rows,
    PortfolioSort sort,
    PortfolioFilter filter,
  ) {
    final now = DateTime.now();
    var out = [...rows];
    switch (filter) {
      case PortfolioFilter.open:
        out = out.where((r) => !r.isSold).toList();
      case PortfolioFilter.sold:
        out = out.where((r) => r.isSold).toList();
      case PortfolioFilter.foil:
        out = out.where((r) => r.item.foil == true).toList();
      case PortfolioFilter.thisMonth:
        out = out
            .where(
              (r) =>
                  r.item.purchasedAt.year == now.year &&
                  r.item.purchasedAt.month == now.month,
            )
            .toList();
      case PortfolioFilter.all:
        break;
    }
    switch (sort) {
      case PortfolioSort.newest:
        out.sort((a, b) => b.item.purchasedAt.compareTo(a.item.purchasedAt));
      case PortfolioSort.name:
        out.sort((a, b) => a.card.name.compareTo(b.card.name));
      case PortfolioSort.biggestLoser:
        out.sort((a, b) {
          final ap = a.ctPnlCents ?? a.cmPnlCents ?? 0;
          final bp = b.ctPnlCents ?? b.cmPnlCents ?? 0;
          return ap.compareTo(bp);
        });
      case PortfolioSort.biggestWinner:
        out.sort((a, b) {
          final ap = a.ctPnlCents ?? a.cmPnlCents ?? 0;
          final bp = b.ctPnlCents ?? b.cmPnlCents ?? 0;
          return bp.compareTo(ap);
        });
    }
    return out;
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
