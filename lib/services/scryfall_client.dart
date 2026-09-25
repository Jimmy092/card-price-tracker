import 'package:dio/dio.dart';

/// Scryfall helpers for MTG name autocomplete and all printings of a card.
class ScryfallClient {
  ScryfallClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: 'https://api.scryfall.com',
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 30),
                headers: {
                  'Accept': 'application/json',
                  'User-Agent': 'card-price-tracker/1.0',
                },
              ),
            );

  final Dio _dio;

  Future<List<String>> autocomplete(String query) async {
    final q = query.trim();
    if (q.length < 2) return [];
    final res = await _dio.get<Map<String, dynamic>>(
      '/cards/autocomplete',
      queryParameters: {'q': q},
    );
    final data = res.data?['data'];
    if (data is! List) return [];
    return data.map((e) => e.toString()).toList();
  }

  /// Every printing of an exact English card name.
  Future<List<ScryfallPrinting>> printingsForExactName(String name) async {
    final all = <ScryfallPrinting>[];
    Response<Map<String, dynamic>> res = await _dio.get<Map<String, dynamic>>(
      '/cards/search',
      queryParameters: {'q': '!"$name" unique:prints'},
    );

    while (true) {
      final data = res.data;
      if (data == null) break;
      final cards = data['data'];
      if (cards is List) {
        for (final item in cards) {
          if (item is Map<String, dynamic>) {
            all.add(ScryfallPrinting.fromJson(item));
          }
        }
      }
      final next = data['next_page'] as String?;
      if (next == null || next.isEmpty) break;
      await Future<void>.delayed(const Duration(milliseconds: 80));
      res = await _dio.getUri<Map<String, dynamic>>(Uri.parse(next));
    }

    all.sort((a, b) {
      final bySet = a.setName.compareTo(b.setName);
      if (bySet != 0) return bySet;
      return a.collectorNumber.compareTo(b.collectorNumber);
    });
    return all;
  }
}

class ScryfallPrinting {
  ScryfallPrinting({
    required this.id,
    required this.name,
    required this.setCode,
    required this.setName,
    required this.collectorNumber,
    this.imageUrl,
    this.releasedAt,
    this.cardmarketId,
  });

  factory ScryfallPrinting.fromJson(Map<String, dynamic> json) {
    String? image;
    final uris = json['image_uris'];
    if (uris is Map<String, dynamic>) {
      image = uris['normal'] as String? ??
          uris['small'] as String? ??
          uris['large'] as String?;
    } else {
      final faces = json['card_faces'];
      if (faces is List && faces.isNotEmpty) {
        final face = faces.first;
        if (face is Map<String, dynamic>) {
          final faceUris = face['image_uris'];
          if (faceUris is Map<String, dynamic>) {
            image = faceUris['normal'] as String? ?? faceUris['small'] as String?;
          }
        }
      }
    }

    return ScryfallPrinting(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      setCode: (json['set'] as String? ?? '').toLowerCase(),
      setName: json['set_name'] as String? ?? '',
      collectorNumber: json['collector_number'] as String? ?? '',
      imageUrl: image,
      releasedAt: json['released_at'] as String?,
      cardmarketId: json['cardmarket_id'] as int?,
    );
  }

  final String id;
  final String name;
  final String setCode;
  final String setName;
  final String collectorNumber;
  final String? imageUrl;
  final String? releasedAt;
  /// Exact Cardmarket product id for this printing (when Scryfall has it).
  final int? cardmarketId;
}
