import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/alert_service.dart';
import '../../services/app_settings.dart';
import '../../services/sync_service.dart';
import 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  SyncCubit({
    required this._sync,
    required this._settings,
    required this._alerts,
  }) : super(const SyncState());

  final SyncService _sync;
  final AppSettings _settings;
  final AlertService _alerts;

  Future<void> syncAll({bool quiet = false}) async {
    if (state.isRunning) return;
    emit(
      SyncState(
        status: SyncStatus.running,
        message: quiet ? 'Auto-sync…' : 'Starting sync…',
        quiet: quiet,
      ),
    );
    try {
      final outcome = await _sync.syncAll(
        onProgress: (m) {
          if (isClosed) return;
          emit(
            state.copyWith(
              status: SyncStatus.running,
              message: m,
              quiet: quiet,
            ),
          );
        },
      );
      await _settings.markFullSyncNow();
      final hits = await _alerts.evaluateWatchlistAlerts();
      if (isClosed) return;
      emit(
        SyncState(
          status: outcome.success ? SyncStatus.success : SyncStatus.failure,
          message: hits.isEmpty
              ? outcome.message
              : '${outcome.message} · ${hits.length} alert(s)',
          alertHits: hits.length,
          quiet: quiet,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        SyncState(
          status: SyncStatus.failure,
          message: e.toString(),
          quiet: quiet,
        ),
      );
    }
  }

  Future<void> syncCard(int cardId) async {
    if (state.isRunning) return;
    emit(
      const SyncState(
        status: SyncStatus.running,
        message: 'Refreshing card…',
      ),
    );
    try {
      final outcome = await _sync.syncWatchlistCard(
        cardId,
        onProgress: (m) {
          if (isClosed) return;
          emit(state.copyWith(status: SyncStatus.running, message: m));
        },
      );
      if (isClosed) return;
      emit(
        SyncState(
          status: outcome.success ? SyncStatus.success : SyncStatus.failure,
          message: outcome.message,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(SyncState(status: SyncStatus.failure, message: e.toString()));
    }
  }

  Future<void> maybeAutoSync() async {
    if (!_settings.autoSyncEnabled || !_settings.needsDailySync) return;
    await syncAll(quiet: true);
  }

  void acknowledge() {
    if (state.status == SyncStatus.running) return;
    emit(const SyncState());
  }
}
