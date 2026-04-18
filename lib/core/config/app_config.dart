/// API va ilova konfiguratsiyasi
class AppConfig {
  static const String baseUrl = 'https://dev.weel.uz/api';
  static const String wsUrl = 'wss://dev.weel.uz/api/ws/chat/';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
