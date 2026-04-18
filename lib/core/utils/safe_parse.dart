// JSON parsing uchun xavfsiz utility funksiyalar
// Null va tur xatolaridan himoya qiladi

String safeString(dynamic value, [String fallback = '']) {
  if (value == null) return fallback;
  if (value is String) return value.isEmpty ? fallback : value;
  return value.toString();
}

String? safeStringOrNull(dynamic value) {
  if (value == null) return null;
  if (value is String) return value.isEmpty ? null : value;
  return value.toString();
}

int safeInt(dynamic value, [int fallback = 0]) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

double safeDouble(dynamic value, [double fallback = 0.0]) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? fallback;
  return fallback;
}

bool safeBool(dynamic value, [bool fallback = false]) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is int) return value != 0;
  if (value is String) return value.toLowerCase() == 'true';
  return fallback;
}

DateTime safeDateTime(dynamic value, [DateTime? fallback]) {
  if (value is String) return DateTime.tryParse(value) ?? fallback ?? DateTime.now();
  if (value is DateTime) return value;
  return fallback ?? DateTime.now();
}

Map<String, dynamic> safeMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.map((k, v) => MapEntry(k.toString(), v));
  return {};
}

List<T> safeListParse<T>(dynamic value, T Function(Map<String, dynamic>) fromJson) {
  if (value is List) {
    return value
        .whereType<Map>()
        .map((e) => fromJson(safeMap(e)))
        .toList();
  }
  return [];
}
