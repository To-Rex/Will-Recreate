import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

/// Markaziy Dio instance - bitta nuqtadan boshqarish
class DioClient {
  static Dio? _dio;
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
    if (_dio != null) return _dio!;

    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Interceptorlar
    _dio!.interceptors.addAll([
      AuthInterceptor(),
      _LoggingInterceptor(),
    ]);

    return _dio!;
  }

  /// Test uchun Dio'ni reset qilish
  static void reset() {
    _dio = null;
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
