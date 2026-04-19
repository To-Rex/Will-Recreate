import 'package:dio/dio.dart';
import '../models/api_log_model.dart';
import '../services/api_log_service.dart';

/// Dio interceptor - barcha API so'rov va javoblarni log qilish
class ApiLogInterceptor extends Interceptor {
  final ApiLogService _logService = ApiLogService.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Request vaqtini saqlash
    options.extra['apiLogStartTime'] = DateTime.now();

    // Request body ni olish
    dynamic requestBody;
    if (options.data != null) {
      requestBody = options.data is FormData
          ? 'FormData (fields: ${(options.data as FormData).fields.length}, files: ${(options.data as FormData).files.length})'
          : options.data;
    }

    // Headerlarni tozalash (maxsus headerlarni yashirish)
    final headers = <String, dynamic>{};
    options.headers.forEach((key, value) {
      // Authorization header ni qisqartirib ko'rsatish
      if (key.toLowerCase() == 'authorization') {
        final str = value.toString();
        headers[key] = str.length > 20
            ? '${str.substring(0, 17)}...'
            : str;
      } else {
        headers[key] = value;
      }
    });

    final log = ApiLog(
      id: _generateId(options),
      method: options.method,
      url: options.uri.toString(),
      headers: headers,
      requestBody: requestBody,
      timestamp: DateTime.now(),
    );

    // Vaqtinchalik saqlash (response da ishlatish uchun)
    options.extra['apiLog'] = log;

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final startTime = response.requestOptions.extra['apiLogStartTime'] as DateTime?;
    final duration = startTime != null ? DateTime.now().difference(startTime) : null;

    final existingLog = response.requestOptions.extra['apiLog'] as ApiLog?;

    final log = ApiLog(
      id: existingLog?.id ?? _generateId(response.requestOptions),
      method: response.requestOptions.method,
      url: response.requestOptions.uri.toString(),
      statusCode: response.statusCode,
      headers: existingLog?.headers ?? _extractHeaders(response.requestOptions),
      requestBody: existingLog?.requestBody,
      responseBody: response.data,
      timestamp: existingLog?.timestamp ?? DateTime.now(),
      duration: duration,
    );

    _logService.addLog(log);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final startTime = err.requestOptions.extra['apiLogStartTime'] as DateTime?;
    final duration = startTime != null ? DateTime.now().difference(startTime) : null;

    final existingLog = err.requestOptions.extra['apiLog'] as ApiLog?;

    final log = ApiLog(
      id: existingLog?.id ?? _generateId(err.requestOptions),
      method: err.requestOptions.method,
      url: err.requestOptions.uri.toString(),
      statusCode: err.response?.statusCode,
      headers: existingLog?.headers ?? _extractHeaders(err.requestOptions),
      requestBody: existingLog?.requestBody,
      responseBody: err.response?.data,
      timestamp: existingLog?.timestamp ?? DateTime.now(),
      duration: duration,
      error: err.message,
    );

    _logService.addLog(log);
    handler.next(err);
  }

  /// Unikal ID generatsiya qilish
  String _generateId(RequestOptions options) {
    return '${options.method}_${options.uri}_${DateTime.now().microsecondsSinceEpoch}';
  }

  /// Headerlarni olish
  Map<String, dynamic> _extractHeaders(RequestOptions options) {
    final headers = <String, dynamic>{};
    options.headers.forEach((key, value) {
      if (key.toLowerCase() == 'authorization') {
        final str = value.toString();
        headers[key] = str.length > 20 ? '${str.substring(0, 17)}...' : str;
      } else {
        headers[key] = value;
      }
    });
    return headers;
  }
}
