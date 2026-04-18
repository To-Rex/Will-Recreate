import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../models/property_model.dart';
import '../services/payment_api_service.dart';

/// Payment repository
class PaymentRepository {
  final PaymentApiService _apiService = PaymentApiService();

  /// Kartalar ro'yxati
  Future<ApiResult<List<CardModel>>> getCards() async {
    try {
      final result = await _apiService.getCards();
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Karta qo'shish
  Future<ApiResult<AddCardResponse>> addCard({
    required String cardNumber,
    required String expireDate,
  }) async {
    try {
      final result = await _apiService.addCard(
        cardNumber: cardNumber,
        expireDate: expireDate,
      );
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Kartani tasdiqlash
  Future<ApiResult<void>> verifyCard({
    required String session,
    required String otp,
  }) async {
    try {
      await _apiService.verifyCard(session: session, otp: otp);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// OTP qayta yuborish
  Future<ApiResult<void>> resendOtp(String session) async {
    try {
      await _apiService.resendOtp(session);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Kartani o'chirish
  Future<ApiResult<void>> deleteCard(int id) async {
    try {
      await _apiService.deleteCard(id);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
}
