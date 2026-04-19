import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/models/api_log_model.dart';
import '../../core/services/api_log_service.dart';
import '../../core/services/base_url_service.dart';
import '../../core/network/dio_client.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/theme/app_colors.dart';

const String _devPasswordKey = 'QAZZAQs!2';
const String _defaultPassword = 'Weel123@#';

class DeveloperScreen extends StatefulWidget {
  const DeveloperScreen({super.key});

  @override
  State<DeveloperScreen> createState() => _DeveloperScreenState();
}

class _DeveloperScreenState extends State<DeveloperScreen> {
  final _storage = SecureStorageService();
  final _logService = ApiLogService.instance;
  final _baseUrlService = BaseUrlService();

  String? _accessToken;
  String? _refreshToken;
  bool _isLoading = true;
  bool _isAccessObscured = true;
  bool _isRefreshObscured = true;

  // Expansion states
  bool _isTokensExpanded = true;
  bool _isPasswordExpanded = false;
  bool _isApiLogsExpanded = false;
  bool _isBaseUrlExpanded = false;

  // Base URL states
  List<BaseUrlItem> _allUrls = [];
  String _activeUrlId = BaseUrlService.defaultId;

  // API logs
  List<ApiLog> _apiLogs = [];
  StreamSubscription<List<ApiLog>>? _logsSubscription;
  final Set<String> _expandedLogIds = {};

