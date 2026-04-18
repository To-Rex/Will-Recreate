import 'package:dio/dio.dart';

/// API natijalarini wrapper qilish uchun sealed class
/// Either o'rniga sodda va GetX bilan ishlaydigan yechim
sealed class ApiResult<T> {
  const ApiResult();

  /// Pattern matching - success/failure holatlarini qayta ishlash
  R when<R>({
    required R Function(T data) success,
    required R Function(String message) failure,
  }) {
    if (this is ApiSuccess<T>) {
      return success((this as ApiSuccess<T>).data);
    } else {
      return failure((this as ApiFailure<T>).message);
    }
  }
}

class ApiSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiSuccess(this.data);
}

class ApiFailure<T> extends ApiResult<T> {
  final String message;
  final int? statusCode;
  const ApiFailure(this.message, {this.statusCode});
}

/// DioException'dan foydalanuvchiga tushunarli xabar olish
String mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return 'Server bilan aloqa vaqti tugadi. Qaytadan urinib ko\'ring.';
    case DioExceptionType.connectionError:
      return 'Internet aloqasi yo\'q. Tarmoqni tekshiring.';
    case DioExceptionType.cancel:
      if (e.error == 'session_expired') return 'Sessiya tugadi. Qayta kiring.';
      return 'So\'rov bekor qilindi.';
    case DioExceptionType.badResponse:
      return _extractErrorMessage(e.response);
    case DioExceptionType.badCertificate:
      return 'Server sertifikati xatosi.';
    case DioExceptionType.unknown:
      return 'Kutilmagan xato yuz berdi.';
  }
}

String _extractErrorMessage(Response? response) {
  if (response?.data is Map) {
    final data = response!.data as Map;
    if (data['message'] != null) return data['message'].toString();
    if (data['detail'] != null) return data['detail'].toString();
    if (data['error'] != null) return data['error'].toString();
    if (data['non_field_errors'] is List) {
      return (data['non_field_errors'] as List).join(', ');
    }
  }
  return 'Server xatosi (${response?.statusCode ?? ''})';
}
