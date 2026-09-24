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

  Future<List<CtExpansion>> listMtgExpansions() async {
    await _auth();
    final res = await _dio.get<List<dynamic>>('/expansions');
    final all = (res.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CtExpansion.fromJson)
        .toList();
    return all.where((e) => e.gameId == mtgGameId).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<CtBlueprint>> listBlueprints(int expansionId) async {
    await _auth();
    final res = await _dio.get<List<dynamic>>(
      '/blueprints/export',
      queryParameters: {'expansion_id': expansionId},
    );
    return (res.data ?? [])
        .whereType<Map<String, dynamic>>()
        .map(CtBlueprint.fromJson)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<CtBlueprint>> searchBlueprintsByName(
    String query, {
    int? expansionId,
    int limit = 40,
  }) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];

    List<CtBlueprint> pool;
    if (expansionId != null) {
      pool = await listBlueprints(expansionId);
    } else {
      // Expansion-scoped search is preferred; without it, scan a few recent expansions.
      final expansions = await listMtgExpansions();
      pool = [];
      for (final exp in expansions.take(8)) {
        pool.addAll(await listBlueprints(exp.id));
        if (pool.length > 2000) break;
      }
    }

    return pool
        .where((b) => b.name.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// Marketplace listings for a blueprint. Separates Zero vs direct mins.
  Future<CtMarketplaceSummary> marketplaceForBlueprint(int blueprintId) async {
    await _auth();
    final res = await _dio.get<Map<String, dynamic>>(
      '/marketplace/products',
      queryParameters: {'blueprint_id': blueprintId},
    );

    final data = res.data ?? {};
    final key = blueprintId.toString();
    final rawList = data[key];
    final listings = <CtListing>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          listings.add(CtListing.fromJson(item));
        }
      }
    }

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
  });
  factory CtBlueprint.fromJson(Map<String, dynamic> json) {
    final expansion = json['expansion'];
    String? expansionName;
    int expansionId = json['expansion_id'] as int? ?? 0;
    if (expansion is Map<String, dynamic>) {
      expansionName = expansion['name'] as String?;
      expansionId = expansion['id'] as int? ?? expansionId;
    }
    return CtBlueprint(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      expansionId: expansionId,
      expansionName: expansionName,
    );
  }
  final int id;
  final String name;
  final int expansionId;
  final String? expansionName;
}

class CtListing {
  CtListing({
    required this.id,
    required this.priceCents,
    required this.canSellViaHub,
    this.quantity,
    this.sellerName,
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
    return CtListing(
      id: json['id'] as int? ?? 0,
      priceCents: cents,
      canSellViaHub: canHub,
      quantity: json['quantity'] as int?,
      sellerName: seller,
    );
  }

  final int id;
  final int? priceCents;
  final bool canSellViaHub;
  final int? quantity;
  final String? sellerName;
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
}
