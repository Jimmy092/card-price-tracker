import 'dart:async';

import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/cardtrader_client.dart';
import '../widgets/price_format.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();
  List<CtExpansion> _expansions = [];
  CtExpansion? _selectedExpansion;
  List<CtBlueprint> _suggestions = [];
  final Map<int, CtMarketplaceSummary> _markets = {};
  final Map<int, String> _priceErrors = {};
  final Set<int> _expanded = {};
  final Set<int> _loadingPrices = {};
  bool _loadingExpansions = false;
  bool _loadingBlueprints = false;
  bool _suggesting = false;
  String? _error;
  Timer? _debounce;
  int _suggestGen = 0;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadExpansions());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _query.removeListener(_onQueryChanged);
    _query.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    final text = _query.text.trim();
    if (text.length < 2) {
      setState(() {
        _suggestions = [];
        _suggesting = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 280), _runSuggest);
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

  Future<void> _onExpansionChanged(CtExpansion? v) async {
    setState(() {
      _selectedExpansion = v;
      _suggestions = [];
      _markets.clear();
      _expanded.clear();
    });
    if (v == null) return;
    setState(() => _loadingBlueprints = true);
    try {
      await context.read<CardTraderClient>().listBlueprints(v.id);
      if (!mounted) return;
      setState(() => _loadingBlueprints = false);
      if (_query.text.trim().length >= 2) {
        await _runSuggest();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingBlueprints = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _runSuggest() async {
    final q = _query.text.trim();
    final expansion = _selectedExpansion;
    if (q.length < 2) return;
    if (expansion == null) {
      setState(() {
        _error = 'Pick an expansion to get live suggestions, images, and prices.';
        _suggestions = [];
      });
      return;
    }

    final gen = ++_suggestGen;
    setState(() {
      _suggesting = true;
      _error = null;
    });

    try {
      final ct = context.read<CardTraderClient>();
      final results = await ct.suggestBlueprints(
        q,
        expansionId: expansion.id,
        limit: 20,
      );
      if (!mounted || gen != _suggestGen) return;
      setState(() {
        _suggestions = results;
        _suggesting = false;
      });
      unawaited(_prefetchPrices(results.take(12).toList(), gen));
    } catch (e) {
      if (!mounted || gen != _suggestGen) return;
      setState(() {
        _suggesting = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _prefetchPrices(List<CtBlueprint> bps, int gen) async {
    final ct = context.read<CardTraderClient>();
    for (final bp in bps) {
      if (!mounted || gen != _suggestGen) return;
      if (_markets.containsKey(bp.id) || _loadingPrices.contains(bp.id)) {
        continue;
      }
      setState(() => _loadingPrices.add(bp.id));
      try {
        final market = await ct.marketplaceForBlueprint(bp.id);
        if (!mounted || gen != _suggestGen) return;
        setState(() {
          _markets[bp.id] = market;
          _priceErrors.remove(bp.id);
          _loadingPrices.remove(bp.id);
        });
      } catch (e) {
        if (!mounted || gen != _suggestGen) return;
        setState(() {
          _priceErrors[bp.id] = e.toString();
          _loadingPrices.remove(bp.id);
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  Future<void> _ensurePrice(CtBlueprint bp) async {
    if (_markets.containsKey(bp.id) || _loadingPrices.contains(bp.id)) return;
    setState(() => _loadingPrices.add(bp.id));
    try {
      final market =
          await context.read<CardTraderClient>().marketplaceForBlueprint(bp.id);
      if (!mounted) return;
      setState(() {
        _markets[bp.id] = market;
        _priceErrors.remove(bp.id);
        _loadingPrices.remove(bp.id);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _priceErrors[bp.id] = e.toString();
        _loadingPrices.remove(bp.id);
      });
    }
  }

  Future<void> _toggleExpand(CtBlueprint bp) async {
    final opening = !_expanded.contains(bp.id);
    setState(() {
      if (opening) {
        _expanded.add(bp.id);
      } else {
        _expanded.remove(bp.id);
      }
    });
    if (opening) await _ensurePrice(bp);
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
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              children: [
                if (_loadingExpansions)
                  const LinearProgressIndicator()
                else
                  DropdownButtonFormField<CtExpansion?>(
                    // ignore: deprecated_member_use
                    value: _selectedExpansion,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Expansion',
                      helperText: 'Required for typeahead + images + CT prices',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      const DropdownMenuItem<CtExpansion?>(
                        value: null,
                        child: Text('Select an expansion'),
                      ),
                      ..._expansions.map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.name, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: _loadingBlueprints ? null : _onExpansionChanged,
                  ),
                if (_loadingBlueprints) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(),
                  const SizedBox(height: 4),
                  Text(
                    'Loading set catalogue…',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: _query,
                  focusNode: _focus,
                  enabled: _selectedExpansion != null && !_loadingBlueprints,
                  decoration: InputDecoration(
                    labelText: 'Card name',
                    hintText: 'Start typing to see suggestions…',
                    border: const OutlineInputBorder(),
                    suffixIcon: _suggesting
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _query.clear();
                              setState(() => _suggestions = []);
                            },
                          ),
                  ),
                  textInputAction: TextInputAction.search,
                ),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          Expanded(
            child: _suggestions.isEmpty
                ? Center(
                    child: Text(
                      _selectedExpansion == null
                          ? 'Choose an expansion, then type a card name.'
                          : (_query.text.trim().length < 2
                              ? 'Type at least 2 characters for suggestions.'
                              : (_suggesting
                                  ? 'Searching…'
                                  : 'No matching cards in this set.')),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, i) {
                      final bp = _suggestions[i];
                      final market = _markets[bp.id];
                      final expanded = _expanded.contains(bp.id);
                      final loadingPrice = _loadingPrices.contains(bp.id);
                      final top5 = market?.bestListings(limit: 5) ?? const [];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: Material(
                        color: Theme.of(context).colorScheme.surface,
                        elevation: 1,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => _toggleExpand(bp),
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _CardThumb(url: bp.absoluteImageUrl),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            bp.name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            bp.expansionName ??
                                                _selectedExpansion?.name ??
                                                '',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall,
                                          ),
                                          const SizedBox(height: 8),
                                          if (loadingPrice && market == null)
                                            const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          else if (market != null)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                _PriceChip(
                                                  label: 'Best',
                                                  value: formatEurCents(
                                                    market.bestPriceCents,
                                                  ),
                                                  emphasize: true,
                                                ),
                                                if (market.minZeroCents != null)
                                                  _PriceChip(
                                                    label: 'Zero',
                                                    value: formatEurCents(
                                                      market.minZeroCents,
                                                    ),
                                                  ),
                                                if (market.minDirectCents !=
                                                    null)
                                                  _PriceChip(
                                                    label: 'Direct',
                                                    value: formatEurCents(
                                                      market.minDirectCents,
                                                    ),
                                                  ),
                                              ],
                                            )
                                          else if (_priceErrors[bp.id] != null)
                                            Text(
                                              'Price unavailable',
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                                fontSize: 12,
                                              ),
                                            )
                                          else
                                            Text(
                                              'Tap for seller prices',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        IconButton(
                                          tooltip: 'Add to watchlist',
                                          icon: const Icon(
                                            Icons.add_circle_outline,
                                          ),
                                          onPressed: () => _add(bp),
                                        ),
                                        Icon(
                                          expanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (expanded) ...[
                              const Divider(height: 1),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Best 5 listings',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Zero = CardTrader hub. Direct = seller ships.',
                                      style:
                                          Theme.of(context).textTheme.bodySmall,
                                    ),
                                    const SizedBox(height: 8),
                                    if (loadingPrice && top5.isEmpty)
                                      const Padding(
                                        padding: EdgeInsets.all(8),
                                        child: Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (top5.isEmpty)
                                      const Text('No live listings found.')
                                    else
                                      ...top5.map(
                                        (l) => ListTile(
                                          dense: true,
                                          contentPadding: EdgeInsets.zero,
                                          title: Text(
                                            l.sellerName ?? 'Unknown seller',
                                          ),
                                          subtitle: Text(
                                            [
                                              if (l.canSellViaHub) 'Zero',
                                              if (!l.canSellViaHub) 'Direct',
                                              if (l.condition != null)
                                                l.condition,
                                              if (l.foil == true) 'Foil',
                                              if (l.quantity != null)
                                                'qty ${l.quantity}',
                                            ].join(' · '),
                                          ),
                                          trailing: Text(
                                            formatEurCents(l.priceCents),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
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

class _CardThumb extends StatelessWidget {
  const _CardThumb({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final border = BorderRadius.circular(6);
    return ClipRRect(
      borderRadius: border,
      child: SizedBox(
        width: 56,
        height: 78,
        child: url == null
            ? ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined, size: 20),
              )
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.broken_image_outlined, size: 20),
                ),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: emphasize
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label $value',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: emphasize ? scheme.onPrimaryContainer : null,
              fontWeight: emphasize ? FontWeight.w600 : null,
            ),
      ),
    );
  }
}
