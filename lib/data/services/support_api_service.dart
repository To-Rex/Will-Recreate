import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/safe_parse.dart';
import '../models/property_model.dart';

/// Support/Chat API endpointlari bilan ishlash
class SupportApiService {
  final Dio _dio = DioClient.dio;

  /// Conversations ro'yxati
  Future<List<Map<String, dynamic>>> getConversations() async {
    final res = await _dio.get('/chat/conversations/');
    if (res.data is List) {
      return (res.data as List).whereType<Map<String, dynamic>>().toList();
    }
    return [];
  }

  /// Recipient ma'lumotlarini olish
  Future<Map<String, dynamic>?> getRecipient(String role) async {
    final res = await _dio.get('/chat/recipient/$role/');
    return safeMap(res.data);
  }

  /// Xabarlar ro'yxati
  Future<List<ChatMessage>> getMessages(int recipientId) async {
    final res = await _dio.get('/chat/messages/$recipientId/');
    if (res.data is List) {
      return (res.data as List)
          .whereType<Map<String, dynamic>>()
          .map((json) => ChatMessage.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Xabar yuborish
  Future<ChatMessage> sendMessage({
    required int receiverId,
    required String content,
    String receiverType = 'admin',
  }) async {
    final res = await _dio.post(
      '/chat/messages/',
      data: {
        'receiver_id': receiverId,
        'receiver_type': receiverType,
        'content': content,
      },
    );
    return ChatMessage.fromJson(res.data);
  }

  /// Xabarlarni o'qilgan deb belgilash
  Future<void> markAsRead(int messageId) async {
    await _dio.post('/chat/messages/$messageId/read/');
  }
}
