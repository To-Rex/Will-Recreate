import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/safe_parse.dart';
import '../models/property_model.dart';

/// Payment API endpointlari bilan ishlash
class PaymentApiService {
  final Dio _dio = DioClient.dio;

  /// Kartalar ro'yxati
  Future<List<CardModel>> getCards() async {
    final res = await _dio.get('/user/client/cards/');
    final result = res.data['result'];
    if (result != null && result['cards'] is List) {
      return (result['cards'] as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => CardModel.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Karta qo'shish
  Future<AddCardResponse> addCard({
    required String cardNumber,
    required String expireDate,
  }) async {
    final sanitized = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    final sanitizedExp = expireDate.replaceAll(RegExp(r'[^0-9]'), '');

    // Format: YYMM
    final mm = sanitizedExp.substring(0, 2);
    final yy = sanitizedExp.substring(2, 4);
    final formattedExpire = '$yy$mm';

    final res = await _dio.post(
      '/user/client/cards/',
      data: {'card_number': sanitized, 'expire_date': formattedExpire},
    );

    final result = res.data['result'] ?? res.data;
    return AddCardResponse.fromJson(safeMap(result));
  }

  /// Kartani tasdiqlash (OTP)
  Future<void> verifyCard({required String session, required String otp}) async {
    final sessionValue = int.tryParse(session) ?? session;
    await _dio.post(
      '/user/client/cards/verify/',
      data: {'session': sessionValue, 'otp': otp},
    );
  }

  /// OTP qayta yuborish
  Future<void> resendOtp(String session) async {
    final sessionValue = int.tryParse(session) ?? session;
    await _dio.post(
      '/user/client/cards/resend/',
      data: {'session': sessionValue},
    );
  }

  /// Kartani o'chirish
  Future<void> deleteCard(int id) async {
    await _dio.delete('/user/client/cards/$id/');
  }
}
