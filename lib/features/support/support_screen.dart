import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../data/mock/mock_data.dart';

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
  final isConnected = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initChat();
  }

  void _initChat() {
    // Simulate loading delay like reference project
    Future.delayed(const Duration(milliseconds: 1200), () {
      final chatMsgs = MockData.chatMessages;
      for (final m in chatMsgs) {
        messages.add(SupportMessage(
          id: m.id,
          content: m.text,
          isFromMe: m.isMe,
          createdAt: m.time,
          status: MessageStatus.sent,
        ));
      }
      isLoading.value = false;
      _scrollToBottom();
    });
  }

  void sendMessage() {
    final content = textController.text.trim();
    if (content.isEmpty) return;

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

    // Simulate sending confirmation
    Future.delayed(const Duration(milliseconds: 500), () {
      final index = messages.indexWhere((m) => m.id == tempMessage.id);
      if (index != -1) {
        messages[index] = SupportMessage(
          id: tempMessage.id,
          content: tempMessage.content,
          isFromMe: true,
          createdAt: tempMessage.createdAt,
          status: MessageStatus.sent,
        );
      }
    });

    // Simulate typing indicator
    Future.delayed(const Duration(milliseconds: 800), () {
      isPartnerTyping.value = true;
    });

    // Mock auto-reply
    Future.delayed(const Duration(seconds: 2), () {
      isPartnerTyping.value = false;
      messages.add(SupportMessage(
        id: 'msg-reply-${DateTime.now().millisecondsSinceEpoch}',
        content: 'Rahmat! Xabaringiz qabul qilindi. Tez orada javob beramiz.',
        isFromMe: false,
        createdAt: DateTime.now(),
      ));
      _scrollToBottom(animate: true);
    });
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
