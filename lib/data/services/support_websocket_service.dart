import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// Chat uchun WebSocket real-time ulanish service
class SupportWebSocketService {
  WebSocketChannel? _channel;
  final String baseUrl;

  Function(Map<String, dynamic>)? onMessage;
  Function(bool)? onConnectionChange;

  SupportWebSocketService({required this.baseUrl});

  bool get isConnected => _channel != null;

  void connect(String token) {
    if (_channel != null) {
      debugPrint('WebSocket already connected');
      return;
    }

    try {
      final uri = Uri.parse('$baseUrl?token=$token');
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          debugPrint('WebSocket raw data received: $data');
          if (data is String) {
            try {
              final json = jsonDecode(data) as Map<String, dynamic>;
              _handleMessage(json);
            } catch (e) {
              debugPrint('JSON decode error: $e');
            }
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          onConnectionChange?.call(false);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _channel = null;
          onConnectionChange?.call(false);
        },
      );

      debugPrint('WebSocket connected to $baseUrl');
      onConnectionChange?.call(true);
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _channel = null;
      onConnectionChange?.call(false);
    }
  }

  void _handleMessage(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    debugPrint('WebSocket message received: type=$type, data=$json');

    if (type == 'error') {
      final data = json['data'] as Map<String, dynamic>?;
      final code = data?['code'] as String?;
      final message = data?['message'] as String?;
      debugPrint('WebSocket ERROR: code=$code, message=$message');
    }

    if (onMessage != null) {
      onMessage!(json);
    }
  }

  void sendMessage({
    required int receiverId,
    required String receiverType,
    required String content,
  }) {
    if (_channel == null) {
      debugPrint('WebSocket not connected');
      return;
    }

    final message = {
      'type': 'message',
      'data': {
        'content': content,
        'receiver_id': receiverId,
        'receiver_type': receiverType,
      },
    };

    final encodedMessage = jsonEncode(message);
    debugPrint('WebSocket raw data sent: $encodedMessage');
    _channel!.sink.add(encodedMessage);
    debugPrint('Message sent to $receiverId ($receiverType): $content');
  }

  void sendReadReceipt({
    required int partnerId,
    required String partnerType,
    required List<int> messageIds,
  }) {
    if (_channel == null) {
      debugPrint('WebSocket not connected');
      return;
    }

    final message = {
      'type': 'read',
      'data': {
        'partnerId': partnerId,
        'partnerType': partnerType,
        'messageIds': messageIds,
      },
    };

    _channel!.sink.add(jsonEncode(message));
    debugPrint('Read receipt sent for messages: $messageIds');
  }

  void sendTypingStatus({
    required int partnerId,
    required String partnerType,
    required bool isTyping,
  }) {
    if (_channel == null) {
      debugPrint('WebSocket not connected');
      return;
    }

    final message = {
      'type': 'typing',
      'data': {
        'partnerId': partnerId,
        'partnerType': partnerType,
        'isTyping': isTyping,
      },
    };

    _channel!.sink.add(jsonEncode(message));
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    debugPrint('WebSocket disconnected');
  }

  void dispose() {
    disconnect();
  }
}
