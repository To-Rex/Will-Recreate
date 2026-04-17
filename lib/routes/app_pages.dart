import 'package:get/get.dart';
import '../app.dart';
import '../features/splash/splash_controller.dart';
import '../features/splash/splash_screen.dart';
import '../features/onboarding/onboarding_controller.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/auth/auth_controller.dart';
import '../features/auth/auth_screens.dart';
import '../features/home/home_controller.dart';
import '../features/home/home_screen.dart';
import '../features/search/search_screen.dart';
import '../features/listing/listing_detail_screen.dart';
import '../features/booking/booking_screens.dart';
import '../features/booking/booking_history_screen.dart';
import '../features/favorites/favorites_screen.dart';
import '../features/payment/payment_screens.dart';
import '../features/settings/settings_screens.dart';
import '../features/support/support_screen.dart';

class AppPages {
  static final pages = [
    // Core bindings
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),

    // Auth
    GetPage(
      name: AppRoutes.userInfo,
      page: () => const UserInfoScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.phoneRegister,
      page: () => const PhoneRegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.phoneLogin,
      page: () => const PhoneLoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.otp,
      page: () => const OtpScreen(),
      binding: AuthBinding(),
    ),

    // Home
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),

    // Search
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
    ),

    // Listing Detail
    GetPage(
      name: AppRoutes.listingDetail,
      page: () => const ListingDetailScreen(),
    ),

    // Calendar & Guests
    GetPage(
      name: AppRoutes.calendar,
      page: () => const CalendarScreen(),
    ),
    GetPage(
      name: AppRoutes.guests,
      page: () => const GuestsScreen(),
      binding: GuestsBinding(),
    ),

    // Booking
    GetPage(
      name: AppRoutes.bookingCalendar,
      page: () => const BookingCalendarScreen(),
    ),
    GetPage(
      name: AppRoutes.activeBookings,
      page: () => const ActiveBookingsScreen(),
    ),
    GetPage(
      name: AppRoutes.clientBookingDetail,
      page: () => const ClientBookingDetailScreen(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const BookingHistoryScreen(),
      binding: BookingHistoryBinding(),
    ),

    // Favorites
    GetPage(
      name: AppRoutes.favorites,
      page: () => const FavoritesScreen(),
      binding: FavoritesBinding(),
    ),

    // Payment
    GetPage(
      name: AppRoutes.paymentMethods,
      page: () => const PaymentMethodsScreen(),
      binding: PaymentBinding(),
    ),
    GetPage(
      name: AppRoutes.addCard,
      page: () => const AddCardScreen(),
    ),

    // Settings
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.language,
      page: () => const LanguageScreen(),
    ),

    // Support
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportChatScreen(),
      binding: SupportBinding(),
    ),
  ];
}
