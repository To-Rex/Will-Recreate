import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/property_model.dart';
import '../../data/mock/mock_data.dart';
import '../../app.dart';

// Calendar Screen
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('calendar'.tr)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('available_dates'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text('booking_pre_order_note'.tr + 'up_to_one_month_ahead'.tr, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
          ),
          const Expanded(child: CalendarWidget()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 53,
                child: ElevatedButton(
                  onPressed: () => Get.back(result: DateTime.now()),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder()),
                  child: Text('save'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  const CalendarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker(
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      onDateChanged: (_) {},
    );
  }
}

// Guests Screen
class GuestsController extends GetxController {
  final adults = 1.obs;
  final children = 0.obs;
  final babies = 0.obs;
  final pets = false.obs;

  void incrementAdults() { if (adults.value < 16) adults.value++; }
  void decrementAdults() { if (adults.value > 1) adults.value--; }
  void incrementChildren() { if (children.value < 10) children.value++; }
  void decrementChildren() { if (children.value > 0) children.value--; }
  void incrementBabies() { if (babies.value < 5) babies.value++; }
  void decrementBabies() { if (babies.value > 0) babies.value--; }
  void togglePets() => pets.value = !pets.value;
}

class GuestsBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut<GuestsController>(() => GuestsController());
}

class GuestsScreen extends GetView<GuestsController> {
  const GuestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('who_heading'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('guests_subheading'.tr, style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
            const SizedBox(height: 24),
            _counterTile('adults_label'.tr, 'adults_info'.tr, controller.adults, controller.incrementAdults, controller.decrementAdults),
            const Divider(),
            _counterTile('children_label'.tr, 'children_info'.tr, controller.children, controller.incrementChildren, controller.decrementChildren),
            const Divider(),
            _counterTile('babies_label'.tr, 'babies_info'.tr, controller.babies, controller.incrementBabies, controller.decrementBabies),
            const Divider(),
            Obx(() => SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('pets_label'.tr),
              subtitle: Text('pets_sublabel'.tr),
              value: controller.pets.value,
              onChanged: (_) => controller.togglePets(),
              activeColor: AppColors.primary,
            )),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 53,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder()),
                child: Text('done'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _counterTile(String title, String subtitle, RxInt value, VoidCallback onAdd, VoidCallback onRemove) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle.tr, style: TextStyle(fontSize: 12, color: Get.theme.colorScheme.onSurface.withOpacity(0.5))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(onPressed: onRemove, icon: const Icon(Icons.remove_circle_outline), color: AppColors.primary),
              Obx(() => Text('${value.value}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
              IconButton(onPressed: onAdd, icon: const Icon(Icons.add_circle_outline), color: AppColors.primary),
            ],
          ),
        ],
      ),
    );
  }
}

// Booking Calendar Screen
class BookingCalendarScreen extends StatelessWidget {
  const BookingCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final property = args['property'] as Property?;

    return Scaffold(
      appBar: AppBar(title: Text('book'.tr)),
      body: Column(
        children: [
          const Expanded(child: CalendarWidget()),
          if (property != null)
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(property.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('total_booking_amount_label'.tr, style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          if (property.price != null) ...[
                            const SizedBox(height: 4),
                            Text('${property.price!.toInt().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ')} so\'m', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                          const SizedBox(height: 8),
                          if (property.price != null) ...[
                            Text('${'advance_payment_label'.tr} ${(property.price! * 0.1).toInt()} so\'m', style: const TextStyle(fontSize: 13)),
                            Text('${'payment_upon_arrival_label'.tr} ${(property.price! * 0.9).toInt()} so\'m', style: const TextStyle(fontSize: 13)),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 53,
                      child: ElevatedButton(
                        onPressed: () => Get.toNamed(AppRoutes.paymentMethods),
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: const StadiumBorder()),
                        child: Text('book_action'.tr, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Active Bookings Screen
class ActiveBookingsScreen extends StatelessWidget {
  const ActiveBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = MockData.bookings;
    return Scaffold(
      appBar: AppBar(title: Text('active_bookings_title'.tr)),
      body: bookings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('no_active_bookings'.tr, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text('active_bookings_description'.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              itemBuilder: (context, index) {
                final booking = bookings[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.clientBookingDetail, arguments: {'booking': booking}),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(booking.property.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                              _buildStatusBadge(booking.status),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('${'booking_number_label'.tr}: ${booking.bookingNumber}', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
                          const SizedBox(height: 4),
                          Text('${'dates_label'.tr}: ${booking.checkIn?.toString().substring(0, 10) ?? ''} - ${booking.checkOut?.toString().substring(0, 10) ?? ''}'),
                          if (booking.totalPrice != null) ...[
                            const SizedBox(height: 4),
                            Text('${booking.totalPrice!.toInt()} so\'m', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    switch (status) {
      case 'confirmed':
        color = AppColors.primary;
        text = 'status_confirmed'.tr;
        break;
      case 'cancelled':
        color = Colors.red;
        text = 'status_cancelled'.tr;
        break;
      case 'paid':
        color = Colors.blue;
        text = 'status_paid'.tr;
        break;
      default:
        color = Colors.orange;
        text = 'status_pending'.tr;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// Client Booking Detail Screen
class ClientBookingDetailScreen extends StatelessWidget {
  const ClientBookingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final booking = args['booking'] as ClientBooking?;

    if (booking == null) {
      return Scaffold(appBar: AppBar(), body: const Center(child: Text('No data')));
    }

    return Scaffold(
      appBar: AppBar(title: Text('booking_number_label'.tr)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(booking.property.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _infoRow(context, Icons.confirmation_number, 'booking_number_label'.tr, booking.bookingNumber),
            _infoRow(context, Icons.login, 'check_in_label'.tr, booking.checkIn?.toString().substring(0, 10) ?? 'dates_not_specified'.tr),
            _infoRow(context, Icons.logout, 'check_out_label'.tr, booking.checkOut?.toString().substring(0, 10) ?? 'dates_not_specified'.tr),
            _infoRow(context, Icons.people, 'guests'.tr, '${booking.adults + booking.children}'),
            if (booking.totalPrice != null) _infoRow(context, Icons.payments, 'price_label'.tr, '${booking.totalPrice!.toInt()} so\'m'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {
                  Get.defaultDialog(
                    title: 'cancel_booking_action'.tr,
                    middleText: 'Are you sure?',
                    textConfirm: 'yes'.tr,
                    textCancel: 'no'.tr,
                    onConfirm: () => Get.back(),
                  );
                },
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text('cancel_booking_action'.tr),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(width: 12),
          Expanded(child: Text(label.tr, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
