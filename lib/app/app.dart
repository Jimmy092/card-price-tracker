import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/portfolio/portfolio_cubit.dart';
import '../bloc/settings/settings_cubit.dart';
import '../bloc/sync/sync_cubit.dart';
import '../bloc/sync/sync_state.dart';
import '../bloc/watchlist/watchlist_cubit.dart';
import '../data/database.dart';
import '../services/alert_service.dart';
import '../services/app_settings.dart';
import '../services/cardmarket_ingest.dart';
import '../services/cardtrader_client.dart';
import '../services/scryfall_client.dart';
import '../services/secure_token_store.dart';
import '../services/sync_service.dart';
import 'router.dart';
import 'theme.dart';

class CardPriceApp extends StatefulWidget {
  const CardPriceApp({super.key});

  @override
  State<CardPriceApp> createState() => _CardPriceAppState();
}

class _CardPriceAppState extends State<CardPriceApp>
    with WidgetsBindingObserver {
  late final AppDatabase _db;
  late final SecureTokenStore _tokens;
  late final CardTraderClient _ct;
  late final ScryfallClient _scryfall;
  late final CardmarketIngest _cm;
  late final SyncService _sync;
  late final AppSettings _settings;
  late final AlertService _alerts;
  late final GoRouter _router;
  final _messengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _db = AppDatabase();
    _tokens = SecureTokenStore();
    _ct = CardTraderClient(tokenProvider: _tokens.readCardTraderToken);
    _scryfall = ScryfallClient();
    _cm = CardmarketIngest();
    _sync = SyncService(db: _db, ct: _ct, cm: _cm);
    _settings = AppSettings();
    _alerts = AlertService(db: _db, settings: _settings);
    _router = buildAppRouter();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: _db),
        RepositoryProvider.value(value: _tokens),
        RepositoryProvider.value(value: _ct),
        RepositoryProvider.value(value: _scryfall),
        RepositoryProvider.value(value: _cm),
        RepositoryProvider.value(value: _sync),
        RepositoryProvider.value(value: _settings),
        RepositoryProvider.value(value: _alerts),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => SettingsCubit(_settings)..load(),
          ),
          BlocProvider(
            create: (_) => SyncCubit(
              sync: _sync,
              settings: _settings,
              alerts: _alerts,
            ),
          ),
          BlocProvider(
            create: (_) => WatchlistCubit(db: _db, sync: _sync),
          ),
          BlocProvider(
            create: (_) => PortfolioCubit(db: _db, sync: _sync),
          ),
        ],
        child: _AppLifecycleSync(
          child: BlocListener<SyncCubit, SyncState>(
            listenWhen: (prev, next) =>
                !next.quiet &&
                next.status != SyncStatus.running &&
                next.message != null &&
                next.message != prev.message,
            listener: (context, state) {
              final msg = state.message;
              if (msg == null || msg.isEmpty) return;
              _messengerKey.currentState
                ?..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(content: Text(msg)));
              context.read<SyncCubit>().acknowledge();
              context.read<SettingsCubit>().refresh();
            },
            child: MaterialApp.router(
              title: 'Card Price Tracker',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.dark(),
              scaffoldMessengerKey: _messengerKey,
              routerConfig: _router,
            ),
          ),
        ),
      ),
    );
  }
}

/// Triggers prefs hydration + quiet daily auto-sync on launch/resume.
class _AppLifecycleSync extends StatefulWidget {
  const _AppLifecycleSync({required this.child});
  final Widget child;

  @override
  State<_AppLifecycleSync> createState() => _AppLifecycleSyncState();
}

class _AppLifecycleSyncState extends State<_AppLifecycleSync>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final settings = context.read<SettingsCubit>();
      final alerts = context.read<AlertService>();
      final sync = context.read<SyncCubit>();
      await settings.load();
      await alerts.init();
      await sync.maybeAutoSync();
      if (mounted) settings.refresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<SyncCubit>().maybeAutoSync();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
