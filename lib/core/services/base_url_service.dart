import 'dart:convert';
import '../config/app_config.dart';
import '../storage/secure_storage_service.dart';

/// Base URL modeli
class BaseUrlItem {
  final String id;
  final String name;
  final String url;

  const BaseUrlItem({
    required this.id,
    required this.name,
    required this.url,
  });

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'url': url};

  factory BaseUrlItem.fromJson(Map<String, dynamic> json) => BaseUrlItem(
        id: json['id'] as String,
        name: json['name'] as String,
        url: json['url'] as String,
      );

  BaseUrlItem copyWith({String? name, String? url}) => BaseUrlItem(
        id: id,
        name: name ?? this.name,
        url: url ?? this.url,
      );
}

/// Base URL'larni boshqarish xizmati
class BaseUrlService {
  static const _keyCustomUrls = 'custom_base_urls';
  static const _keyActiveUrlId = 'active_base_url_id';

  /// Asosiy (default) base URL - o'chirib bo'lmaydi, tahrirlab bo'lmaydi
  static const String defaultId = 'default';
  static const BaseUrlItem defaultUrl = BaseUrlItem(
    id: defaultId,
    name: 'Production',
    url: AppConfig.baseUrl,
  );

  final SecureStorageService _storage = SecureStorageService();

  /// Hozirgi aktiv base URL'ni olish
  Future<String> getActiveBaseUrl() async {
    final activeId = await _storage.read(_keyActiveUrlId);
    if (activeId == null || activeId == defaultId) {
      return AppConfig.baseUrl;
    }
    final urls = await getCustomUrls();
    final active = urls.where((u) => u.id == activeId).firstOrNull;
    return active?.url ?? AppConfig.baseUrl;
  }

  /// Hozirgi aktiv WS URL'ni olish
  Future<String> getActiveWsUrl() async {
    final baseUrl = await getActiveBaseUrl();
    return _httpToWs(baseUrl);
  }

  /// Aktiv base URL ID'sini olish
  Future<String> getActiveId() async {
    return (await _storage.read(_keyActiveUrlId)) ?? defaultId;
  }

  /// Aktiv base URL'ni o'rnatish
  Future<void> setActiveId(String id) async {
    await _storage.write(_keyActiveUrlId, id);
  }

  /// Qo'shimcha base URL'lar ro'yxati
  Future<List<BaseUrlItem>> getCustomUrls() async {
    final raw = await _storage.read(_keyCustomUrls);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => BaseUrlItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Qo'shimcha base URL qo'shish
  Future<BaseUrlItem> addCustomUrl({required String name, required String url}) async {
    final urls = await getCustomUrls();
    final item = BaseUrlItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      url: url,
    );
    urls.add(item);
    await _saveCustomUrls(urls);
    return item;
  }

  /// Qo'shimcha base URL'ni tahrirlash
  Future<void> updateCustomUrl(String id, {String? name, String? url}) async {
    final urls = await getCustomUrls();
    final index = urls.indexWhere((u) => u.id == id);
    if (index == -1) return;
    urls[index] = urls[index].copyWith(name: name, url: url);
    await _saveCustomUrls(urls);
  }

  /// Qo'shimcha base URL'ni o'chirish
  Future<void> deleteCustomUrl(String id) async {
    var urls = await getCustomUrls();
    urls = urls.where((u) => u.id != id).toList();
    await _saveCustomUrls(urls);
    // Agar aktiv URL o'chirilsa, default'ga qaytarish
    final activeId = await _storage.read(_keyActiveUrlId);
    if (activeId == id) {
      await setActiveId(defaultId);
    }
  }

  /// Barcha URL'lar ro'yxati (default + custom)
  Future<List<BaseUrlItem>> getAllUrls() async {
    final custom = await getCustomUrls();
    return [defaultUrl, ...custom];
  }

  // ==================== PRIVATE ====================

  Future<void> _saveCustomUrls(List<BaseUrlItem> urls) async {
    final json = jsonEncode(urls.map((e) => e.toJson()).toList());
    await _storage.write(_keyCustomUrls, json);
  }

  /// HTTP URL'ni WS URL'ga aylantirish
  /// https://dev.weel.uz/api -> wss://dev.weel.uz/api/ws/chat/
  /// http://localhost:8000/api -> ws://localhost:8000/api/ws/chat/
  static String _httpToWs(String httpUrl) {
    var wsUrl = httpUrl;
    if (wsUrl.startsWith('https://')) {
      wsUrl = wsUrl.replaceFirst('https://', 'wss://');
    } else if (wsUrl.startsWith('http://')) {
      wsUrl = wsUrl.replaceFirst('http://', 'ws://');
    }
    // /api bilan tugasa, /ws/chat/ qo'shamiz
    if (wsUrl.endsWith('/api')) {
      wsUrl = '$wsUrl/ws/chat/';
    } else if (!wsUrl.endsWith('/')) {
      wsUrl = '$wsUrl/ws/chat/';
    } else {
      wsUrl = '${wsUrl}ws/chat/';
    }
    return wsUrl;
  }
}