  final _accessController = TextEditingController();
  final _refreshController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTokens();
    _loadBaseUrls();
    _apiLogs = _logService.logs;
    _logsSubscription = _logService.logsStream.listen((logs) {
      if (mounted) {
        setState(() => _apiLogs = logs);
      }
    });
  }

  @override
  void dispose() {
    _logsSubscription?.cancel();
    _accessController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadTokens() async {
    final tokens = await _storage.getTokens();
    setState(() {
      _accessToken = tokens['access_token'] ?? '';
      _refreshToken = tokens['refresh_token'] ?? '';
      _accessController.text = _accessToken ?? '';
      _refreshController.text = _refreshToken ?? '';
      _isLoading = false;
    });
  }

  Future<void> _loadBaseUrls() async {
    final urls = await _baseUrlService.getAllUrls();
    final activeId = await _baseUrlService.getActiveId();
    setState(() {
      _allUrls = urls;
      _activeUrlId = activeId;
    });
  }

  Future<void> _saveTokens() async {
    final newAccess = _accessController.text.trim();
    final newRefresh = _refreshController.text.trim();

    if (newAccess.isEmpty || newRefresh.isEmpty) {
      _showSnackBar('Tokenlar bo\'sh bo\'lishi mumkin emas', isError: true);
      return;
    }

    await _storage.saveTokens(
      accessToken: newAccess,
      refreshToken: newRefresh,
    );

    setState(() {
      _accessToken = newAccess;
      _refreshToken = newRefresh;
    });

    _showSnackBar('Tokenlar muvaffaqiyatli saqlandi');
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('$label nusxalandi');
  }

  String _maskToken(String token) {
    if (token.isEmpty) return '';
    if (token.length <= 8) return '•' * token.length;
    return '${token.substring(0, 4)}${'•' * (token.length - 8)}${token.substring(token.length - 4)}';
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        margin: EdgeInsets.all(16.w),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
      appBar: AppBar(
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
                    color: isDark
                        ? Colors.black.withOpacity(0.3)
                        : Colors.grey.withOpacity(0.1),
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
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.code_rounded,
              color: AppColors.primary,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              'Developer',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // API Loglar bo'limi
                  _buildApiLogsSection(isDark),
                  SizedBox(height: 12.h),

                  // Base URL bo'limi
                  _buildBaseUrlSection(isDark),
                  SizedBox(height: 12.h),

                  // Tokenlar bo'limi
                  _buildExpandableSection(
                    isDark: isDark,
                    title: 'Tokenlar',
                    icon: Icons.token_rounded,
                    isExpanded: _isTokensExpanded,
                    onToggle: () => setState(() => _isTokensExpanded = !_isTokensExpanded),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Access Token
                        _buildTokenSection(
                          context: context,
                          isDark: isDark,
                          label: 'Access Token',
                          token: _accessToken,
                          controller: _accessController,
                          isObscured: _isAccessObscured,
                          onToggleVisibility: () {
                            setState(() => _isAccessObscured = !_isAccessObscured);
                          },
                          onCopy: () => _copyToClipboard(_accessToken ?? '', 'Access token'),
                        ),
                        SizedBox(height: 16.h),

                        // Refresh Token
                        _buildTokenSection(
                          context: context,
                          isDark: isDark,
                          label: 'Refresh Token',
                          token: _refreshToken,
                          controller: _refreshController,
                          isObscured: _isRefreshObscured,
                          onToggleVisibility: () {
                            setState(() => _isRefreshObscured = !_isRefreshObscured);
                          },
                          onCopy: () => _copyToClipboard(_refreshToken ?? '', 'Refresh token'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Parollar bo'limi
                  _buildExpandableSection(
                    isDark: isDark,
                    title: 'Parollar',
                    icon: Icons.key_rounded,
                    isExpanded: _isPasswordExpanded,
                    onToggle: () => setState(() => _isPasswordExpanded = !_isPasswordExpanded),
                    child: _buildPasswordSection(context, isDark),
                  ),
                  SizedBox(height: 24.h),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton.icon(
                      onPressed: _saveTokens,
                      icon: Icon(Icons.save_rounded, size: 20.sp),
                      label: Text(
                        'Saqlash',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  // Warning
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.orange.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.orange.shade700,
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            'Tokenlarni o\'zgartirish ilova ishiga ta\'sir qilishi mumkin',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // ==================== API LOGS SECTION ====================

  Widget _buildApiLogsSection(bool isDark) {
    return _buildExpandableSection(
      isDark: isDark,
      title: 'API Loglar',
      icon: Icons.api_rounded,
      isExpanded: _isApiLogsExpanded,
      onToggle: () => setState(() => _isApiLogsExpanded = !_isApiLogsExpanded),
      trailing: _buildApiLogsTrailing(isDark),
      child: _apiLogs.isEmpty
          ? _buildEmptyLogsState(isDark)
          : Column(
              children: [
                // Loglar ro'yxati
                ..._apiLogs.map((log) => _buildApiLogItem(log, isDark)),
              ],
            ),
    );
  }

  // ==================== BASE URL SECTION ====================

  Widget _buildBaseUrlSection(bool isDark) {
    return _buildExpandableSection(
      isDark: isDark,
      title: 'Base URL',
      icon: Icons.dns_rounded,
      isExpanded: _isBaseUrlExpanded,
      onToggle: () => setState(() => _isBaseUrlExpanded = !_isBaseUrlExpanded),
      trailing: _buildBaseUrlTrailing(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // URL ro'yxati
          ..._allUrls.map((url) => _buildUrlItem(url, isDark)),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildBaseUrlTrailing(bool isDark) {
    return GestureDetector(
      onTap: () => _showAddUrlDialog(isDark),
      child: Container(
        padding: EdgeInsets.all(6.r),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          Icons.add_rounded,
          size: 18.sp,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildUrlItem(BaseUrlItem item, bool isDark) {
    final isDefault = item.id == BaseUrlService.defaultId;
    final isActive = item.id == _activeUrlId;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.primary.withOpacity(0.06)
            : isDark
                ? AppColors.darkSurfaceVariant
                : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withOpacity(0.4)
              : isDark
                  ? AppColors.darkBorder
                  : Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: () => _selectUrl(item),
        borderRadius: BorderRadius.circular(10.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          child: Row(
            children: [
              // Radio indicator
              Container(
                width: 20.r,
                height: 20.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: isActive
                        ? AppColors.primary
                        : isDark
                            ? AppColors.darkTextTertiary
                            : Colors.grey.shade400,
                    width: 2,
                  ),
                ),
                child: isActive
                    ? Icon(Icons.check_rounded, size: 14.sp, color: Colors.white)
                    : null,
              ),
              SizedBox(width: 10.w),

              // Name va URL
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isActive
                                ? AppColors.primary
                                : isDark
                                    ? AppColors.darkTextPrimary
                                    : Colors.black87,
                          ),
                        ),
                        if (isDefault) ...[
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'ASOSIY',
                              style: TextStyle(
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      item.url,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontFamily: 'monospace',
                        color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Action buttons (faqat custom URL'lar uchun)
              if (!isDefault) ...[
                SizedBox(width: 6.w),
                _buildMiniButton(
                  icon: Icons.edit_rounded,
                  onTap: () => _showEditUrlDialog(item, isDark),
                  isDark: isDark,
                ),
                SizedBox(width: 4.w),
                _buildMiniButton(
                  icon: Icons.delete_outline_rounded,
                  onTap: () => _confirmDeleteUrl(item),
                  isDark: isDark,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectUrl(BaseUrlItem item) async {
    await _baseUrlService.setActiveId(item.id);
    DioClient.updateBaseUrl(item.url);
    setState(() => _activeUrlId = item.id);
    _showSnackBar('Base URL o\'zgartirildi: ${item.name}');
  }

  void _showAddUrlDialog(bool isDark) {
    final nameController = TextEditingController();
    final urlController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => _buildUrlDialog(
        context: ctx,
        isDark: isDark,
        title: 'Base URL qo\'shish',
        nameController: nameController,
        urlController: urlController,
        onConfirm: () async {
          final name = nameController.text.trim();
          final url = urlController.text.trim();
          if (name.isEmpty || url.isEmpty) {
            _showSnackBar('Barcha maydonlarni to\'ldiring', isError: true);
            return;
          }
          if (Uri.tryParse(url) == null) {
            _showSnackBar('URL formati noto\'g\'ri', isError: true);
            return;
          }
          Navigator.pop(ctx);
          await _baseUrlService.addCustomUrl(name: name, url: url);
          await _loadBaseUrls();
          _showSnackBar('Base URL qo\'shildi');
        },
      ),
    );
  }

  void _showEditUrlDialog(BaseUrlItem item, bool isDark) {
    final nameController = TextEditingController(text: item.name);
    final urlController = TextEditingController(text: item.url);

    showDialog(
      context: context,
      builder: (ctx) => _buildUrlDialog(
        context: ctx,
        isDark: isDark,
        title: 'Base URL tahrirlash',
        nameController: nameController,
        urlController: urlController,
        onConfirm: () async {
          final name = nameController.text.trim();
          final url = urlController.text.trim();
          if (name.isEmpty || url.isEmpty) {
            _showSnackBar('Barcha maydonlarni to\'ldiring', isError: true);
            return;
          }
          Navigator.pop(ctx);
          await _baseUrlService.updateCustomUrl(item.id, name: name, url: url);
          // Agar aktiv URL tahrirlansa, DioClient'ni yangilash
          if (item.id == _activeUrlId) {
            DioClient.updateBaseUrl(url);
          }
          await _loadBaseUrls();
          _showSnackBar('Base URL yangilandi');
        },
      ),
    );
  }

  Widget _buildUrlDialog({
    required BuildContext context,
    required bool isDark,
    required String title,
    required TextEditingController nameController,
    required TextEditingController urlController,
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameController,
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'Nomi',
              labelStyle: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade600,
                fontSize: 13.sp,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: urlController,
            style: TextStyle(
              fontSize: 13.sp,
              fontFamily: 'monospace',
              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
            decoration: InputDecoration(
              labelText: 'URL',
              hintText: 'https://api.example.com/api',
              labelStyle: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade600,
                fontSize: 13.sp,
              ),
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
                fontSize: 12.sp,
                fontFamily: 'monospace',
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Bekor qilish',
            style: TextStyle(
              color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade600,
              fontSize: 14.sp,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            elevation: 0,
          ),
          child: Text(
            'Saqlash',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _confirmDeleteUrl(BaseUrlItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'O\'chirish',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '"${item.name}" base URL\'ni o\'chirmoqchimisiz?',
          style: TextStyle(fontSize: 14.sp),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Bekor qilish',
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _baseUrlService.deleteCustomUrl(item.id);
              await _loadBaseUrls();
              // DioClient'ni yangilash (aktiv URL o'chirilgan bo'lishi mumkin)
              final activeUrl = await _baseUrlService.getActiveBaseUrl();
              DioClient.updateBaseUrl(activeUrl);
              _showSnackBar('Base URL o\'chirildi');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: Text(
              'O\'chirish',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiLogsTrailing(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_apiLogs.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Text(
              '${_apiLogs.length}',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        if (_apiLogs.isNotEmpty) SizedBox(width: 8.w),
        if (_apiLogs.isNotEmpty)
          GestureDetector(
            onTap: () {
              _logService.clearLogs();
              setState(() => _expandedLogIds.clear());
            },
            child: Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.delete_outline_rounded,
                size: 16.sp,
                color: Colors.red.shade400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyLogsState(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 32.sp,
            color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
          ),
          SizedBox(height: 8.h),
          Text(
            'Hali API so\'rovlar yo\'q',
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiLogItem(ApiLog log, bool isDark) {
    final isExpanded = _expandedLogIds.contains(log.id);

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          // Asosiy qator (doim ko'rinadi)
          GestureDetector(
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedLogIds.remove(log.id);
                } else {
                  _expandedLogIds.add(log.id);
                }
              });
            },
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  // Method badge
                  _buildMethodBadge(log.method, isDark),
                  SizedBox(width: 8.w),

                  // URL
                  Expanded(
                    child: Text(
                      log.shortUrl,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),

                  // Duration
                  if (log.formattedDuration.isNotEmpty)
                    Text(
                      log.formattedDuration,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade500,
                      ),
                    ),
                  SizedBox(width: 6.w),

                  // Status code badge
                  _buildStatusCodeBadge(log, isDark),
                  SizedBox(width: 4.w),

                  // Expand icon
                  AnimatedRotation(
                    turns: isExpanded ? 0.0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 18.sp,
                      color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Kengaytirilgan kontent
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: _buildExpandedLogContent(log, isDark),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  Widget _buildMethodBadge(String method, bool isDark) {
    final Color bgColor;
    final Color textColor;
    switch (method.toUpperCase()) {
      case 'GET':
        bgColor = Colors.blue.withOpacity(0.15);
        textColor = Colors.blue;
        break;
      case 'POST':
        bgColor = Colors.green.withOpacity(0.15);
        textColor = Colors.green.shade700;
        break;
      case 'PUT':
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade700;
        break;
      case 'PATCH':
        bgColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orange.shade700;
        break;
      case 'DELETE':
        bgColor = Colors.red.withOpacity(0.15);
        textColor = Colors.red.shade700;
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.15);
        textColor = Colors.grey.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatusCodeBadge(ApiLog log, bool isDark) {
    if (log.statusCode == null) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          borderRadius: BorderRadius.circular(5.r),
        ),
        child: Text(
          'ERR',
          style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w700,
            color: Colors.grey.shade600,
          ),
        ),
      );
    }

    final Color bgColor;
    final Color textColor;
    if (log.isSuccess) {
      bgColor = Colors.green.withOpacity(0.15);
      textColor = Colors.green.shade700;
    } else if (log.statusCode! >= 400 && log.statusCode! < 500) {
      bgColor = Colors.orange.withOpacity(0.15);
      textColor = Colors.orange.shade700;
    } else {
      bgColor = Colors.red.withOpacity(0.15);
      textColor = Colors.red.shade700;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: Text(
        '${log.statusCode}',
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildExpandedLogContent(ApiLog log, bool isDark) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 12.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // To'liq URL
          _buildLogDetailRow(
            label: 'URL',
            value: log.url,
            isDark: isDark,
            onCopy: () => _copyToClipboard(log.url, 'URL'),
          ),
          SizedBox(height: 8.h),

          // Vaqt
          _buildLogDetailRow(
            label: 'Vaqt',
            value: '${log.timestamp.toLocal().toString().substring(0, 19)}'
                '${log.formattedDuration.isNotEmpty ? '  (${log.formattedDuration})' : ''}',
            isDark: isDark,
          ),
          SizedBox(height: 8.h),

          // Xato
          if (log.error != null) ...[
            _buildLogDetailRow(
              label: 'Xato',
              value: log.error!,
              isDark: isDark,
              valueColor: Colors.red.shade400,
            ),
            SizedBox(height: 8.h),
          ],

          // Headers
          if (log.formattedHeaders.isNotEmpty) ...[
            _buildLogCodeBlock(
              label: 'Headers',
              content: log.formattedHeaders,
              isDark: isDark,
              onCopy: () => _copyToClipboard(log.formattedHeaders, 'Headers'),
            ),
            SizedBox(height: 8.h),
          ],

          // Request Body
          if (log.formattedRequestBody.isNotEmpty) ...[
            _buildLogCodeBlock(
              label: 'Request Body',
              content: log.formattedRequestBody,
              isDark: isDark,
              onCopy: () => _copyToClipboard(log.formattedRequestBody, 'Request body'),
            ),
            SizedBox(height: 8.h),
          ],

          // Response Body
          if (log.formattedResponseBody.isNotEmpty) ...[
            _buildLogCodeBlock(
              label: 'Response Body',
              content: log.formattedResponseBody,
              isDark: isDark,
              onCopy: () => _copyToClipboard(log.formattedResponseBody, 'Response body'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLogDetailRow({
    required String label,
    required String value,
    required bool isDark,
    Color? valueColor,
    VoidCallback? onCopy,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 60.w,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: valueColor ?? (isDark ? AppColors.darkTextSecondary : Colors.black87),
              fontFamily: 'monospace',
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (onCopy != null)
          GestureDetector(
            onTap: onCopy,
            child: Padding(
              padding: EdgeInsets.only(left: 4.w),
              child: Icon(
                Icons.copy_rounded,
                size: 14.sp,
                color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLogCodeBlock({
    required String label,
    required String content,
    required bool isDark,
    VoidCallback? onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade500,
              ),
            ),
            if (onCopy != null)
              GestureDetector(
                onTap: onCopy,
                child: Icon(
                  Icons.copy_rounded,
                  size: 14.sp,
                  color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 200.h),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBackground
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
              ),
            ),
            child: Scrollbar(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(8.r),
                physics: const AlwaysScrollableScrollPhysics(),
                child: SelectableText(
                  content,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontFamily: 'monospace',
                    color: isDark ? AppColors.darkTextSecondary : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== EXPANDABLE SECTION ====================

  Widget _buildExpandableSection({
    required bool isDark,
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - tap to expand/collapse
          GestureDetector(
            onTap: onToggle,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextPrimary : Colors.black87,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing,
                  if (trailing != null) SizedBox(width: 8.w),
                  AnimatedRotation(
                    turns: isExpanded ? 0.0 : -0.25,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(14.r, 0, 14.r, 14.r),
              child: child,
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ==================== PASSWORD SECTION ====================

  Future<void> _changePassword(
    String currentPwd,
    String newPwd,
    String confirmPwd,
  ) async {
    if (currentPwd.isEmpty || newPwd.isEmpty || confirmPwd.isEmpty) {
      _showSnackBar('Barcha maydonlarni to\'ldiring', isError: true);
      return;
    }

    // Verify current password
    final storedPassword = await _storage.read(_devPasswordKey);
    final actualPassword = storedPassword ?? _defaultPassword;

    if (currentPwd != actualPassword) {
      _showSnackBar('Joriy parol noto\'g\'ri', isError: true);
      return;
    }

    if (newPwd != confirmPwd) {
      _showSnackBar('Yangi parollar mos emas', isError: true);
      return;
    }

    if (newPwd.length < 6) {
      _showSnackBar('Parol kamida 6 belgidan iborat bo\'lishi kerak', isError: true);
      return;
    }

    await _storage.write(_devPasswordKey, newPwd);
    _showSnackBar('Parol muvaffaqiyatli o\'zgartirildi');
  }

  Widget _buildPasswordSection(BuildContext context, bool isDark) {
    final currentPwdController = TextEditingController();
    final newPwdController = TextEditingController();
    final confirmPwdController = TextEditingController();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPasswordField(
          controller: currentPwdController,
          hint: 'Joriy parol',
          isDark: isDark,
        ),
        SizedBox(height: 10.h),
        _buildPasswordField(
          controller: newPwdController,
          hint: 'Yangi parol',
          isDark: isDark,
        ),
        SizedBox(height: 10.h),
        _buildPasswordField(
          controller: confirmPwdController,
          hint: 'Yangi parolni tasdiqlash',
          isDark: isDark,
        ),
        SizedBox(height: 14.h),
        SizedBox(
          width: double.infinity,
          height: 44.h,
          child: OutlinedButton.icon(
            onPressed: () => _changePassword(
              currentPwdController.text,
              newPwdController.text,
              confirmPwdController.text,
            ),
            icon: Icon(Icons.key_rounded, size: 18.sp),
            label: Text(
              'Parolni o\'zgartirish',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(
        fontSize: 14.sp,
        color: isDark ? AppColors.darkTextPrimary : Colors.black87,
      ),
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        filled: true,
        fillColor: isDark ? AppColors.darkSurfaceVariant : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  // ==================== TOKEN SECTION ====================

  Widget _buildTokenSection({
    required BuildContext context,
    required bool isDark,
    required String label,
    required String? token,
    required TextEditingController controller,
    required bool isObscured,
    required VoidCallback onToggleVisibility,
    required VoidCallback onCopy,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildMiniButton(
                  icon: isObscured ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  onTap: onToggleVisibility,
                  isDark: isDark,
                ),
                SizedBox(width: 6.w),
                _buildMiniButton(
                  icon: Icons.copy_rounded,
                  onTap: onCopy,
                  isDark: isDark,
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : Colors.grey.shade200,
            ),
          ),
          child: TextField(
            controller: isObscured
                ? TextEditingController(text: _maskToken(controller.text))
                : controller,
            maxLines: 4,
            minLines: 3,
            readOnly: isObscured,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: 'monospace',
              color: isDark ? AppColors.darkTextPrimary : Colors.black87,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12.r),
              border: InputBorder.none,
              hintText: 'Token...',
              hintStyle: TextStyle(
                color: isDark ? AppColors.darkTextTertiary : Colors.grey.shade400,
                fontFamily: 'monospace',
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMiniButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.r,
        height: 32.r,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade600,
        ),
      ),
    );
  }
}
