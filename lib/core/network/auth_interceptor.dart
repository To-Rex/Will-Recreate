import 'dart:async';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../storage/secure_storage_service.dart';
import '../controllers/app_controller.dart';

/// Har bir so'rovga token qo'shish va 401 da refresh qilish
class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage = SecureStorageService();

  bool _isRefreshing = false;
  Completer<Map<String, String>?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final tokens = await _storage.getTokens();
    final token = tokens['access_token'];

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    // Til headeri
    final locale = Get.locale?.languageCode ?? 'uz';
    options.headers['Accept-Language'] = locale;

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Public endpointlar uchun refresh urinmasin
    const publicPaths = ['/user/client/register/', '/user/client/login/', '/user/client/verify/'];
    final isPublic = publicPaths.any(
      (p) => err.requestOptions.path.contains(p),
    );
    if (isPublic) return handler.next(err);

    // Token refresh
    Map<String, String>? newTokens;

    if (_isRefreshing) {
      newTokens = await _refreshCompleter?.future;
    } else {
      _isRefreshing = true;
      _refreshCompleter = Completer<Map<String, String>?>();

      try {
        final tokens = await _storage.getTokens();
        final refreshToken = tokens['refresh_token'];

        if (refreshToken != null && refreshToken.isNotEmpty) {
          newTokens = await _performTokenRefresh(
            err.requestOptions.baseUrl,
            refreshToken,
          );

          if (newTokens != null) {
            await _storage.saveTokens(
              accessToken: newTokens['access']!,
              refreshToken: newTokens['refresh']!,
            );
          }
        }
        _refreshCompleter?.complete(newTokens);
      } catch (e) {
        _refreshCompleter?.completeError(e);
      } finally {
        _isRefreshing = false;
        _refreshCompleter = null;
      }
    }

    if (newTokens != null) {
      // Asl so'rovni yangi token bilan qayta jo'natish
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer ${newTokens['access']}';

      try {
        final retryDio = Dio(BaseOptions(baseUrl: options.baseUrl));
        final response = await retryDio.fetch(options);
        return handler.resolve(response);
      } catch (_) {
        return handler.next(err);
      }
    } else {
      // Refresh muvaffaqiyatsiz - logout
      await _storage.clearAll();
      final appController = Get.find<AppController>();
      appController.logout();

      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'session_expired',
          type: DioExceptionType.cancel,
        ),
      );
    }
  }

  Future<Map<String, String>?> _performTokenRefresh(
    String baseUrl,
    String refreshToken,
  ) async {
    final dio = Dio(BaseOptions(baseUrl: baseUrl));

    try {
      final response = await dio.post(
        '/user/refresh/',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'access': response.data['access'] as String,
          'refresh': response.data['refresh'] as String,
        };
      }
    } catch (_) {}
    return null;
  }
}
