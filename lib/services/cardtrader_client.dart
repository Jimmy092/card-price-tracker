import 'package:dio/dio.dart';

/// CardTrader API v2 client (EUR marketplace, Zero via `user.can_sell_via_hub`).
class CardTraderClient {
  CardTraderClient({
    required this.tokenProvider,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.cardtrader.com/api/v2',
                connectTimeout: const Duration(seconds: 20),
                receiveTimeout: const Duration(seconds: 60),
                headers: {'Accept': 'application/json'},
              ),
            );

  final Future<String?> Function() tokenProvider;
  final Dio _dio;

  static const int mtgGameId = 1;

  /// In-memory blueprint cache keyed by expansion id.
  final Map<int, List<CtBlueprint>> _blueprintCache = {};
  /// Scryfall id → blueprint, built when an expansion is exported.
  final Map<String, CtBlueprint> _blueprintByScryfallId = {};
  /// In-flight expansion exports so parallel callers share one request.
  final Map<int, Future<List<CtBlueprint>>> _blueprintInflight = {};
  List<CtExpansion>? _mtgExpansionsCache;
  Map<String, CtExpansion>? _expansionsByCode;

  Future<void> _auth() async {
    final token = await tokenProvider();
    if (token == null || token.isEmpty) {
      throw CardTraderException('CardTrader token not set. Add it in Settings.');
    }
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<CtAppInfo> getInfo() async {
    await _auth();
    final res = await _dio.get<Map<String, dynamic>>('/info');
    return CtAppInfo.fromJson(res.data!);
  }

  Future<List<CtExpansion>> listMtgExpansions({bool forceRefresh = false}) async {
    if (!forceRefresh && _mtgExpansionsCache != null) {
      return _mtgExpansionsCache!;
    }
    await _auth();
    final res = await _dio.get<List<dynamic>>('/expansions');
    final all = (res.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CtExpansion.fromJson)
        .toList();
    final mtg = all.where((e) => e.gameId == mtgGameId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    _mtgExpansionsCache = mtg;
    _expansionsByCode = {
      for (final e in mtg)
        if (e.code != null && e.code!.isNotEmpty) e.code!.toLowerCase(): e,
    };
    return mtg;
  }

  Future<CtExpansion?> expansionForSetCode(String setCode) async {
    await listMtgExpansions();
    return _expansionsByCode?[setCode.toLowerCase()];
  }

  /// Resolve a Scryfall printing to a CardTrader blueprint (by scryfall id, then name).
  Future<CtBlueprint?> blueprintForPrinting({
    required String setCode,
    required String cardName,
    String? scryfallId,
  }) async {
    final expansion = await expansionForSetCode(setCode);
    if (expansion == null) return null;
    final blueprints = await listBlueprints(expansion.id);
    return _matchBlueprint(
      blueprints,
      expansionName: expansion.name,
      cardName: cardName,
      scryfallId: scryfallId,
    );
  }

  /// Resolve many Scryfall printings at once.
  ///
  /// Groups by unique set code, fetches each expansion export in parallel
  /// (bounded concurrency), then matches locally — much faster than
  /// one-by-one [blueprintForPrinting] for heavily reprinted cards.
  Future<List<CtBlueprint?>> blueprintsForPrintings(
    List<({String setCode, String cardName, String? scryfallId})> printings, {
    int concurrency = 6,
  }) async {
    if (printings.isEmpty) return const [];
    await listMtgExpansions();

    final uniqueCodes = <String>{};
    for (final p in printings) {
      final code = p.setCode.trim().toLowerCase();
      if (code.isNotEmpty) uniqueCodes.add(code);
    }

    final expansionIds = <int>[];
    final seenExp = <int>{};
    for (final code in uniqueCodes) {
      final exp = _expansionsByCode?[code];
      if (exp != null && seenExp.add(exp.id)) {
        expansionIds.add(exp.id);
      }
    }

    await _mapPool(
      expansionIds,
      concurrency: concurrency,
      fn: (id) async {
        await listBlueprints(id);
      },
    );

    return [
      for (final p in printings)
        _resolveCachedPrinting(
          setCode: p.setCode,
          cardName: p.cardName,
          scryfallId: p.scryfallId,
        ),
    ];
  }

  CtBlueprint? _resolveCachedPrinting({
    required String setCode,
    required String cardName,
    String? scryfallId,
  }) {
    if (scryfallId != null && scryfallId.isNotEmpty) {
      final byId = _blueprintByScryfallId[scryfallId];
      if (byId != null) {
        final exp = _expansionsByCode?[setCode.toLowerCase()];
        return exp != null ? byId.copyWithExpansionName(exp.name) : byId;
      }
    }
    final expansion = _expansionsByCode?[setCode.toLowerCase()];
    if (expansion == null) return null;
    final blueprints = _blueprintCache[expansion.id];
    if (blueprints == null) return null;
    return _matchBlueprint(
      blueprints,
      expansionName: expansion.name,
      cardName: cardName,
      scryfallId: scryfallId,
    );
  }

  CtBlueprint? _matchBlueprint(
    List<CtBlueprint> blueprints, {
    required String expansionName,
    required String cardName,
    String? scryfallId,
  }) {
    if (scryfallId != null && scryfallId.isNotEmpty) {
      for (final b in blueprints) {
        if (b.scryfallId == scryfallId) {
          return b.copyWithExpansionName(expansionName);
        }
      }
    }
    final target = cardName.toLowerCase();
    for (final b in blueprints) {
      if (b.name.toLowerCase() == target) {
        return b.copyWithExpansionName(expansionName);
      }
    }
    // Split card faces: "Fire // Ice" vs front face only.
    final front = target.split('//').first.trim();
    for (final b in blueprints) {
      if (b.name.toLowerCase() == front) {
        return b.copyWithExpansionName(expansionName);
      }
    }
    return null;
  }

  Future<List<CtBlueprint>> listBlueprints(
    int expansionId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _blueprintCache.containsKey(expansionId)) {
      return _blueprintCache[expansionId]!;
    }
    final inflight = _blueprintInflight[expansionId];
    if (!forceRefresh && inflight != null) return inflight;

    final future = () async {
      await _auth();
      final res = await _dio.get<List<dynamic>>(
        '/blueprints/export',
        queryParameters: {'expansion_id': expansionId},
      );
      final list = (res.data ?? [])
          .whereType<Map<String, dynamic>>()
          .map(CtBlueprint.fromJson)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      _blueprintCache[expansionId] = list;
      for (final b in list) {
        final sid = b.scryfallId;
        if (sid != null && sid.isNotEmpty) {
          _blueprintByScryfallId[sid] = b;
        }
      }
      return list;
    }();

    _blueprintInflight[expansionId] = future;
    try {
      return await future;
    } finally {
      _blueprintInflight.remove(expansionId);
    }
  }

  /// Fetch marketplace summaries for many blueprints with bounded concurrency.
  Future<Map<int, CtMarketplaceSummary>> marketplacesForBlueprints(
    Iterable<int> blueprintIds, {
    bool? foil,
    String? language,
    CardCondition? minCondition,
    String? sellerName,
    int? minQuantity,
    int concurrency = 5,
    bool Function()? shouldContinue,
    void Function(int blueprintId, CtMarketplaceSummary summary)? onEach,
    void Function(int blueprintId, Object error)? onError,
  }) async {
    final ids = blueprintIds.toList();
    final out = <int, CtMarketplaceSummary>{};
    await _mapPool(
      ids,
      concurrency: concurrency,
      fn: (id) async {
        if (shouldContinue != null && !shouldContinue()) return;
        try {
          final summary = await marketplaceForBlueprint(
            id,
            foil: foil,
            language: language,
            minCondition: minCondition,
            sellerName: sellerName,
            minQuantity: minQuantity,
          );
          if (shouldContinue != null && !shouldContinue()) return;
          out[id] = summary;
          onEach?.call(id, summary);
        } catch (e) {
          onError?.call(id, e);
        }
      },
    );
    return out;
  }

  /// Run [fn] over [items] with at most [concurrency] in flight.
  Future<void> _mapPool<T>(
    List<T> items, {
    required int concurrency,
    required Future<void> Function(T item) fn,
  }) async {
    if (items.isEmpty) return;
    final limit = concurrency < 1 ? 1 : concurrency;
    var next = 0;
    Future<void> worker() async {
      while (true) {
        final i = next++;
        if (i >= items.length) return;
        await fn(items[i]);
      }
    }

    await Future.wait(
      List.generate(
        limit < items.length ? limit : items.length,
        (_) => worker(),
      ),
    );
  }

  /// Instant local filter against a cached expansion (load once, suggest as user types).
  Future<List<CtBlueprint>> suggestBlueprints(
    String query, {
    required int expansionId,
    int limit = 20,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.length < 2) return [];
    final pool = await listBlueprints(expansionId);
    final starts = <CtBlueprint>[];
    final contains = <CtBlueprint>[];
    for (final b in pool) {
      final name = b.name.toLowerCase();
      if (name.startsWith(q)) {
        starts.add(b);
      } else if (name.contains(q)) {
        contains.add(b);
      }
      if (starts.length >= limit) break;
    }
    return [...starts, ...contains].take(limit).toList();
  }

  Future<List<CtBlueprint>> searchBlueprintsByName(
    String query, {
    int? expansionId,
    int limit = 40,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    if (expansionId != null) {
      return suggestBlueprints(query, expansionId: expansionId, limit: limit);
    }

    final expansions = await listMtgExpansions();
    final pool = <CtBlueprint>[];
    for (final exp in expansions.take(8)) {
      pool.addAll(await listBlueprints(exp.id));
      if (pool.length > 2000) break;
    }

    return pool
        .where((b) => b.name.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// Marketplace listings for a blueprint. Separates Zero vs direct mins.
  ///
  /// [foil] and [language] are sent to CardTrader (`foil`, `language` query
  /// params). [minCondition], [sellerName], and [minQuantity] are applied
  /// client-side on the returned listings.
  Future<CtMarketplaceSummary> marketplaceForBlueprint(
    int blueprintId, {
    bool? foil,
    String? language,
    CardCondition? minCondition,
    String? sellerName,
    int? minQuantity,
  }) async {
    await _auth();
    final query = <String, dynamic>{'blueprint_id': blueprintId};
    if (foil != null) query['foil'] = foil;
    if (language != null && language.isNotEmpty) query['language'] = language;

    final res = await _dio.get<Map<String, dynamic>>(
      '/marketplace/products',
      queryParameters: query,
    );

    final data = res.data ?? {};
    final key = blueprintId.toString();
    final rawList = data[key];
    var listings = <CtListing>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          listings.add(CtListing.fromJson(item));
        }
      }
    }

    // Belt-and-suspenders: CT sometimes ignores foil query — filter locally.
    if (foil == true) {
      listings = listings.where((l) => l.foil == true).toList();
    } else if (foil == false) {
      listings = listings.where((l) => l.foil != true).toList();
    }

    // Belt-and-suspenders: CT sometimes ignores language query.
    if (language != null && language.isNotEmpty) {
      final lang = language.toLowerCase();
      final tagged = listings
          .where((l) => (l.language ?? '').trim().isNotEmpty)
          .toList();
      if (tagged.isNotEmpty) {
        listings = tagged
            .where((l) => (l.language ?? '').toLowerCase() == lang)
            .toList();
      }
    }

    if (minCondition != null) {
      listings = listings
          .where((l) => CardCondition.meetsMinimum(l.condition, minCondition))
          .toList();
    }

    final sellerQ = sellerName?.trim().toLowerCase();
    if (sellerQ != null && sellerQ.isNotEmpty) {
      listings = listings
          .where(
            (l) => (l.sellerName ?? '').toLowerCase().contains(sellerQ),
          )
          .toList();
    }

    if (minQuantity != null && minQuantity > 0) {
      listings = listings
          .where((l) => (l.quantity ?? 0) >= minQuantity)
          .toList();
    }

    listings.sort((a, b) {
      final ac = a.priceCents ?? 1 << 30;
      final bc = b.priceCents ?? 1 << 30;
      return ac.compareTo(bc);
    });

    int? minDirect;
    int? minZero;
    var zeroCount = 0;
    for (final l in listings) {
      final cents = l.priceCents;
      if (cents == null) continue;
      if (l.canSellViaHub) {
        zeroCount++;
        if (minZero == null || cents < minZero) minZero = cents;
      } else {
        if (minDirect == null || cents < minDirect) minDirect = cents;
      }
    }

    return CtMarketplaceSummary(
      blueprintId: blueprintId,
      listings: listings,
      minDirectCents: minDirect,
      minZeroCents: minZero,
      listingCount: listings.length,
      zeroListingCount: zeroCount,
    );
  }
}

/// MTG card condition ordered from best (Near Mint) to worst (Poor).
enum CardCondition {
  nearMint('Near Mint'),
  slightlyPlayed('Slightly Played'),
  moderatelyPlayed('Moderately Played'),
  played('Played'),
  heavilyPlayed('Heavily Played'),
  poor('Poor');

