import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences store (no ChangeNotifier — exposed via [SettingsCubit]).
class AppSettings {
  AppSettings();

  SharedPreferences? _prefs;
  bool _ready = false;

  final Map<String, Object?> _memory = {};

  bool get isReady => _ready;

  /// Load SharedPreferences after the Flutter engine + plugins are up.
  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _ready = true;
    } catch (e, st) {
      debugPrint('AppSettings: SharedPreferences unavailable: $e\n$st');
      _ready = false;
    }
  }

  static const _kAutoSync = 'auto_sync_enabled';
  static const _kAlerts = 'price_alerts_enabled';
  static const _kLastSync = 'last_full_sync_ms';
  static const _kZeroFee = 'landed_zero_fee_cents';
  static const _kDirectShip = 'landed_direct_ship_cents';

  bool? _getBool(String key) {
    final mem = _memory[key];
    if (mem is bool) return mem;
    return _prefs?.getBool(key);
  }

  int? _getInt(String key) {
    final mem = _memory[key];
    if (mem is int) return mem;
    return _prefs?.getInt(key);
  }

  Future<void> _setBool(String key, bool v) async {
    _memory[key] = v;
    try {
      await _prefs?.setBool(key, v);
    } catch (e) {
      debugPrint('AppSettings: setBool($key) failed: $e');
    }
  }

  Future<void> _setInt(String key, int v) async {
    _memory[key] = v;
    try {
      await _prefs?.setInt(key, v);
    } catch (e) {
      debugPrint('AppSettings: setInt($key) failed: $e');
    }
  }

  bool get autoSyncEnabled => _getBool(_kAutoSync) ?? true;
  Future<void> setAutoSyncEnabled(bool v) => _setBool(_kAutoSync, v);

  bool get alertsEnabled => _getBool(_kAlerts) ?? true;
  Future<void> setAlertsEnabled(bool v) => _setBool(_kAlerts, v);

  DateTime? get lastFullSyncAt {
    final ms = _getInt(_kLastSync);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> markFullSyncNow() =>
      _setInt(_kLastSync, DateTime.now().millisecondsSinceEpoch);

  bool get needsDailySync {
    final last = lastFullSyncAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= const Duration(hours: 20);
  }

  int get zeroFeeCents => _getInt(_kZeroFee) ?? 50;
  Future<void> setZeroFeeCents(int v) => _setInt(_kZeroFee, v);

  int get directShippingCents => _getInt(_kDirectShip) ?? 180;
  Future<void> setDirectShippingCents(int v) => _setInt(_kDirectShip, v);
}
