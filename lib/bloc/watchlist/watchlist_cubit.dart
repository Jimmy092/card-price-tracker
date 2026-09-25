import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/database.dart';
import '../../services/sync_service.dart';
import 'watchlist_state.dart';

class WatchlistCubit extends Cubit<WatchlistState> {
  WatchlistCubit({
    required this._db,
    required this._sync,
  }) : super(const WatchlistState()) {
    _sub = _db.watchWatchlist().listen(
      (rows) => emit(
        state.copyWith(
          status: WatchlistStatus.ready,
          rows: rows,
          clearError: true,
        ),
      ),
      onError: (Object e) => emit(
        state.copyWith(status: WatchlistStatus.error, error: e.toString()),
      ),
    );
  }

  final AppDatabase _db;
  final SyncService _sync;
  StreamSubscription<List<WatchlistRow>>? _sub;

  Future<void> setTargets({
    required int watchlistItemId,
    int? targetBuyCents,
    int? targetSellCents,
  }) {
    return _db.updateWatchlistTargets(
      watchlistItemId: watchlistItemId,
      targetBuyCents: targetBuyCents,
      targetSellCents: targetSellCents,
    );
  }

  Future<void> remove(int watchlistItemId) =>
      _db.removeFromWatchlist(watchlistItemId);

  Future<void> addToPortfolio({
    required WatchlistRow row,
    required int paidCents,
    required DateTime purchasedAt,
    bool? foil,
    String? language,
    String? condition,
    int quantity = 1,
    String notes = '',
  }) async {
    final cardId = await _db.addTrackedCard(
      name: row.card.name,
      expansion: row.card.expansion,
      paidCents: paidCents,
      purchasedAt: purchasedAt,
      cardTraderBlueprintId: row.card.cardTraderBlueprintId,
      cardTraderExpansionId: row.card.cardTraderExpansionId,
      cardmarketProductId: row.card.cardmarketProductId,
      imageUrl: row.card.imageUrl,
      foil: foil,
      language: language,
      condition: condition,
      quantity: quantity,
      notes: notes,
    );
    await _sync.syncWatchlistCard(cardId);
    if (!isClosed) {
      emit(
        state.copyWith(
          snackMessage: 'Added ${row.card.name} to Portfolio',
        ),
      );
    }
  }

  void clearSnack() => emit(state.copyWith(clearSnack: true));

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
