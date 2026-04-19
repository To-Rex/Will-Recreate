import 'package:get/get.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../payment/payment_screens.dart';

/// Booking flow uchun GetX controller
class BookingController extends GetxController {
  final _repository = BookingRepository();

  // Property
  final property = Rx<Property?>(null);

  // Dates
  final checkIn = Rx<DateTime?>(null);
  final checkOut = Rx<DateTime?>(null);

  // Guests
  final adults = 1.obs;
  final children = 0.obs;
  final babies = 0.obs;

  // Payment
  final selectedCardId = Rx<String?>(null);

  // State
  final isLoading = false.obs;
  final errorMessage = Rx<String?>(null);
  final bookingDetails = Rx<Map<String, dynamic>?>(null);

  void init(Property prop) {
    property.value = prop;
  }

  void setDates(DateTime start, DateTime? end) {
    checkIn.value = start;
    checkOut.value = end;
  }

  void setGuests({int? adults, int? children, int? babies}) {
    if (adults != null) this.adults.value = adults;
    if (children != null) this.children.value = children;
    if (babies != null) this.babies.value = babies;
  }

  void setCard(String cardId) {
    selectedCardId.value = cardId;
  }

  int calculateTotalAmount() {
    final prop = property.value;
    if (prop == null || prop.price == null) return 0;

    final start = checkIn.value;
    final end = checkOut.value ?? checkIn.value?.add(const Duration(days: 1));
    if (start == null || end == null) return 0;

    int nights = end.difference(start).inDays;
    if (nights <= 0) nights = 1;

    return (prop.price! * nights).toInt();
  }

  Future<void> createBooking() async {
    final prop = property.value;
    final start = checkIn.value;
    final end = checkOut.value;
    final cardId = selectedCardId.value;

    if (prop == null || start == null || end == null || cardId == null) {
      errorMessage.value = 'missing_booking_data'.tr;
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;

    final request = BookingRequest(
      propertyId: prop.guid,
      cardId: cardId,
      checkIn: start.toIso8601String().split('T')[0],
      checkOut: end.toIso8601String().split('T')[0],
      adults: adults.value,
      children: children.value,
      babies: babies.value,
    );

    final result = await _repository.createBooking(request);

    result.when(
      success: (response) async {
        // Get booking details
        final detailsResult = await _repository.getBookingDetails(response.id);
        detailsResult.when(
          success: (details) {
            bookingDetails.value = details;
            isLoading.value = false;
          },
          failure: (msg) {
            errorMessage.value = msg;
            isLoading.value = false;
          },
        );
      },
      failure: (msg) {
        errorMessage.value = msg;
        isLoading.value = false;
      },
    );
  }

  void reset() {
    property.value = null;
    checkIn.value = null;
    checkOut.value = null;
    adults.value = 1;
    children.value = 0;
    babies.value = 0;
    selectedCardId.value = null;
    isLoading.value = false;
    errorMessage.value = null;
    bookingDetails.value = null;
  }
}

/// BookingFlow uchun Binding
class BookingFlowBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingController>(() => BookingController());
    Get.lazyPut<PaymentController>(() => PaymentController());
  }
}
