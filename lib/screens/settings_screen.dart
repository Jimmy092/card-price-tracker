import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/cardmarket_ingest.dart';
import '../services/cardtrader_client.dart';
import '../services/secure_token_store.dart';
import '../services/sync_service.dart';
import '../widgets/ui_kit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _tokenController = TextEditingController();
  bool _obscure = true;
  bool _busy = false;
  String? _status;
  String? _tokenHint;
  CardmarketCacheStatus? _cmStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final tokens = context.read<SecureTokenStore>();
    final cm = context.read<CardmarketIngest>();
    final existing = await tokens.readCardTraderToken();
    final status = await cm.cacheStatus();
    if (!mounted) return;
    setState(() {
      if (existing != null && existing.isNotEmpty) {
        _tokenController.text = existing;
        _tokenHint = 'Token saved (${existing.length} chars)';
      }
      _cmStatus = status;
    });
  }

  Future<void> _saveToken() async {
    final tokens = context.read<SecureTokenStore>();
    await tokens.writeCardTraderToken(_tokenController.text);
    setState(() => _tokenHint = 'Token saved');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('CardTrader token saved securely')),
    );
  }

  Future<void> _testToken() async {
    setState(() {
      _busy = true;
      _status = 'Testing CardTrader token…';
    });
    try {
      await _saveToken();
      if (!mounted) return;
      final info = await context.read<CardTraderClient>().getInfo();
      if (!mounted) return;
      setState(() => _status = 'OK — app "${info.name}" (id ${info.id})');
    } catch (e) {
      if (!mounted) return;
      setState(() => _status = 'Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _status = null;
    });
    try {
      await action();
      if (!mounted) return;
      final status = await context.read<CardmarketIngest>().cacheStatus();
      if (!mounted) return;
      setState(() => _cmStatus = status);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sync = context.watch<SyncService>();
    final db = context.watch<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const SectionHeader(
            title: 'CardTrader',
            subtitle: 'Live marketplace API token',
          ),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _tokenController,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    labelText: 'Bearer token',
                    helperText: _tokenHint ??
                        'From CardTrader profile settings → API token',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: _busy ? null : _saveToken,
                      child: const Text('Save token'),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _testToken,
                      child: const Text('Test token'),
                    ),
                    TextButton(
                      onPressed: _busy
                          ? null
                          : () async {
                              await context
                                  .read<SecureTokenStore>()
                                  .clearCardTraderToken();
                              _tokenController.clear();
                              setState(() => _tokenHint = 'Token cleared');
                            },
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Cardmarket guides',
            subtitle: 'Daily reference prices',
          ),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _cmStatus == null
                      ? 'Checking cache…'
                      : _cmStatus!.ready
                          ? 'Cached. Products: ${_fmt(_cmStatus!.productsModified)}; '
                              'Guide: ${_fmt(_cmStatus!.priceGuideModified)}'
                          : 'No local guides yet — download or import CSV/JSON.',
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonal(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                                final outcome = await sync.syncCardmarketGuides(
                                  onProgress: (m) =>
                                      setState(() => _status = m),
                                );
                                setState(() => _status = outcome.message);
                              }),
                      child: const Text('Download & apply CM guides'),
                    ),
                    OutlinedButton(
                      onPressed: _busy ? null : _importCmFiles,
                      child: const Text('Import CM files'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(
            title: 'Sync',
            subtitle: 'Refresh watchlist prices',
          ),
          GlowCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                                final outcome = await sync.syncAll(
                                  onProgress: (m) =>
                                      setState(() => _status = m),
                                );
                                setState(() => _status = outcome.message);
                              }),
                      child: const Text('Sync now'),
                    ),
                    OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => _run(() async {
                                final outcome =
                                    await sync.syncCardTraderWatchlist(
                                  onProgress: (m) =>
                                      setState(() => _status = m),
                                );
                                setState(() => _status = outcome.message);
                              }),
                      child: const Text('CT watchlist only'),
                    ),
                  ],
                ),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(),
                ],
                if (_status != null) ...[
                  const SizedBox(height: 12),
                  Text(_status!),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          const SectionHeader(title: 'Recent sync runs'),
          GlowCard(
            child: StreamBuilder<List<SyncRun>>(
              stream: db.watchRecentSyncRuns(),
              builder: (context, snapshot) {
                final runs = snapshot.data ?? [];
                if (runs.isEmpty) return const Text('No syncs yet.');
                return Column(
                  children: runs
                      .map(
                        (r) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text('${r.source} · ${r.status}'),
                          subtitle: Text(
                            '${r.startedAt.toLocal()} · ${r.message}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _importCmFiles() async {
    final productsPick = await FilePicker.pickFiles(
      dialogTitle: 'Cardmarket products (JSON or CSV)',
      type: FileType.custom,
      allowedExtensions: const ['json', 'csv'],
    );
    if (productsPick.isEmpty || productsPick.first.path == null) return;
    final guidePick = await FilePicker.pickFiles(
      dialogTitle: 'Cardmarket price guide (JSON or CSV)',
      type: FileType.custom,
      allowedExtensions: const ['json', 'csv'],
    );
    if (guidePick.isEmpty || guidePick.first.path == null) return;
    if (!mounted) return;

    final productsPath = productsPick.first.path;
    final guidePath = guidePick.first.path;
    final sync = context.read<SyncService>();
    await _run(() async {
      final outcome = await sync.syncCardmarketGuides(
        download: false,
        productsPath: productsPath,
        priceGuidePath: guidePath,
        onProgress: (m) {
          if (mounted) setState(() => _status = m);
        },
      );
      if (mounted) setState(() => _status = outcome.message);
    });
  }

  String _fmt(DateTime? d) => d?.toLocal().toString().split('.').first ?? '—';
}
