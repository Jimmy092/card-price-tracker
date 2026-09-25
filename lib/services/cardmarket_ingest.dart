import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Cardmarket public MTG catalogue + daily price guide ingest (game id 1).
///
/// Prefer official JSON downloads; also accepts CSV/JSON via file picker.
class CardmarketIngest {
  CardmarketIngest({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(minutes: 3),
              ),
            );

  final Dio _dio;

  static const productsSinglesUrl =
      'https://downloads.s3.cardmarket.com/productCatalog/productList/products_singles_1.json';
  static const priceGuideUrl =
      'https://downloads.s3.cardmarket.com/productCatalog/priceGuide/price_guide_1.json';

  Future<Directory> _cacheDir() async {
    final root = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(root.path, 'cardmarket'));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir;
  }

  Future<File> _productsFile() async =>
      File(p.join((await _cacheDir()).path, 'products_singles_1.json'));

  Future<File> _priceGuideFile() async =>
      File(p.join((await _cacheDir()).path, 'price_guide_1.json'));

  Future<CardmarketDownloadResult> downloadGuides({
    void Function(String step)? onProgress,
  }) async {
    onProgress?.call('Downloading MTG singles catalogue…');
    final products = await _productsFile();
    await _downloadTo(productsSinglesUrl, products);

    onProgress?.call('Downloading MTG price guide…');
    final guide = await _priceGuideFile();
    await _downloadTo(priceGuideUrl, guide);

    final productsCount = await _countProductsJson(products);
    final pricesCount = await _countPriceGuidesJson(guide);
    return CardmarketDownloadResult(
      productsPath: products.path,
      priceGuidePath: guide.path,
      productsCount: productsCount,
      pricesCount: pricesCount,
    );
  }

  Future<void> _downloadTo(String url, File dest) async {
    final tmp = File('${dest.path}.tmp');
    await _dio.download(url, tmp.path);
    if (await dest.exists()) await dest.delete();
    await tmp.rename(dest.path);
  }

  Future<Map<int, CmProduct>> loadProducts({String? overridePath}) async {
    final file = overridePath != null
        ? File(overridePath)
        : await _productsFile();
    if (!await file.exists()) return {};

    if (file.path.toLowerCase().endsWith('.csv')) {
      return _parseProductsCsv(await file.readAsString());
    }
    return _parseProductsJson(await file.readAsString());
  }

  Future<Map<int, CmPriceGuide>> loadPriceGuide({String? overridePath}) async {
    final file = overridePath != null
        ? File(overridePath)
        : await _priceGuideFile();
    if (!await file.exists()) return {};

    if (file.path.toLowerCase().endsWith('.csv')) {
      return _parsePriceGuideCsv(await file.readAsString());
    }
    return _parsePriceGuideJson(await file.readAsString());
  }

  Future<CardmarketCacheStatus> cacheStatus() async {
    final products = await _productsFile();
    final guide = await _priceGuideFile();
    return CardmarketCacheStatus(
      productsExists: await products.exists(),
      priceGuideExists: await guide.exists(),
      productsModified: await products.exists() ? await products.lastModified() : null,
      priceGuideModified:
          await guide.exists() ? await guide.lastModified() : null,
    );
  }

  Map<int, CmProduct>? _productsCache;
  Map<int, CmPriceGuide>? _guidesCache;
  Map<String, List<CmProduct>>? _productsByName;

  /// Loads (and caches) catalogue + guide for fast name → trend lookups.
  Future<bool> ensureLookupReady({bool forceReload = false}) async {
    if (!forceReload &&
        _productsCache != null &&
        _guidesCache != null &&
        _productsByName != null) {
      return true;
    }
    final status = await cacheStatus();
    if (!status.ready) return false;
    final products = await loadProducts();
    final guides = await loadPriceGuide();
    final byName = <String, List<CmProduct>>{};
    for (final p in products.values) {
      final key = p.name.trim().toLowerCase();
      if (key.isEmpty) continue;
      (byName[key] ??= []).add(p);
    }
    _productsCache = products;
    _guidesCache = guides;
    _productsByName = byName;
    return true;
  }

  /// Exact product-id lookup (preferred — one printing = one CM product).
  int? trendCentsForProductId(int productId, {bool? foil}) {
    final guides = _guidesCache;
    if (guides == null) return null;
    final guide = guides[productId];
    if (guide == null) return null;
    return guide.centsFor(foil: foil).trend;
  }

  /// Cardmarket "From" price (guide `low` / `low-foil`) for a product id.
  int? fromCentsForProductId(int productId, {bool? foil}) {
    final guides = _guidesCache;
    if (guides == null) return null;
    final guide = guides[productId];
    if (guide == null) return null;
    return guide.centsFor(foil: foil).low;
  }

  /// Cardmarket "From" price (EUR cents) for a printing — guide low / low-foil.
  int? fromCentsForPrinting({
    required String name,
    String? collectorNumber,
    String? setName,
    bool? foil,
    int? preferNearCents,
    int? cardmarketId,
  }) {
    if (cardmarketId != null) {
      final exact = fromCentsForProductId(cardmarketId, foil: foil);
      if (exact != null) return exact;
    }

    final byName = _productsByName;
    final guides = _guidesCache;
    if (byName == null || guides == null) return null;
    final products = byName[name.trim().toLowerCase()];
    if (products == null || products.isEmpty) return null;

    final match = _bestProductMatch(
      products,
      guides: guides,
      collectorNumber: collectorNumber,
      setName: setName,
      foil: foil,
      preferNearCents: preferNearCents,
      useLowForAnchor: true,
    );
    final guide = guides[match.idProduct];
    if (guide == null) return null;
    return guide.centsFor(foil: foil).low;
  }

  /// Cardmarket trend (EUR cents) for a printing.
  ///
  /// Prefer [cardmarketId] from Scryfall when available (exact Alpha vs Secret
  /// Lair, etc.). Otherwise fall back to name matching heuristics.
  int? trendCentsForPrinting({
    required String name,
    String? collectorNumber,
    String? setName,
    bool? foil,
    int? preferNearCents,
    int? cardmarketId,
  }) {
    if (cardmarketId != null) {
      final exact = trendCentsForProductId(cardmarketId, foil: foil);
      if (exact != null) return exact;
    }

    final byName = _productsByName;
    final guides = _guidesCache;
    if (byName == null || guides == null) return null;
    final products = byName[name.trim().toLowerCase()];
    if (products == null || products.isEmpty) return null;

    final match = _bestProductMatch(
      products,
      guides: guides,
      collectorNumber: collectorNumber,
      setName: setName,
      foil: foil,
      preferNearCents: preferNearCents,
    );
    final guide = guides[match.idProduct];
    if (guide == null) return null;
    return guide.centsFor(foil: foil).trend;
  }

  /// Legacy helper — name only (may pick the wrong expansion).
  int? trendCentsForName(String name, {bool? foil}) => trendCentsForPrinting(
        name: name,
        foil: foil,
      );

  CmProduct _bestProductMatch(
    List<CmProduct> products, {
    required Map<int, CmPriceGuide> guides,
    String? collectorNumber,
    String? setName,
    bool? foil,
    int? preferNearCents,
    bool useLowForAnchor = false,
  }) {
    final numKey = _normalizeCollectorNumber(collectorNumber);
    if (numKey != null) {
      for (final p in products) {
        if (_normalizeCollectorNumber(p.number) == numKey) return p;
      }
    }
    final setKey = setName?.trim().toLowerCase();
    if (setKey != null && setKey.isNotEmpty) {
      for (final p in products) {
        final hay = '${p.categoryName} ${p.name}'.toLowerCase();
        if (hay.contains(setKey)) return p;
      }
    }

    // Disambiguate reprints by picking the CM price closest to a live CT price.
    if (preferNearCents != null && products.length > 1) {
      CmProduct? best;
      var bestDist = 1 << 30;
      for (final p in products) {
        final cents = guides[p.idProduct]?.centsFor(foil: foil);
        final value = useLowForAnchor ? cents?.low : cents?.trend;
        if (value == null) continue;
        final dist = (value - preferNearCents).abs();
        if (dist < bestDist) {
          bestDist = dist;
          best = p;
        }
      }
      if (best != null) return best;
    }

    return products.first;
  }

  static String? _normalizeCollectorNumber(String? raw) {
    if (raw == null) return null;
    final t = raw.trim().toLowerCase();
    if (t.isEmpty) return null;
    // Strip leading zeros for numeric-only numbers ("012" → "12") but keep
    // alphanumeric codes like "12a" / "220★".
    if (RegExp(r'^\d+$').hasMatch(t)) {
      return int.parse(t).toString();
    }
    return t;
  }

  Future<int> _countProductsJson(File file) async {
    final map = await loadProducts(overridePath: file.path);
    return map.length;
  }

  Future<int> _countPriceGuidesJson(File file) async {
    final map = await loadPriceGuide(overridePath: file.path);
    return map.length;
  }

  Map<int, CmProduct> _parseProductsJson(String raw) {
    final decoded = jsonDecode(raw);
    final list = decoded is Map<String, dynamic>
        ? decoded['products'] as List<dynamic>? ?? []
        : decoded is List
            ? decoded
            : <dynamic>[];
    final out = <int, CmProduct>{};
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['idProduct'] as int?;
      if (id == null) continue;
      out[id] = CmProduct(
        idProduct: id,
        name: item['name'] as String? ?? '',
        expansionId: item['idExpansion'] as int? ?? 0,
        categoryName: item['categoryName'] as String? ?? '',
        number: (item['number'] ?? item['collectorNumber'] ?? item['collectorsNumber'])
            ?.toString(),
      );
    }
    return out;
  }

  Map<int, CmPriceGuide> _parsePriceGuideJson(String raw) {
    final decoded = jsonDecode(raw);
    final list = decoded is Map<String, dynamic>
        ? decoded['priceGuides'] as List<dynamic>? ?? []
        : decoded is List
            ? decoded
            : <dynamic>[];
    final out = <int, CmPriceGuide>{};
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      final id = item['idProduct'] as int?;
      if (id == null) continue;
      out[id] = CmPriceGuide(
        idProduct: id,
        avg: _asDouble(item['avg']),
        low: _asDouble(item['low']),
        trend: _asDouble(item['trend']),
        avg7: _asDouble(item['avg7']),
        avg30: _asDouble(item['avg30']),
        avgFoil: _asDouble(item['avg-foil'] ?? item['avgFoil'] ?? item['foilAvg']),
        lowFoil: _asDouble(item['low-foil'] ?? item['lowFoil'] ?? item['foilLow']),
        trendFoil:
            _asDouble(item['trend-foil'] ?? item['trendFoil'] ?? item['foilTrend']),
        avg7Foil:
            _asDouble(item['avg7-foil'] ?? item['avg7Foil'] ?? item['foilAvg7']),
        avg30Foil: _asDouble(
          item['avg30-foil'] ?? item['avg30Foil'] ?? item['foilAvg30'],
        ),
      );
    }
    return out;
  }

  Map<int, CmProduct> _parseProductsCsv(String raw) {
    final rows = csv.decode(raw);
    if (rows.isEmpty) return {};
    final header = rows.first.map((e) => e.toString()).toList();
    final idIdx = _col(header, ['idProduct', 'id_product']);
    final nameIdx = _col(header, ['Name', 'name']);
    final expIdx = _col(header, ['Expansion ID', 'idExpansion', 'Expansion']);
    final numIdx = _col(header, ['Number', 'number', 'Collectors Number']);
    final out = <int, CmProduct>{};
    for (final row in rows.skip(1)) {
      if (row.length <= idIdx) continue;
      final id = int.tryParse(row[idIdx].toString());
      if (id == null) continue;
      out[id] = CmProduct(
        idProduct: id,
        name: nameIdx >= 0 && nameIdx < row.length ? row[nameIdx].toString() : '',
        expansionId: expIdx >= 0 && expIdx < row.length
            ? int.tryParse(row[expIdx].toString()) ?? 0
            : 0,
        number: numIdx >= 0 && numIdx < row.length
            ? row[numIdx].toString()
            : null,
      );
    }
    return out;
  }

  Map<int, CmPriceGuide> _parsePriceGuideCsv(String raw) {
    final rows = csv.decode(raw);
    if (rows.isEmpty) return {};
    final header = rows.first.map((e) => e.toString()).toList();
    final idIdx = _col(header, ['idProduct', 'id_product']);
    final avgIdx = _col(header, ['Avg', 'avg']);
    final lowIdx = _col(header, ['Low', 'low']);
    final trendIdx = _col(header, ['Trend', 'trend']);
    final avg7Idx = _col(header, ['Avg7', 'avg7']);
    final avg30Idx = _col(header, ['Avg30', 'avg30']);
    final avgFoilIdx = _col(header, ['Foil Sell', 'avg-foil', 'FoilAvg', 'avgFoil']);
    final lowFoilIdx = _col(header, ['Foil Low', 'low-foil', 'FoilLow', 'lowFoil']);
    final trendFoilIdx =
        _col(header, ['Foil Trend', 'trend-foil', 'FoilTrend', 'trendFoil']);
    final avg7FoilIdx =
        _col(header, ['Foil AVG7', 'avg7-foil', 'FoilAvg7', 'avg7Foil']);
    final avg30FoilIdx =
        _col(header, ['Foil AVG30', 'avg30-foil', 'FoilAvg30', 'avg30Foil']);
    final out = <int, CmPriceGuide>{};
    for (final row in rows.skip(1)) {
      if (row.length <= idIdx) continue;
      final id = int.tryParse(row[idIdx].toString());
      if (id == null) continue;
      out[id] = CmPriceGuide(
        idProduct: id,
        avg: _cellDouble(row, avgIdx),
        low: _cellDouble(row, lowIdx),
        trend: _cellDouble(row, trendIdx),
        avg7: _cellDouble(row, avg7Idx),
        avg30: _cellDouble(row, avg30Idx),
        avgFoil: _cellDouble(row, avgFoilIdx),
        lowFoil: _cellDouble(row, lowFoilIdx),
        trendFoil: _cellDouble(row, trendFoilIdx),
        avg7Foil: _cellDouble(row, avg7FoilIdx),
        avg30Foil: _cellDouble(row, avg30FoilIdx),
      );
    }
    return out;
  }

  int _col(List<String> header, List<String> names) {
    for (final n in names) {
      final i = header.indexWhere((h) => h.toLowerCase() == n.toLowerCase());
      if (i >= 0) return i;
    }
    return -1;
  }

  double? _cellDouble(List<dynamic> row, int idx) {
    if (idx < 0 || idx >= row.length) return null;
    return _asDouble(row[idx]);
  }

  double? _asDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString().replaceAll(',', '.'));
  }
}