  const CardCondition(this.label);
  final String label;

  /// Higher = better condition.
  int get rank => CardCondition.values.length - index;

  static CardCondition? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final lower = raw.toLowerCase();
    for (final c in CardCondition.values) {
      if (c.label.toLowerCase() == lower) return c;
    }
    return null;
  }

  /// True when [listingCondition] is at least as good as [minimum].
  static bool meetsMinimum(String? listingCondition, CardCondition minimum) {
    final parsed = tryParse(listingCondition);
    if (parsed == null) return false;
    return parsed.rank >= minimum.rank;
  }
}

/// Common MTG language codes used by CardTrader (`mtg_language` / `language`).
class CardLanguages {
  CardLanguages._();

  static const any = '';
  static const options = <(String code, String label)>[
    ('en', 'English'),
    ('de', 'German'),
    ('fr', 'French'),
    ('it', 'Italian'),
    ('es', 'Spanish'),
    ('pt', 'Portuguese'),
    ('jp', 'Japanese'),
    ('kr', 'Korean'),
    ('ru', 'Russian'),
    ('zh-CN', 'Chinese (Simplified)'),
    ('zh-TW', 'Chinese (Traditional)'),
    ('nl', 'Dutch'),
    ('cz', 'Czech'),
    ('hu', 'Hungarian'),
    ('pl', 'Polish'),
  ];

