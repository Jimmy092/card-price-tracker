import 'dart:async';

import 'package:flutter/material.dart' hide Card;
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../services/cardtrader_client.dart';
import '../services/scryfall_client.dart';
import '../services/sync_service.dart';
import '../widgets/card_thumb.dart';
import '../widgets/price_format.dart';

/// One printing of a card (across sets), optionally linked to a CT blueprint.
class _PrintingRow {
  _PrintingRow({
    required this.printing,
    this.blueprint,
  });

  final ScryfallPrinting printing;
  final CtBlueprint? blueprint;

  String get key => printing.id;
  String get name => printing.name;
  String get setLabel =>
      '${printing.setName} (${printing.setCode.toUpperCase()}) · #${printing.collectorNumber}';
  String? get imageUrl =>
      blueprint?.absoluteImageUrl ?? printing.imageUrl;
  int? get blueprintId => blueprint?.id;
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _query = TextEditingController();
  final _focus = FocusNode();

  List<String> _nameSuggestions = [];
  String? _resolvedName;
  List<_PrintingRow> _printings = [];

  final Map<int, CtMarketplaceSummary> _markets = {};
  final Map<int, String> _priceErrors = {};
  final Set<String> _expandedKeys = {};
  final Set<int> _loadingPrices = {};

  /// null = any language; otherwise CardTrader language code (e.g. `en`).
  String? _language;
  /// null = any; true = foil only; false = non-foil only.
  bool? _foil;
  /// null = any condition; otherwise minimum accepted grade.
  CardCondition? _minCondition;

  bool _loadingNames = false;
  bool _loadingPrintings = false;
  String? _error;
  Timer? _debounce;
  int _gen = 0;
  /// Separate counter so filter changes don't cancel name/printing loads.
  int _priceGen = 0;

