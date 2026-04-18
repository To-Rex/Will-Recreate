import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/config/app_config.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/support_repository.dart';
import '../../data/services/support_websocket_service.dart';

// Message status enum matching reference project
enum MessageStatus { sending, sent, read, failed }

// Message model matching reference project structure
class SupportMessage {
  final String id;
  final String content;
  final bool isFromMe;
  final DateTime createdAt;
  final MessageStatus status;

  SupportMessage({
    required this.id,
    required this.content,
    required this.isFromMe,
    required this.createdAt,
    this.status = MessageStatus.sent,
  });
}

class SupportController extends GetxController {
  final messages = <SupportMessage>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final focusNode = FocusNode();
  final isLoading = true.obs;
  final isPartnerTyping = false.obs;
  final isConnected = false.obs;
  final _supportRepository = SupportRepository();
  final _storage = SecureStorageService();
  int? _recipientId;
  String? _recipientRole;
  SupportWebSocketService? _webSocketService;
  String? _currentToken;
  Timer? _typingTimer;
  Timer? _typingStopTimer;

  @override
  void onInit() {
    super.onInit();
    _initChat();
  }

  Future<void> _initChat() async {
    // Recipient (admin) ni olish
    final recipientResult = await _supportRepository.getRecipient('admin');
    int? adminId;
    String? adminRole;
    recipientResult.when(
      success: (data) {
        if (data != null && data.containsKey('id')) {
          adminId = data['id'] as int;
          adminRole = data['role'] as String? ?? 'admin';
        }
      },
      failure: (_) {},
    );

    // Agar recipient topilsa, xabarlarni yuklash
    if (adminId != null) {
      _recipientId = adminId;
      _recipientRole = adminRole;
      final messagesResult = await _supportRepository.getMessages(adminId!);
      messagesResult.when(
        success: (chatMessages) {
          for (final m in chatMessages) {
            messages.add(SupportMessage(
              id: m.id,
              content: m.text,
              isFromMe: m.isMe,
              createdAt: m.time,
              status: MessageStatus.sent,
            ));
          }
        },
        failure: (_) {},
      );
    }
    isLoading.value = false;
    _scrollToBottom();

    // WebSocket ulanish
    await _connectWebSocket();
  }

  Future<void> _connectWebSocket() async {
    final tokens = await _storage.getTokens();
    final token = tokens['access_token'];
    if (token == null || token.isEmpty) return;

    if (_currentToken == token && _webSocketService?.isConnected == true) {
      return;
    }

    _currentToken = token;
    _webSocketService?.disconnect();

    _webSocketService = SupportWebSocketService(
      baseUrl: AppConfig.wsUrl,
    );

    _webSocketService!.onConnectionChange = (connected) {
      isConnected.value = connected;
      if (connected) {
        _resendPendingMessages();
      }
    };

    _webSocketService!.onMessage = (json) {
      _handleWebSocketMessage(json);
    };

    _webSocketService!.connect(token);
  }