  static String labelFor(String? code) {
    if (code == null || code.isEmpty) return 'Any';
    for (final o in options) {
      if (o.$1 == code) return o.$2;
    }
    return code;
  }
}

class CardTraderException implements Exception {
  CardTraderException(this.message);
  final String message;
  @override
  String toString() => message;
}

class CtAppInfo {
  CtAppInfo({required this.id, required this.name, this.userId});
  factory CtAppInfo.fromJson(Map<String, dynamic> json) => CtAppInfo(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        userId: json['user_id'] as int?,
      );
  final int id;
  final String name;
  final int? userId;
}

class CtExpansion {
  CtExpansion({
    required this.id,
    required this.name,
    required this.gameId,
    this.code,
  });
  factory CtExpansion.fromJson(Map<String, dynamic> json) => CtExpansion(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        gameId: json['game_id'] as int? ?? 0,
        code: json['code'] as String?,
      );
  final int id;
  final String name;
  final int gameId;
  final String? code;
}

class CtBlueprint {
  CtBlueprint({
    required this.id,
    required this.name,
    required this.expansionId,
    this.expansionName,
    this.imageUrl,
    this.scryfallId,
  });

  factory CtBlueprint.fromJson(Map<String, dynamic> json) {
    final expansion = json['expansion'];
    String? expansionName;
    int expansionId = json['expansion_id'] as int? ?? 0;
    if (expansion is Map<String, dynamic>) {
      expansionName = expansion['name'] as String? ?? expansion['code'] as String?;
      expansionId = expansion['id'] as int? ?? expansionId;
    }

    String? imageUrl = json['image_url'] as String?;
    final image = json['image'];
    if ((imageUrl == null || imageUrl.isEmpty) && image is Map<String, dynamic>) {
      imageUrl = image['show'] as String? ??
          image['preview'] as String? ??
          image['url'] as String?;
    }

    return CtBlueprint(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      expansionId: expansionId,
      expansionName: expansionName,
      imageUrl: imageUrl,
      scryfallId: json['scryfall_id'] as String?,
    );
  }