class CmProduct {
  CmProduct({
    required this.idProduct,
    required this.name,
    required this.expansionId,
    this.categoryName = '',
    this.number,
  });
  final int idProduct;
  final String name;
  final int expansionId;
  final String categoryName;
  /// Collector number within the expansion, when present in the catalogue.
  final String? number;
}

class CmPriceGuide {
  CmPriceGuide({
    required this.idProduct,
    this.avg,
    this.low,
    this.trend,
    this.avg7,
    this.avg30,
    this.avgFoil,
    this.lowFoil,
    this.trendFoil,
    this.avg7Foil,
    this.avg30Foil,
  });
  final int idProduct;
  final double? avg;
  final double? low;
  final double? trend;
  final double? avg7;
  final double? avg30;
  final double? avgFoil;
  final double? lowFoil;
  final double? trendFoil;
  final double? avg7Foil;
  final double? avg30Foil;

  int? get trendCents => _toCents(trend);
  int? get lowCents => _toCents(low);
  int? get avgCents => _toCents(avg);
  int? get avg7Cents => _toCents(avg7);
  int? get avg30Cents => _toCents(avg30);

  int? get trendFoilCents => _toCents(trendFoil);
  int? get lowFoilCents => _toCents(lowFoil);
  int? get avgFoilCents => _toCents(avgFoil);
  int? get avg7FoilCents => _toCents(avg7Foil);
  int? get avg30FoilCents => _toCents(avg30Foil);

