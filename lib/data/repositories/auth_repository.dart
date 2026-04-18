import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../../core/storage/secure_storage_service.dart';
import '../models/property_model.dart';
import '../services/auth_api_service.dart';

/// Auth repository - API service ni wrap qilib ApiResult qaytaradi
class AuthRepository {
  final AuthApiService _apiService = AuthApiService();
  final SecureStorageService _storage = SecureStorageService();

  /// Ro'yxatdan o'tish - OTP yuborish
  Future<ApiResult<OtpRequestResponse>> register({
    required String phoneNumber,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final result = await _apiService.register(
        phoneNumber: phoneNumber,
        firstName: firstName,
        lastName: lastName,
      );
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Login - OTP yuborish
  Future<ApiResult<OtpRequestResponse>> login({required String phoneNumber}) async {
    try {
      final result = await _apiService.login(phoneNumber: phoneNumber);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// OTP tasdiqlash (register yoki login)
  Future<ApiResult<VerifyResponse>> verifyOtp({
    required String phoneNumber,
    required String otpCode,
    required bool isLogin,
    String? fcmToken,
  }) async {
    try {
      final result = isLogin
          ? await _apiService.verifyLogin(
              phoneNumber: phoneNumber,
              otpCode: otpCode,
              fcmToken: fcmToken,
            )
          : await _apiService.verifyRegistration(
              phoneNumber: phoneNumber,
              otpCode: otpCode,
              fcmToken: fcmToken,
            );

      // Token va user ma'lumotlarini saqlash
      await _storage.saveTokens(
        accessToken: result.accessToken,
        refreshToken: result.refreshToken,
      );
      await _storage.saveUserData(
        guid: result.client.guid,
        phoneNumber: result.client.phoneNumber,
        firstName: result.client.firstName,
        lastName: result.client.lastName,
      );

      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// OTP qayta yuborish
  Future<ApiResult<void>> resendOtp({
    required String phoneNumber,
    required bool isLogin,
  }) async {
    try {
      if (isLogin) {
        await _apiService.resendLoginOtp(phoneNumber: phoneNumber);
      } else {
        await _apiService.resendRegisterOtp(phoneNumber: phoneNumber);
      }
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Logout
  Future<ApiResult<void>> logout() async {
    try {
      final tokens = await _storage.getTokens();
      final refreshToken = tokens['refresh_token'];
      if (refreshToken != null) {
        await _apiService.logout(refreshToken: refreshToken);
      }
      await _storage.clearAll();
      return const ApiSuccess(null);
    } on DioException catch (_) {
      // Logout API xato bersa ham local ma'lumotlarni o'chiramiz
      await _storage.clearAll();
      return const ApiSuccess(null);
    } catch (_) {
      await _storage.clearAll();
      return const ApiSuccess(null);
    }
  }

  /// Profil olish
  Future<ApiResult<Map<String, dynamic>>> getProfile() async {
    try {
      final result = await _apiService.getProfile();
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Saqlangan user ma'lumotlarini yuklash
  Future<ApiResult<ClientInfo?>> loadUserFromStorage() async {
    try {
      final isLoggedIn = await _storage.isLoggedIn();
      if (!isLoggedIn) return const ApiSuccess(null);

      final tokens = await _storage.getTokens();
      final userData = await _storage.getUserData();

      if (tokens['access_token'] != null && userData['guid'] != null) {
        return ApiSuccess(ClientInfo(
          guid: userData['guid']!,
          phoneNumber: userData['phone_number'] ?? '',
          firstName: userData['first_name'] ?? '',
          lastName: userData['last_name'] ?? '',
        ));
      }
      return const ApiSuccess(null);
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Hisobni o'chirish
  Future<ApiResult<void>> deleteAccount() async {
    try {
      final tokens = await _storage.getTokens();
      final refreshToken = tokens['refresh_token'];
      if (refreshToken != null) {
        await _apiService.deleteAccount(refreshToken: refreshToken);
      }
      await _storage.clearAll();
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
}
