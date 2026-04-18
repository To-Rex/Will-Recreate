import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../models/property_model.dart';
import '../services/support_api_service.dart';

/// Support/Chat repository
class SupportRepository {
  final SupportApiService _apiService = SupportApiService();

  /// Conversations ro'yxati
  Future<ApiResult<List<Map<String, dynamic>>>> getConversations() async {
    try {
      final result = await _apiService.getConversations();
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Recipient olish
  Future<ApiResult<Map<String, dynamic>?>> getRecipient(String role) async {
    try {
      final result = await _apiService.getRecipient(role);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Xabarlar
  Future<ApiResult<List<ChatMessage>>> getMessages(int recipientId) async {
    try {
      final result = await _apiService.getMessages(recipientId);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Xabar yuborish
  Future<ApiResult<ChatMessage>> sendMessage({
    required int receiverId,
    required String content,
    String receiverType = 'admin',
  }) async {
    try {
      final result = await _apiService.sendMessage(
        receiverId: receiverId,
        content: content,
        receiverType: receiverType,
      );
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Xabarlarni o'qilgan deb belgilash
  Future<ApiResult<void>> markAsRead(int messageId) async {
    try {
      await _apiService.markAsRead(messageId);
      return const ApiSuccess(null);
    } on DioException catch (_) {
      return const ApiSuccess(null); // Silent fail
    }
  }
}
