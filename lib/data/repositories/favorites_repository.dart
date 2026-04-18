import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/property_model.dart';

/// Favorites repository - local storage bilan ishlash
class FavoritesRepository {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _key = 'favorite_properties';

  /// Sevimlilarni olish
  Future<List<Property>> getFavorites() async {
    try {
      final jsonString = await _storage.read(key: _key);
      if (jsonString == null) return [];

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((j) => Property.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Sevimliga qo'shish
  Future<void> saveFavorite(Property property) async {
    final favorites = await getFavorites();
    if (favorites.any((p) => p.guid == property.guid)) return;

    favorites.add(property);
    await _storage.write(
      key: _key,
      value: json.encode(favorites.map((p) => p.toJson()).toList()),
    );
  }

  /// Sevimlidan o'chirish
  Future<void> removeFavorite(String guid) async {
    final favorites = await getFavorites();
    favorites.removeWhere((p) => p.guid == guid);
    await _storage.write(
      key: _key,
      value: json.encode(favorites.map((p) => p.toJson()).toList()),
    );
  }

  /// Sevimlilarda ekanligini tekshirish
  Future<bool> isFavorite(String guid) async {
    final favorites = await getFavorites();
    return favorites.any((p) => p.guid == guid);
  }
}