  /// Pick foil or non-foil guide fields. When [foil] is null, use non-foil.
  ({int? trend, int? low, int? avg, int? avg7, int? avg30}) centsFor({
    bool? foil,
  }) {
    if (foil == true) {
      return (
        trend: trendFoilCents ?? trendCents,
        low: lowFoilCents ?? lowCents,
        avg: avgFoilCents ?? avgCents,
        avg7: avg7FoilCents ?? avg7Cents,
        avg30: avg30FoilCents ?? avg30Cents,
      );
    }
    return (
      trend: trendCents,
      low: lowCents,
      avg: avgCents,
      avg7: avg7Cents,
      avg30: avg30Cents,
    );
  }

  static int? _toCents(double? euros) {
    if (euros == null) return null;
    return (euros * 100).round();
  }
}

class CardmarketDownloadResult {
  CardmarketDownloadResult({
    required this.productsPath,
    required this.priceGuidePath,
    required this.productsCount,
    required this.pricesCount,
  });
  final String productsPath;
  final String priceGuidePath;
  final int productsCount;
  final int pricesCount;
}

class CardmarketCacheStatus {
  CardmarketCacheStatus({
    required this.productsExists,
    required this.priceGuideExists,
    this.productsModified,
    this.priceGuideModified,
  });
  final bool productsExists;
  final bool priceGuideExists;
  final DateTime? productsModified;
  final DateTime? priceGuideModified;

  bool get ready => productsExists && priceGuideExists;
}
