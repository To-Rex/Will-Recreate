import 'dart:async';
import '../models/api_log_model.dart';

/// API loglarini xotirada saqlash va boshqarish servisi
class ApiLogService {
  static final ApiLogService _instance = ApiLogService._internal();
  factory ApiLogService() => _instance;
  ApiLogService._internal();

  static ApiLogService get instance => _instance;

  final List<ApiLog> _logs = [];
  final int _maxLogs = 100; // Maksimal loglar soni

  final StreamController<List<ApiLog>> _logsController =
      StreamController<List<ApiLog>>.broadcast();

  /// Loglar o'zgarishini kuzatish
  Stream<List<ApiLog>> get logsStream => _logsController.stream;

  /// Barcha loglar ro'yxati
  List<ApiLog> get logs => List.unmodifiable(_logs);

  /// Loglar soni
  int get count => _logs.length;

  /// Yangi log qo'shish
  void addLog(ApiLog log) {
    _logs.insert(0, log); // Eng yangi log birinchi
    if (_logs.length > _maxLogs) {
      _logs.removeLast(); // Eski loglarni o'chirish
    }
    _logsController.add(List.unmodifiable(_logs));
  }

  /// Barcha loglarni tozalash
  void clearLogs() {
    _logs.clear();
    _logsController.add(List.unmodifiable(_logs));
  }

  /// StreamController ni yopish
  void dispose() {
    _logsController.close();
  }
}