  final int id;
  final String name;
  final int expansionId;
  final String? expansionName;
  final String? imageUrl;
  final String? scryfallId;

  CtBlueprint copyWithExpansionName(String name) => CtBlueprint(
        id: id,
        name: this.name,
        expansionId: expansionId,
        expansionName: name,
        imageUrl: imageUrl,
        scryfallId: scryfallId,
      );

  String? get absoluteImageUrl {
    final u = imageUrl?.trim();
    if (u == null || u.isEmpty) return null;
    if (u.startsWith('http://') || u.startsWith('https://')) return u;
    if (u.startsWith('//')) return 'https:$u';
    if (u.startsWith('/')) return 'https://www.cardtrader.com$u';
    return 'https://www.cardtrader.com/$u';
  }
}

class CtListing {
  CtListing({
    required this.id,
    required this.priceCents,
    required this.canSellViaHub,
    this.quantity,
    this.sellerName,
    this.condition,
    this.foil,
    this.language,
  });

  factory CtListing.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    var canHub = false;
    String? seller;
    if (user is Map<String, dynamic>) {
      canHub = user['can_sell_via_hub'] == true;
      seller = user['username'] as String?;
    }
    final priceObj = json['price'];
    int? cents = json['price_cents'] as int?;
    if (cents == null && priceObj is Map<String, dynamic>) {
      cents = priceObj['cents'] as int?;
    }
    final props = json['properties_hash'] ?? json['properties'];
    String? condition;
    bool? foil;
    String? language;
    if (props is Map<String, dynamic>) {
      condition = props['condition'] as String?;
      foil = props['mtg_foil'] as bool? ?? props['foil'] as bool?;
      language = props['mtg_language'] as String? ?? props['language'] as String?;
    }
    return CtListing(
      id: json['id'] as int? ?? 0,
      priceCents: cents,
      canSellViaHub: canHub,
      quantity: json['quantity'] as int?,
      sellerName: seller,
      condition: condition,
      foil: foil,
      language: language,
    );
  }

  final int id;
  final int? priceCents;
  final bool canSellViaHub;
  final int? quantity;
  final String? sellerName;
  final String? condition;
  final bool? foil;
  final String? language;
}

class CtMarketplaceSummary {
  CtMarketplaceSummary({
    required this.blueprintId,
    required this.listings,
    required this.minDirectCents,
    required this.minZeroCents,
    required this.listingCount,
    required this.zeroListingCount,
  });

  final int blueprintId;
  final List<CtListing> listings;
  final int? minDirectCents;
  final int? minZeroCents;
  final int listingCount;
  final int zeroListingCount;

  /// Prefer Zero min when available; otherwise cheapest direct listing.
  int? get bestPriceCents => minZeroCents ?? minDirectCents;

  /// Cheapest listings first (already sorted by client).
  List<CtListing> bestListings({int limit = 5}) =>
      listings.where((l) => l.priceCents != null).take(limit).toList();
}
