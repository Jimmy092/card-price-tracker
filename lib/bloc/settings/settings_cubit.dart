import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/app_settings.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._settings) : super(SettingsState.from(_settings));

  final AppSettings _settings;

  AppSettings get settings => _settings;

  Future<void> load() async {
    await _settings.load();
    if (!isClosed) emit(SettingsState.from(_settings));
  }

  Future<void> setAutoSyncEnabled(bool v) async {
    await _settings.setAutoSyncEnabled(v);
    if (!isClosed) emit(SettingsState.from(_settings));
  }

  Future<void> setAlertsEnabled(bool v) async {
    await _settings.setAlertsEnabled(v);
    if (!isClosed) emit(SettingsState.from(_settings));
  }

  Future<void> setZeroFeeCents(int v) async {
    await _settings.setZeroFeeCents(v);
    if (!isClosed) emit(SettingsState.from(_settings));
  }

  Future<void> setDirectShippingCents(int v) async {
    await _settings.setDirectShippingCents(v);
    if (!isClosed) emit(SettingsState.from(_settings));
  }

  void refresh() {
    if (!isClosed) emit(SettingsState.from(_settings));
  }
}
