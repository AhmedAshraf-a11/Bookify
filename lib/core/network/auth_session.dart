import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthSession {
  String? get accessToken;
  Future<void> setAccessToken(String? token);
  Future<void> clear();
  Future<void> init();
}

class SecureAuthSession implements AuthSession {
  SecureAuthSession({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;
  String? _accessToken;

  static const _tokenKey = 'access_token';

  @override
  String? get accessToken => _accessToken;

  @override
  Future<void> init() async {
    _accessToken = await _storage.read(key: _tokenKey);
  }

  @override
  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    if (token == null) {
      await _storage.delete(key: _tokenKey);
    } else {
      await _storage.write(key: _tokenKey, value: token);
    }
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
    await _storage.delete(key: _tokenKey);
  }
}

class InMemoryAuthSession implements AuthSession {
  String? _accessToken;

  @override
  String? get accessToken => _accessToken;

  @override
  Future<void> init() async {
    // No initialization needed for in-memory session.
  }

  @override
  Future<void> clear() async {
    _accessToken = null;
  }

  @override
  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
  }
}
