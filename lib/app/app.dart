import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/cardmarket_ingest.dart';
import '../services/cardtrader_client.dart';
import '../services/secure_token_store.dart';
import '../services/sync_service.dart';
import 'router.dart';

class CardPriceApp extends StatefulWidget {
  const CardPriceApp({super.key});

  @override
  State<CardPriceApp> createState() => _CardPriceAppState();
}

class _CardPriceAppState extends State<CardPriceApp> {
  late final AppDatabase _db;
  late final SecureTokenStore _tokens;
  late final CardTraderClient _ct;
  late final CardmarketIngest _cm;
  late final SyncService _sync;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _db = AppDatabase();
    _tokens = SecureTokenStore();
    _ct = CardTraderClient(tokenProvider: _tokens.readCardTraderToken);
    _cm = CardmarketIngest();
    _sync = SyncService(db: _db, ct: _ct, cm: _cm);
    _router = buildAppRouter();
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider.value(value: _db),
        Provider.value(value: _tokens),
        Provider.value(value: _ct),
        Provider.value(value: _cm),
        Provider.value(value: _sync),
      ],
      child: MaterialApp.router(
        title: 'Card Price Tracker',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1B4D3E),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        routerConfig: _router,
      ),
    );
  }
}
