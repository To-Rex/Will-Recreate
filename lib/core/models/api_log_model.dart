import 'dart:convert';

/// API so'rov va javob ma'lumotlarini saqlash uchun model
class ApiLog {
  final String id;
  final String method;
  final String url;
  final int? statusCode;
  final Map<String, dynamic> headers;
  final dynamic requestBody;
  final dynamic responseBody;
  final DateTime timestamp;
  final Duration? duration;
  final String? error;

  ApiLog({
    required this.id,
    required this.method,
    required this.url,
    this.statusCode,
    required this.headers,
    this.requestBody,
    this.responseBody,
    required this.timestamp,
    this.duration,
    this.error,
  });

  /// HTTP metodiga qarab rang
  String get methodColor {
    switch (method.toUpperCase()) {
      case 'GET':
        return '#2196F3'; // Blue
      case 'POST':
        return '#4CAF50'; // Green
      case 'PUT':
        return '#FF9800'; // Orange
      case 'PATCH':
        return '#FF9800'; // Orange
      case 'DELETE':
        return '#F44336'; // Red
      default:
        return '#9E9E9E'; // Grey
    }
  }

  /// Status kodiga qarab muvaffaqiyat holati
  bool get isSuccess => statusCode != null && statusCode! >= 200 && statusCode! < 300;

  /// Status kodiga qarab rang
  String get statusColor {
    if (statusCode == null) return '#9E9E9E';
    if (statusCode! >= 200 && statusCode! < 300) return '#4CAF50';
    if (statusCode! >= 300 && statusCode! < 400) return '#2196F3';
    if (statusCode! >= 400 && statusCode! < 500) return '#FF9800';
    return '#F44336';
  }

  /// Headerlarni chiroyli formatda
  String get formattedHeaders {
    final buffer = StringBuffer();
    headers.forEach((key, value) {
      buffer.writeln('$key: $value');
    });
    return buffer.toString().trimRight();
  }

  /// Request body ni chiroyli formatda
  String get formattedRequestBody {
    if (requestBody == null) return '';
    return _formatBody(requestBody);
  }

  /// Response body ni chiroyli formatda
  String get formattedResponseBody {
    if (responseBody == null) return '';
    return _formatBody(responseBody);
  }

  String _formatBody(dynamic body) {
    if (body is String) {
      try {
        final decoded = jsonDecode(body);
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(decoded);
      } catch (_) {
        return body;
      }
    } else if (body is Map || body is List) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(body);
    }
    return body.toString();
  }

  /// Davomiylikni chiroyli formatda
  String get formattedDuration {
    if (duration == null) return '';
    final ms = duration!.inMilliseconds;
    if (ms < 1000) return '${ms}ms';
    return '${(ms / 1000).toStringAsFixed(1)}s';
  }

  /// URL ni qisqartirilgan ko'rinishi (faqat path)
  String get shortUrl {
    try {
      final uri = Uri.parse(url);
      return uri.path + (uri.query.isNotEmpty ? '?${uri.query}' : '');
    } catch (_) {
      return url;
    }
  }
}
