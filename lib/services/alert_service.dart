import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:drift/drift.dart';

import '../data/database.dart';
import 'app_settings.dart';

/// Evaluates watchlist buy/sell targets after a price sync.
class AlertService {
  AlertService({
    required this.db,
    required this.settings,
  });

  final AppDatabase db;
  final AppSettings settings;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      _ready = true;
    } catch (e) {
      // Hot restart / missing plugin channel — alerts stay soft-disabled.
      _ready = false;
    }
  }

  Future<List<String>> evaluateWatchlistAlerts() async {
    if (!settings.alertsEnabled) return const [];
    try {
      await init();
    } catch (_) {
      return const [];
    }
    if (!_ready) return const [];

    final entries = await db.allWatchlistEntries();
    final hits = <String>[];
    var id = 0;
    for (final entry in entries) {
      final card = entry.card;
      final item = entry.item;
      final latestCt = await (db.select(db.priceSnapshots)
            ..where(
              (t) =>
                  t.cardId.equals(card.id) & t.source.equals('cardtrader'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
            ..limit(1))
          .getSingleOrNull();
      final latestCm = await (db.select(db.priceSnapshots)
            ..where(
              (t) =>
                  t.cardId.equals(card.id) & t.source.equals('cardmarket'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.capturedAt)])
            ..limit(1))
          .getSingleOrNull();
      final ct = latestCt?.ctMinZeroCents ?? latestCt?.ctMinDirectCents;
      final cm = latestCm?.cmTrendCents;

      final buy = item.targetBuyCents;
      if (buy != null && ct != null && ct <= buy) {
        hits.add('${card.name}: buy target hit');
        await _notify(
          ++id,
          'Buy target hit',
          '${card.name} is at/under your buy price',
        );
      }
      final sell = item.targetSellCents;
      if (sell != null &&
          ((ct != null && ct >= sell) || (cm != null && cm >= sell))) {
        hits.add('${card.name}: sell target hit');
        await _notify(
          ++id,
          'Sell target hit',
          '${card.name} reached your sell price',
        );
      }
    }
    return hits;
  }

  Future<void> _notify(int id, String title, String body) async {
    const android = AndroidNotificationDetails(
      'price_alerts',
      'Price alerts',
      channelDescription: 'Watchlist buy/sell target alerts',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const details = NotificationDetails(android: android, iOS: DarwinNotificationDetails());
    await _plugin.show(id, title, body, details);
  }
}
