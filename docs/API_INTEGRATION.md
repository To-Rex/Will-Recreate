# WEEL App - API Integratsiya Arxitekturasi

## Arxitektura Oqimi

```
UI (Screens) → Controllers (GetxController) → Repositories → API Services → Dio Client
```

## Yaratilgan Fayllar

### Core Infrastructure
| Fayl | Tavsif |
|------|--------|
| `lib/core/config/app_config.dart` | Base URL va timeout sozlamalari |
| `lib/core/utils/safe_parse.dart` | JSON parse uchun xavfsiz utility |
| `lib/core/storage/secure_storage_service.dart` | Token va user ma'lumotlarini saqlash |
| `lib/core/network/dio_client.dart` | Markaziy Dio instance (singleton) |
| `lib/core/network/auth_interceptor.dart` | Token qo'shish va 401 da refresh |
| `lib/core/network/api_result.dart` | ApiResult (Success/Failure) wrapper |

### API Services (Data Source)
| Fayl | Endpointlar |
|------|-------------|
| `lib/data/services/auth_api_service.dart` | `/user/client/register/`, `/user/client/login/`, `/user/client/verify/`, `/user/refresh/`, `/user/client/logout/` |
| `lib/data/services/property_api_service.dart` | `/property/types/`, `/property/properties/`, `/property/services/`, `/story/public/stories/`, `/property/properties/{guid}/reviews/` |
| `lib/data/services/booking_api_service.dart` | `/booking/client/`, `/booking/client/{id}/`, `/booking/client/{id}/cancel/`, `/booking/properties/{id}/calendar/`, `/booking/client/history/` |
| `lib/data/services/payment_api_service.dart` | `/user/client/cards/`, `/user/client/cards/verify/`, `/user/client/cards/resend/` |
| `lib/data/services/support_api_service.dart` | `/chat/conversations/`, `/chat/recipient/{role}/`, `/chat/messages/{id}/` |

### Repositories (Business Logic)
| Fayl | Tavsif |
|------|--------|
| `lib/data/repositories/auth_repository.dart` | Auth logikasi, token saqlash, user yuklash |
| `lib/data/repositories/property_repository.dart` | Property filter/search, reviews, stories |
| `lib/data/repositories/booking_repository.dart` | Booking CRUD, kalendar, tarix |
| `lib/data/repositories/payment_repository.dart` | Kartalar CRUD, OTP |
| `lib/data/repositories/support_repository.dart` | Chat, xabarlar |
| `lib/data/repositories/favorites_repository.dart` | Local storage (sevimlilar) |

## Screen → API Mapping

| Screen | Controller | Repository | API Endpoints |
|--------|-----------|------------|---------------|
| **Splash** | `SplashController` | `AuthRepository.loadUserFromStorage()` | - |
| **Onboarding** | `OnboardingController` | - | - |
| **UserInfo (Register)** | `AuthController` | `AuthRepository.register()` | `POST /user/client/register/` |
| **PhoneInput** | `AuthController` | `AuthRepository.login()` / `register()` | `POST /user/client/login/` |
| **OTP Verify** | `AuthController` | `AuthRepository.verifyOtp()` | `POST /user/client/register/verify/` yoki `/login/verify/` |
| **Home** | `HomeController` | `PropertyRepository.getPropertyTypes()`, `getProperties()`, `getStories()` | `GET /property/types/`, `GET /property/properties/`, `GET /story/public/stories/` |
| **Search** | - | `PropertyRepository.getProperties(search: ...)` | `GET /property/properties/?search=` |
| **Listing Detail** | - | `PropertyRepository.getPropertyDetail()`, `getReviews()` | `GET /property/properties/{guid}`, `GET /property/properties/{guid}/reviews/` |
| **Booking Calendar** | - | `BookingRepository.getPropertyCalendar()` | `GET /booking/properties/{id}/calendar/` |
| **Booking Confirmation** | - | `BookingRepository.createBooking()` | `POST /booking/client/` |
| **Active Bookings** | - | `BookingRepository.getClientBookings()` | `GET /booking/client/` |
| **Booking Detail** | - | `BookingRepository.getBookingDetails()` | `GET /booking/client/{id}/` |
| **Booking History** | - | `BookingRepository.getBookingHistory()` | `GET /booking/client/history/` |
| **Favorites** | - | `FavoritesRepository.getFavorites()`, `saveFavorite()`, `removeFavorite()` | Local storage |
| **Payment Methods** | - | `PaymentRepository.getCards()`, `addCard()`, `verifyCard()`, `deleteCard()` | `GET/POST/DELETE /user/client/cards/` |
| **Support Chat** | - | `SupportRepository.getConversations()`, `getMessages()`, `sendMessage()` | `GET/POST /chat/` |
| **Settings** | - | `AuthRepository.logout()`, `deleteAccount()` | `POST /user/client/logout/`, `DELETE /user/account/` |

## Eski vs Yangi Yondashuv

| Jihat | Eski Loyiha | Yangi Loyiha |
|-------|-------------|--------------|
| **State Management** | Bloc/Cubit + ChangeNotifier | GetX (GetxController) |
| **DI** | get_it + injectable | GetX Bindings |
| **Error Handling** | dartz Either | ApiResult sealed class |
| **HTTP Client** | Dio (manual DI) | Dio (singleton + interceptors) |
| **Storage** | FlutterSecureStorage | FlutterSecureStorage (bir xil) |
| **Architecture** | DataSource → Repository → UseCase → Cubit | API Service → Repository → Controller |
| **Token Refresh** | AuthInterceptor (Completer) | AuthInterceptor (bir xil logika) |

## Asosiy Farqlar

1. **Soddalashtirilgan DI**: `injectable` o'rniga GetX `Bindings` ishlatilgan
2. **UseCase olib tashlandi**: Repository to'g'ridan-to'g'ri Controllerga ulangan (over-engineering oldini olish)
3. **ApiResult**: `dartz` Either o'rniga sodda sealed class
4. **Markaziy Dio**: `DioClient.dio` orqali bitta instance barcha joyda ishlatiladi
5. **Token refresh**: Interceptor ichida `Completer` bilan parallel so'rovlar uchun qo'llab-quvvatlash
