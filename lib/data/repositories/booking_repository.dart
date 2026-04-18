import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../models/property_model.dart';
import '../services/booking_api_service.dart';

/// Booking repository
class BookingRepository {
  final BookingApiService _apiService = BookingApiService();

  /// Yangi booking yaratish
  Future<ApiResult<BookingResponse>> createBooking(BookingRequest request) async {
    try {
      final result = await _apiService.createBooking(request);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Mijoz bookinglari
  Future<ApiResult<List<ClientBooking>>> getClientBookings() async {
    try {
      final result = await _apiService.getClientBookings();
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Booking detail
  Future<ApiResult<Map<String, dynamic>>> getBookingDetails(String bookingId) async {
    try {
      final result = await _apiService.getBookingDetails(bookingId);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Bookingni bekor qilish
  Future<ApiResult<void>> cancelBooking(String bookingId) async {
    try {
      await _apiService.cancelBooking(bookingId);
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Property kalendari
  Future<ApiResult<List<CalendarDate>>> getPropertyCalendar({
    required String propertyId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final result = await _apiService.getPropertyCalendar(
        propertyId: propertyId,
        fromDate: fromDate,
        toDate: toDate,
      );
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Booking tarixi
  Future<ApiResult<List<BookingHistoryModel>>> getBookingHistory() async {
    try {
      final result = await _apiService.getBookingHistory();
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Booking tarixi detail
  Future<ApiResult<BookingHistoryModel>> getBookingHistoryDetail(
    String bookingId,
  ) async {
    try {
      final result = await _apiService.getBookingHistoryDetail(bookingId);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
}