  void _handleWebSocketMessage(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final data = json['data'] as Map<String, dynamic>?;

    switch (type) {
      case 'message':
        if (data != null) {
          final msgId = (data['id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
          final content = data['content'] as String? ?? '';
          final senderType = data['sender_type'] as String? ?? '';
          final isFromMe = senderType == 'client';
          final createdAt = data['created_at'] != null
              ? DateTime.tryParse(data['created_at'].toString()) ?? DateTime.now()
              : DateTime.now();

          if (isFromMe) {
            // Jo'natilgan xabar tasdiqlandi
            _confirmPendingMessage(msgId, content);
          } else {
            // Yangi xabar keldi
            messages.add(SupportMessage(
              id: msgId,
              content: content,
              isFromMe: false,
              createdAt: createdAt,
              status: MessageStatus.sent,
            ));
            _scrollToBottom(animate: true);
            // Avtomatik read receipt yuborish
            _sendReadReceipt(int.tryParse(msgId) ?? 0);
          }
        }
        break;
      case 'read':
        // Xabarlar o'qilgan deb belgilandi
        if (data != null) {
          _markMessagesAsRead();
        }
        break;
      case 'typing':
        if (data != null) {
          final isTyping = data['isTyping'] as bool? ?? false;
          isPartnerTyping.value = isTyping;
        }
        break;
      case 'error':
        debugPrint('WebSocket error: $data');
        break;
    }
  }

  void _confirmPendingMessage(String confirmedId, String content) {
    final index = messages.indexWhere(
      (m) => m.status == MessageStatus.sending && m.isFromMe && m.content == content,
    );
    if (index != -1) {
      messages[index] = SupportMessage(
        id: confirmedId,
        content: content,
        isFromMe: true,
        createdAt: messages[index].createdAt,
        status: MessageStatus.sent,
      );
    }
  }

  void _markMessagesAsRead() {
    for (int i = 0; i < messages.length; i++) {
      if (messages[i].isFromMe && messages[i].status != MessageStatus.read) {
        messages[i] = SupportMessage(
          id: messages[i].id,
          content: messages[i].content,
          isFromMe: true,
          createdAt: messages[i].createdAt,
          status: MessageStatus.read,
        );
      }
    }
  }

  void _sendReadReceipt(int messageId) {
    if (_recipientId == null || _recipientRole == null) return;
    _webSocketService?.sendReadReceipt(
      partnerId: _recipientId!,
      partnerType: _recipientRole!,
      messageIds: [messageId],
    );
  }

  void _resendPendingMessages() {
    final pending = messages.where(
      (m) => (m.status == MessageStatus.sending || m.status == MessageStatus.failed) && m.isFromMe,
    );
    for (final message in pending) {
      if (_recipientId != null && _recipientRole != null) {
        _webSocketService?.sendMessage(
          receiverId: _recipientId!,
          receiverType: _recipientRole!,
          content: message.content,
        );
      }
    }
  }

  void sendMessage() {
    final content = textController.text.trim();
    if (content.isEmpty) return;
    if (_recipientId == null || _recipientRole == null) return;

    final tempMessage = SupportMessage(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      isFromMe: true,
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );

    messages.add(tempMessage);
    textController.clear();
    _scrollToBottom(animate: true);

    // WebSocket orqali xabar yuborish
    if (_webSocketService?.isConnected == true) {
      _webSocketService?.sendMessage(
        receiverId: _recipientId!,
        receiverType: _recipientRole!,
        content: content,
      );
    } else {
      // WebSocket ulanmagan bo'lsa, qayta ulanishga urinish
      _connectWebSocket();
      // Keyin xabarni yuborish
      Future.delayed(const Duration(seconds: 1), () {
        _webSocketService?.sendMessage(
          receiverId: _recipientId!,
          receiverType: _recipientRole!,
          content: content,
        );
      });
    }
  }

  // Typing indikatori
  void emitTyping() {
    if (_recipientId == null || _recipientRole == null) return;

    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 3), () {
      _webSocketService?.sendTypingStatus(
        partnerId: _recipientId!,
        partnerType: _recipientRole!,
        isTyping: false,
      );
    });

    if (_typingTimer == null || !_typingTimer!.isActive) {
      _webSocketService?.sendTypingStatus(
        partnerId: _recipientId!,
        partnerType: _recipientRole!,
        isTyping: true,
      );
      _typingTimer = Timer(const Duration(seconds: 3), () {
        _typingTimer = null;
      });
    }
  }

  void _scrollToBottom({bool animate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        if (animate) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } else {
          scrollController.jumpTo(scrollController.position.maxScrollExtent);
        }
      }
    });
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    _typingStopTimer?.cancel();
    _webSocketService?.dispose();
    textController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    super.onClose();
  }
}

class SupportBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<SupportController>(() => SupportController());
}