  @override
  void initState() {
    super.initState();
    _query.addListener(_onQueryChanged);
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
        _nameSuggestions = [];
        _printings = [];
        _resolvedName = null;
        _loadingNames = false;
        _loadingPrintings = false;
        _error = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 320), _onDebouncedQuery);
  }

  Future<void> _onDebouncedQuery() async {
    final text = _query.text.trim();
    if (text.length < 2) return;
    final gen = ++_gen;

    setState(() {
      _loadingNames = true;
      _error = null;
    });

    try {
      final scryfall = context.read<ScryfallClient>();
      final names = await scryfall.autocomplete(text);
      if (!mounted || gen != _gen) return;

      setState(() {
        _nameSuggestions = names;
        _loadingNames = false;
      });

      // Prefer exact name match; otherwise if only one suggestion, use it;
      // otherwise if the typed text equals the nearest suggestion ignoring case.
      String? chosen;
      for (final n in names) {
        if (n.toLowerCase() == text.toLowerCase()) {
          chosen = n;
          break;
        }
      }
      chosen ??= names.length == 1 ? names.first : null;
      if (chosen == null && names.isNotEmpty) {
        final top = names.first;
        if (top.toLowerCase().startsWith(text.toLowerCase()) &&
            text.length >= 4) {
          // Wait until user picks or types the full name for multi-match.
        }
      }

      if (chosen != null) {
        await _loadPrintingsForName(chosen, gen);
      } else {
        setState(() {
          _printings = [];
          _resolvedName = null;
        });
      }
    } catch (e) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _loadingNames = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _selectName(String name) async {
    _query.removeListener(_onQueryChanged);
    _query.text = name;
    _query.selection = TextSelection.collapsed(offset: name.length);
    _query.addListener(_onQueryChanged);
    final gen = ++_gen;
    setState(() {
      _nameSuggestions = [name];
      _error = null;
    });
    await _loadPrintingsForName(name, gen);
  }

  Future<void> _loadPrintingsForName(String name, int gen) async {
    setState(() {
      _loadingPrintings = true;
      _resolvedName = name;
      _printings = [];
      _markets.clear();
      _expandedKeys.clear();
      _priceErrors.clear();
      _loadingPrices.clear();
      _priceGen++;
    });

    try {
      final scryfall = context.read<ScryfallClient>();
      final ct = context.read<CardTraderClient>();

      // Warm CT expansion index once.
      await ct.listMtgExpansions();
      if (!mounted || gen != _gen) return;

      final printings = await scryfall.printingsForExactName(name);
      if (!mounted || gen != _gen) return;

      final rows = <_PrintingRow>[];
      for (final p in printings) {
        CtBlueprint? bp;
        try {
          bp = await ct.blueprintForPrinting(
            setCode: p.setCode,
            cardName: p.name,
            scryfallId: p.id,
          );
        } catch (_) {
          bp = null;
        }
        rows.add(_PrintingRow(printing: p, blueprint: bp));
        if (!mounted || gen != _gen) return;
        // Light pause when resolving many sets against CT.
        if (rows.length % 5 == 0) {
          await Future<void>.delayed(const Duration(milliseconds: 50));
        }
      }

      if (!mounted || gen != _gen) return;
      setState(() {
        _printings = rows;
        _loadingPrintings = false;
      });

      final withBp = rows
          .where((r) => r.blueprintId != null)
          .map((r) => r.blueprintId!)
          .toList();
      unawaited(_prefetchPrices(withBp));
    } catch (e) {
      if (!mounted || gen != _gen) return;
      setState(() {
        _loadingPrintings = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _prefetchPrices(List<int> blueprintIds) async {
    final priceGen = ++_priceGen;
    final ct = context.read<CardTraderClient>();
    for (final id in blueprintIds) {
      if (!mounted || priceGen != _priceGen) return;
      if (_markets.containsKey(id) || _loadingPrices.contains(id)) continue;
      setState(() => _loadingPrices.add(id));
      try {
        final market = await ct.marketplaceForBlueprint(
          id,
          foil: _foil,
          language: _language,
          minCondition: _minCondition,
        );
        if (!mounted || priceGen != _priceGen) return;
        setState(() {
          _markets[id] = market;
          _priceErrors.remove(id);
          _loadingPrices.remove(id);
        });
      } catch (e) {
        if (!mounted || priceGen != _priceGen) return;
        setState(() {
          _priceErrors[id] = e.toString();
          _loadingPrices.remove(id);
        });
      }
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }
  }

  Future<void> _ensurePrice(int blueprintId) async {
    if (_markets.containsKey(blueprintId) ||
        _loadingPrices.contains(blueprintId)) {
      return;
    }
    final priceGen = _priceGen;
    setState(() => _loadingPrices.add(blueprintId));
    try {
      final market = await context.read<CardTraderClient>().marketplaceForBlueprint(
            blueprintId,
            foil: _foil,
            language: _language,
            minCondition: _minCondition,
          );
      if (!mounted || priceGen != _priceGen) return;
      setState(() {
        _markets[blueprintId] = market;
        _priceErrors.remove(blueprintId);
        _loadingPrices.remove(blueprintId);
      });
    } catch (e) {
      if (!mounted || priceGen != _priceGen) return;
      setState(() {
        _priceErrors[blueprintId] = e.toString();
        _loadingPrices.remove(blueprintId);
      });
    }
  }

  /// Clears cached prices and reloads for visible printings when filters change.
  void _onFiltersChanged() {
    setState(() {
      _markets.clear();
      _priceErrors.clear();
      _loadingPrices.clear();
    });
    final withBp = _printings
        .where((r) => r.blueprintId != null)
        .map((r) => r.blueprintId!)
        .toList();
    if (withBp.isNotEmpty) {
      unawaited(_prefetchPrices(withBp));
    }
  }

  Future<void> _toggleExpand(_PrintingRow row) async {
    final key = row.key;
    final opening = !_expandedKeys.contains(key);
    setState(() {
      if (opening) {
        _expandedKeys.add(key);
      } else {
        _expandedKeys.remove(key);
      }
    });
    final bpId = row.blueprintId;
    if (opening && bpId != null) await _ensurePrice(bpId);
  }

  Future<void> _add(_PrintingRow row) async {
    final bp = row.blueprint;
    if (bp == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No CardTrader match for this printing yet'),
        ),
      );
      return;
    }
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          [
            'Adding ${bp.name}',
            if (_foil == true) '(foil)',
            if (_foil == false) '(non-foil)',
            '… fetching prices',
          ].join(' '),
        ),
      ),
    );
    final cardId = await context.read<AppDatabase>().upsertWatchlistCard(
          name: bp.name,
          expansion: bp.expansionName ?? row.printing.setName,
          cardTraderBlueprintId: bp.id,
          cardTraderExpansionId: bp.expansionId,
          imageUrl: row.imageUrl ?? bp.absoluteImageUrl,
          foil: _foil,
          language: _language,
          minCondition: _minCondition?.label,
        );
    if (!mounted) return;

    // Pull CT + CM prices immediately so the watchlist isn't empty.
    final outcome = await context.read<SyncService>().syncWatchlistCard(cardId);
    if (!mounted) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          outcome.success
              ? 'Added ${bp.name} (${row.printing.setName})'
              : 'Added ${bp.name}, but prices failed: ${outcome.message}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showNamePicker =
        _nameSuggestions.isNotEmpty && _resolvedName == null && !_loadingPrintings;

    return Scaffold(
      appBar: AppBar(title: const Text('Search / Add')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _query,
              focusNode: _focus,
              decoration: InputDecoration(
                labelText: 'Card name',
                hintText: 'e.g. Counterspell',
                helperText:
                    'Type a name — every printing across sets appears below',
                border: const OutlineInputBorder(),
                suffixIcon: (_loadingNames || _loadingPrintings)
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
                          setState(() {
                            _nameSuggestions = [];
                            _printings = [];
                            _resolvedName = null;
                            _error = null;
                          });
                        },
                      ),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (v) async {
                final text = v.trim();
                if (text.isEmpty) return;
                String? pick;
                for (final n in _nameSuggestions) {
                  if (n.toLowerCase() == text.toLowerCase()) {
                    pick = n;
                    break;
                  }
                }
                pick ??= _nameSuggestions.isNotEmpty
                    ? _nameSuggestions.first
                    : text;
                await _selectName(pick);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: _ListingFilters(
              language: _language,
              foil: _foil,
              minCondition: _minCondition,
              onLanguageChanged: (v) {
                setState(() => _language = v);
                _onFiltersChanged();
              },
              onFoilChanged: (v) {
                setState(() => _foil = v);
                _onFiltersChanged();
              },
              onMinConditionChanged: (v) {
                setState(() => _minCondition = v);
                _onFiltersChanged();
              },
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
          if (showNamePicker)
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _nameSuggestions.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final name = _nameSuggestions[i];
                  return ActionChip(
                    label: Text(name),
                    onPressed: () => _selectName(name),
                  );
                },
              ),
            ),
          if (_resolvedName != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _loadingPrintings
                      ? 'Loading all printings of $_resolvedName…'
                      : '${_printings.length} printings of $_resolvedName',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
          Expanded(
            child: _buildBody(showNamePicker),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool showNamePicker) {
    if (_loadingPrintings && _printings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_printings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            showNamePicker
                ? 'Tap a suggested name to see every expansion printing.'
                : 'Type a card name (at least 2 characters).',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _printings.length,
      itemBuilder: (context, i) {
        final row = _printings[i];
        final bpId = row.blueprintId;
        final market = bpId == null ? null : _markets[bpId];
        final expanded = _expandedKeys.contains(row.key);
        final loadingPrice = bpId != null && _loadingPrices.contains(bpId);
        final top5 = market?.bestListings(limit: 5) ?? const [];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            elevation: 1,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(12),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                InkWell(
                  onTap: () => _toggleExpand(row),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CardThumb(url: row.imageUrl),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                row.name,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                row.setLabel,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 8),
                              if (bpId == null)
                                Text(
                                  'No CardTrader listing link for this set yet',
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              else if (loadingPrice && market == null)
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
                                    if (market.minDirectCents != null)
                                      _PriceChip(
                                        label: 'Direct',
                                        value: formatEurCents(
                                          market.minDirectCents,
                                        ),
                                      ),
                                  ],
                                )
                              else if (_priceErrors[bpId] != null)
                                Text(
                                  'Price unavailable',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                )
                              else
                                Text(
                                  'Tap for seller prices',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              tooltip: 'Add to watchlist',
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => _add(row),
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
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Zero = CardTrader hub. Direct = seller ships.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        if (bpId == null)
                          const Text('Cannot load CT sellers without a blueprint match.')
                        else if (loadingPrice && top5.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (top5.isEmpty)
                          const Text('No live listings found.')
                        else
                          ...top5.map(
                            (l) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(l.sellerName ?? 'Unknown seller'),
                              subtitle: Text(
                                [
                                  if (l.canSellViaHub) 'Zero',
                                  if (!l.canSellViaHub) 'Direct',
                                  if (l.language != null)
                                    CardLanguages.labelFor(l.language),
                                  if (l.condition != null) l.condition,
                                  if (l.foil == true) 'Foil',
                                  if (l.foil == false) 'Non-foil',
                                  if (l.quantity != null) 'qty ${l.quantity}',
                                ].join(' · '),
                              ),
                              trailing: Text(
                                formatEurCents(l.priceCents),
                                style: Theme.of(context).textTheme.titleSmall,
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
    );
  }
}

class _ListingFilters extends StatelessWidget {
  const _ListingFilters({
    required this.language,
    required this.foil,
    required this.minCondition,
    required this.onLanguageChanged,
    required this.onFoilChanged,
    required this.onMinConditionChanged,
  });

  final String? language;
  final bool? foil;
  final CardCondition? minCondition;
  final ValueChanged<String?> onLanguageChanged;
  final ValueChanged<bool?> onFoilChanged;
  final ValueChanged<CardCondition?> onMinConditionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Listing filters (also saved when you add to the watchlist)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String?>(
                // ignore: deprecated_member_use
                value: language,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Language',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ...CardLanguages.options.map(
                    (o) => DropdownMenuItem<String?>(
                      value: o.$1,
                      child: Text(o.$2, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: onLanguageChanged,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: foil == null ? 'any' : (foil! ? 'foil' : 'non'),
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Foil',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'any', child: Text('Any')),
                  DropdownMenuItem(value: 'foil', child: Text('Foil only')),
                  DropdownMenuItem(value: 'non', child: Text('Non-foil')),
                ],
                onChanged: (v) {
                  if (v == null || v == 'any') {
                    onFoilChanged(null);
                  } else if (v == 'foil') {
                    onFoilChanged(true);
                  } else {
                    onFoilChanged(false);
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<CardCondition?>(
          // ignore: deprecated_member_use
          value: minCondition,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Min. condition',
            helperText: 'Includes this grade and better (e.g. SP includes NM)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: [
            const DropdownMenuItem<CardCondition?>(
              value: null,
              child: Text('Any'),
            ),
            ...CardCondition.values.map(
              (c) => DropdownMenuItem<CardCondition?>(
                value: c,
                child: Text(c.label),
              ),
            ),
          ],
          onChanged: onMinConditionChanged,
        ),
      ],
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
