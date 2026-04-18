import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Token va user ma'lumotlarini xavfsiz saqlash
class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _keyAccessToken = 'access_token';
  static const _keyRefreshToken = 'refresh_token';
  static const _keyUserGuid = 'user_guid';
  static const _keyPhoneNumber = 'phone_number';
  static const _keyFirstName = 'first_name';
  static const _keyLastName = 'last_name';

  // --- Tokens ---

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _keyAccessToken, value: accessToken),
      _storage.write(key: _keyRefreshToken, value: refreshToken),
    ]);
  }

  Future<Map<String, String?>> getTokens() async {
    return {
      'access_token': await _storage.read(key: _keyAccessToken),
      'refresh_token': await _storage.read(key: _keyRefreshToken),
    };
  }

  // --- User data ---

  Future<void> saveUserData({
    required String guid,
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    await Future.wait([
      _storage.write(key: _keyUserGuid, value: guid),
      _storage.write(key: _keyPhoneNumber, value: phoneNumber),
      _storage.write(key: _keyFirstName, value: firstName),
      _storage.write(key: _keyLastName, value: lastName),
    ]);
  }

  Future<Map<String, String?>> getUserData() async {
    return {
      'guid': await _storage.read(key: _keyUserGuid),
      'phone_number': await _storage.read(key: _keyPhoneNumber),
      'first_name': await _storage.read(key: _keyFirstName),
      'last_name': await _storage.read(key: _keyLastName),
    };
  }

  // --- Auth state ---

  Future<bool> isLoggedIn() async {
    final tokens = await getTokens();
    return tokens['access_token'] != null && tokens['access_token']!.isNotEmpty;
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