class SupportChatScreen extends GetWidget<SupportController> {
  const SupportChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: _buildAppBar(context, isDark),
      body: SafeArea(child: _buildBody(context, isDark)),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      elevation: 0,
      leading: Padding(
        padding: EdgeInsets.all(8.r),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurface : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Icon(
              Icons.chevron_left,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
      title: Text(
        'support'.tr,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
            child: Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ),
        Obx(() => controller.isConnected.value
            ? Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                ),
              )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildBody(BuildContext context, bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildChatSkeleton(isDark);
      }
      return _buildChatView(context, isDark);
    });
  }

  // Shimmer loading skeleton - matching reference project
  Widget _buildChatSkeleton(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurface : Colors.grey.shade300;
    final highlightColor =
        isDark ? AppColors.darkBackground : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 8,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final isFromMe = index % 2 == 0;
                final width = (0.3 + (index % 3) * 0.15).sw;
                return Column(
                  children: [
                    if (index == 3) _buildSkeletonDateChip(isDark),
                    _buildSkeletonMessage(isFromMe, width, isDark),
                  ],
                );
              },
            ),
          ),
          _buildSkeletonInput(isDark),
        ],
      ),
    );
  }

  Widget _buildSkeletonDateChip(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          width: 80.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonMessage(bool isFromMe, double width, bool isDark) {
    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        width: width,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r).copyWith(
            bottomLeft:
                isFromMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight:
                isFromMe ? Radius.zero : Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 6.h),
            Container(
              width: 40.w,
              height: 10.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonInput(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Container(
            width: 48.r,
            height: 48.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // Chat view with messages
  Widget _buildChatView(BuildContext context, bool isDark) {
    return Column(
      children: [
        Expanded(
          child: Obx(() => controller.messages.isEmpty
              ? Center(
                  child: Text(
                    'No messages yet. Start a conversation!',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.darkTextTertiary
                          : Colors.grey,
                      fontSize: 14.sp,
                    ),
                  ),
                )
              : ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final message = controller.messages[index];
                    final showDateHeader = _shouldShowDateHeader(index);
                    return Column(
                      children: [
                        if (showDateHeader)
                          _buildDateHeader(context, message.createdAt, isDark),
                        _buildMessageBubble(message, isDark),
                      ],
                    );
                  },
                )),
        ),
        Obx(() => controller.isPartnerTyping.value
            ? _buildTypingIndicator(isDark)
            : const SizedBox.shrink()),
        _buildMessageInput(isDark),
      ],
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.r,
            height: 12.r,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'typing...',
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : Colors.grey.shade500,
              fontSize: 12.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  bool _shouldShowDateHeader(int index) {
    if (index == 0) return true;
    final current = controller.messages[index].createdAt;
    final previous = controller.messages[index - 1].createdAt;
    return _isDifferentDay(current, previous);
  }

  bool _isDifferentDay(DateTime a, DateTime b) {
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  String _getDateHeaderLabel(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'today'.tr;
    } else if (messageDate == yesterday) {
      return 'yesterday'.tr;
    } else {
      return DateFormat('dd.MM.yyyy').format(date);
    }
  }

  Widget _buildDateHeader(BuildContext context, DateTime date, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            _getDateHeaderLabel(context, date),
            style: TextStyle(
              color: isDark
                  ? AppColors.darkTextTertiary
                  : Colors.grey.shade600,
              fontSize: 12.sp,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(SupportMessage message, bool isDark) {
    final isFromMe = message.isFromMe;
    final timeString = DateFormat('HH:mm').format(message.createdAt);

    return Align(
      alignment: isFromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isFromMe
              ? AppColors.primary
              : (isDark ? AppColors.darkSurface : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16.r).copyWith(
            bottomLeft:
                isFromMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight:
                isFromMe ? Radius.zero : Radius.circular(16.r),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isFromMe
                    ? Colors.white
                    : (isDark ? Colors.white : Colors.black),
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    color: isFromMe
                        ? Colors.white.withValues(alpha: 0.7)
                        : (isDark
                            ? AppColors.darkTextTertiary
                            : Colors.grey.shade500),
                    fontSize: 10.sp,
                  ),
                ),
                if (isFromMe) ...[
                  SizedBox(width: 4.w),
                  _buildStatusIndicator(message.status),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(MessageStatus status) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: 10.r,
          height: 10.r,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.check,
          size: 14.r,
          color: Colors.white.withValues(alpha: 0.7),
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: 14.r,
          color: Colors.white.withValues(alpha: 0.9),
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: 14.r,
          color: Colors.white.withValues(alpha: 0.9),
        );
    }
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.textController,
              focusNode: controller.focusNode,
              decoration: InputDecoration(
                hintText: 'add_comment_hint'.tr,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : Colors.grey.shade500,
                  fontSize: 14.sp,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 20.w,
                  vertical: 12.h,
                ),
              ),
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 14.sp,
              ),
              onChanged: (_) => controller.emitTyping(),
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: controller.sendMessage,
            child: Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: Icon(Icons.send_rounded, color: Colors.white, size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}
