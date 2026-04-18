import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../models/property_model.dart';

/// Auth API endpointlari bilan ishlash
class AuthApiService {
  final Dio _dio = DioClient.dio;

  /// Ro'yxatdan o'tish - OTP yuborish
  Future<OtpRequestResponse> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    final res = await _dio.post(
      '/user/client/register/',
      data: {
        'phone_number': phoneNumber,
        'first_name': firstName,
        'last_name': lastName,
      },
    );
    return OtpRequestResponse.fromJson(res.data);
  }

  /// Login - OTP yuborish
  Future<OtpRequestResponse> login({required String phoneNumber}) async {
    final res = await _dio.post(
      '/user/client/login/',
      data: {'phone_number': phoneNumber},
    );
    return OtpRequestResponse.fromJson(res.data);
  }

  /// Ro'yxatdan o'tish - OTP tasdiqlash
  Future<VerifyResponse> verifyRegistration({
    required String phoneNumber,
    required String otpCode,
    String? fcmToken,
  }) async {
    final res = await _dio.post(
      '/user/client/register/verify/',
      data: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
        if (fcmToken != null) 'fcm_token': fcmToken,
        'device_type': 'android',
      },
    );
    return VerifyResponse.fromJson(res.data);
  }

  /// Login - OTP tasdiqlash
  Future<VerifyResponse> verifyLogin({
    required String phoneNumber,
    required String otpCode,
    String? fcmToken,
  }) async {
    final res = await _dio.post(
      '/user/client/login/verify/',
      data: {
        'phone_number': phoneNumber,
        'otp_code': otpCode,
        if (fcmToken != null) 'fcm_token': fcmToken,
        'device_type': 'android',
      },
    );
    return VerifyResponse.fromJson(res.data);
  }

  /// OTP qayta yuborish (register)
  Future<void> resendRegisterOtp({required String phoneNumber}) async {
    await _dio.post(
      '/user/client/register/resend/',
      data: {'phone_number': phoneNumber},
    );
  }

  /// OTP qayta yuborish (login)
  Future<void> resendLoginOtp({required String phoneNumber}) async {
    await _dio.post(
      '/user/client/login/resend/',
      data: {'phone_number': phoneNumber},
    );
  }

  /// Logout
  Future<void> logout({required String refreshToken}) async {
    await _dio.post(
      '/user/client/logout/',
      data: {'refresh': refreshToken},
    );
  }

  /// Profil ma'lumotlarini olish
  Future<Map<String, dynamic>> getProfile() async {
    final res = await _dio.get('/user/client/profile/');
    return res.data;
  }

  /// Profilni yangilash
  Future<void> updateProfile({String? firstName, String? lastName}) async {
    await _dio.patch(
      '/user/client/profile/',
      data: {
        if (firstName != null) 'first_name': firstName,
        if (lastName != null) 'last_name': lastName,
      },
    );
  }

  /// Hisobni o'chirish
  Future<void> deleteAccount({required String refreshToken}) async {
    await _dio.delete(
      '/user/account/',
      data: {'refresh': refreshToken},
    );
  }
}
