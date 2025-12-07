import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class GlobalStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyAccessToken = 'ACCESS_TOKEN';
  static const _keyRefreshToken = 'REFRESH_TOKEN';
  static const _keyLastWorkspaceId = 'LAST_WORKSPACE_ID';

  // Tokens
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: _keyAccessToken, value: accessToken);
    await _storage.write(key: _keyRefreshToken, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  static Future<void> deleteTokens() async {
    await _storage.delete(key: _keyAccessToken);
    await _storage.delete(key: _keyRefreshToken);
  }

  // Workspace
  static Future<void> saveLastWorkspaceId(String id) async {
    await _storage.write(key: _keyLastWorkspaceId, value: id);
  }

  static Future<String?> getLastWorkspaceId() async {
    return await _storage.read(key: _keyLastWorkspaceId);
  }

  static Future<void> deleteLastWorkspaceId() async {
    await _storage.delete(key: _keyLastWorkspaceId);
  }
}
