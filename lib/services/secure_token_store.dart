import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStore {
  SecureTokenStore({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const _ctTokenKey = 'cardtrader_bearer_token';

  final FlutterSecureStorage _storage;

  Future<String?> readCardTraderToken() => _storage.read(key: _ctTokenKey);

  Future<void> writeCardTraderToken(String token) =>
      _storage.write(key: _ctTokenKey, value: token.trim());

  Future<void> clearCardTraderToken() => _storage.delete(key: _ctTokenKey);

  Future<bool> hasCardTraderToken() async {
    final t = await readCardTraderToken();
    return t != null && t.isNotEmpty;
  }
}
