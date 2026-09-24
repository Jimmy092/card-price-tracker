import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/cardtrader_client.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  List<CtExpansion> _expansions = [];
  CtExpansion? _selectedExpansion;
  List<CtBlueprint> _results = [];
  bool _loadingExpansions = false;
  bool _searching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExpansions());
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _loadExpansions() async {
    setState(() {
      _loadingExpansions = true;
      _error = null;
    });
    try {
      final ct = context.read<CardTraderClient>();
      final list = await ct.listMtgExpansions();
      if (!mounted) return;
      setState(() {
        _expansions = list;
        _loadingExpansions = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingExpansions = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _search() async {
    final q = _query.text.trim();
    if (q.isEmpty) return;
    setState(() {
      _searching = true;
      _error = null;
    });
    try {
      final ct = context.read<CardTraderClient>();
      final results = await ct.searchBlueprintsByName(
        q,
        expansionId: _selectedExpansion?.id,
      );
      if (!mounted) return;
      setState(() {
        _results = results;
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _searching = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _add(CtBlueprint bp) async {
    final db = context.read<AppDatabase>();
    await db.upsertWatchlistCard(
      name: bp.name,
      expansion: bp.expansionName ?? _selectedExpansion?.name ?? '',
      cardTraderBlueprintId: bp.id,
      cardTraderExpansionId: bp.expansionId,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${bp.name} to watchlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search / Add')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                if (_loadingExpansions)
                  const LinearProgressIndicator()
                else
                  DropdownButtonFormField<CtExpansion?>(
                    // ignore: deprecated_member_use
                    value: _selectedExpansion,
                    decoration: const InputDecoration(
                      labelText: 'Expansion (optional but faster)',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<CtExpansion?>(
                        value: null,
                        child: Text('Any (scans recent sets)'),
                      ),
                      ..._expansions.map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedExpansion = v),
                  ),
                const SizedBox(height: 12),
                TextField(
                  controller: _query,
                  decoration: InputDecoration(
                    labelText: 'Card name',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searching ? null : _search,
                    ),
                  ),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ),
          if (_searching) const LinearProgressIndicator(),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final bp = _results[i];
                return ListTile(
                  title: Text(bp.name),
                  subtitle: Text(
                    bp.expansionName ??
                        _selectedExpansion?.name ??
                        'expansion ${bp.expansionId}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => _add(bp),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
