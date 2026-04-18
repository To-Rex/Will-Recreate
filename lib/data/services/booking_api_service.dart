import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/safe_parse.dart';
import '../models/property_model.dart';

/// Booking API endpointlari bilan ishlash
class BookingApiService {
  final Dio _dio = DioClient.dio;

  /// Yangi booking yaratish
  Future<BookingResponse> createBooking(BookingRequest request) async {
    final res = await _dio.post('/booking/client/', data: request.toJson());

    final data = res.data;
    if (data is List && data.isNotEmpty) {
      return BookingResponse.fromJson(safeMap(data.last));
    }
    return BookingResponse.fromJson(safeMap(data));
  }

  /// Mijoz bookinglari ro'yxati
  Future<List<ClientBooking>> getClientBookings() async {
    final res = await _dio.get('/booking/client/');
    return safeListParse(res.data, ClientBooking.fromJson);
  }

  /// Booking detail
  Future<Map<String, dynamic>> getBookingDetails(String bookingId) async {
    final res = await _dio.get('/booking/client/$bookingId/');
    return safeMap(res.data);
  }

  /// Bookingni bekor qilish
  Future<void> cancelBooking(String bookingId) async {
    await _dio.post('/booking/client/$bookingId/cancel/');
  }

  /// Property kalendari
  Future<List<CalendarDate>> getPropertyCalendar({
    required String propertyId,
    required String fromDate,
    required String toDate,
  }) async {
    final res = await _dio.get(
      '/booking/properties/$propertyId/calendar/',
      queryParameters: {'from_date': fromDate, 'to_date': toDate},
    );
    final data = safeMap(res.data);
    return safeListParse(data['calendar'], CalendarDate.fromJson);
  }

  /// Booking tarixi
  Future<List<BookingHistoryModel>> getBookingHistory() async {
    final res = await _dio.get('/booking/client/history/');
    return safeListParse(res.data, BookingHistoryModel.fromJson);
  }

  /// Booking tarixi detail
  Future<BookingHistoryModel> getBookingHistoryDetail(String bookingId) async {
    final res = await _dio.get('/booking/client/history/$bookingId/');
    return BookingHistoryModel.fromJson(res.data);
  }
}
