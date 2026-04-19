import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import '../services/base_url_service.dart';
import 'api_log_interceptor.dart';
import 'auth_interceptor.dart';

/// Markaziy Dio instance - bitta nuqtadan boshqarish
class DioClient {
  static Dio? _dio;
  static String? _currentBaseUrl;
  static final _baseUrlService = BaseUrlService();
  static final _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 3,
      lineLength: 80,
      colors: false,
      printEmojis: false,
    ),
  );

  /// Singleton Dio instance
  static Dio get dio {
    // Agar Dio mavjud bo'lsa va baseUrl o'zgarmagan bo'lsa, qaytarish
    if (_dio != null && _currentBaseUrl != null) return _dio!;

    _currentBaseUrl = AppConfig.baseUrl;
    _dio = _createDio(AppConfig.baseUrl);

    // Saqlangan aktiv base URL'ni yuklash
    _loadActiveBaseUrl();

    return _dio!;
  }

  static Dio _createDio(String baseUrl) {
    return Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.addAll([
        AuthInterceptor(),
        ApiLogInterceptor(),
        _LoggingInterceptor(),
      ]);
  }

  /// Saqlangan base URL'ni yuklash va Dio'ni yangilash
  static Future<void> _loadActiveBaseUrl() async {
    final activeUrl = await _baseUrlService.getActiveBaseUrl();
    if (activeUrl != AppConfig.baseUrl) {
      updateBaseUrl(activeUrl);
    }
  }

  /// Base URL'ni dinamik o'zgartirish
  static void updateBaseUrl(String newBaseUrl) {
    if (_dio != null) {
      _dio!.options.baseUrl = newBaseUrl;
      _currentBaseUrl = newBaseUrl;
    }
  }

  /// Test uchun Dio'ni reset qilish
  static void reset() {
    _dio = null;
    _currentBaseUrl = null;
  }
}

/// Logging interceptor - debug uchun
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    DioClient._logger.d('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    DioClient._logger.d('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    DioClient._logger.e(
      '✗ ${err.response?.statusCode} ${err.requestOptions.uri}',
      error: err.message,
    );
    handler.next(err);
  }
}
