import 'package:get/get.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/favorites_repository.dart';

class FavoritesController extends GetxController {
  final _isLoading = true.obs;
  final _hasError = false.obs;
  final favorites = <Property>[].obs;
  final _repository = FavoritesRepository();

  bool get isLoading => _isLoading.value;
  bool get hasError => _hasError.value;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    _isLoading.value = true;
    _hasError.value = false;
    try {
      favorites.value = await _repository.getFavorites();
    } catch (e) {
      _hasError.value = true;
    }
    _isLoading.value = false;
  }

  /// Sevimliga qo'shish yoki o'chirish (toggle)
  Future<void> toggleFavorite(Property property) async {
    final isFav = isFavorite(property.guid);
    if (isFav) {
      await _repository.removeFavorite(property.guid);
      favorites.removeWhere((p) => p.guid == property.guid);
    } else {
      await _repository.saveFavorite(property);
      favorites.add(property);
    }
  }

  /// Sevimlidan o'chirish
  Future<void> removeFavorite(String guid) async {
    await _repository.removeFavorite(guid);
    favorites.removeWhere((p) => p.guid == guid);
  }

  /// Sevimlilarda ekanligini tekshirish
  bool isFavorite(String guid) {
    return favorites.any((p) => p.guid == guid);
  }
}

class FavoritesBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<FavoritesController>()) {
      Get.put<FavoritesController>(FavoritesController(), permanent: true);
    }
  }
}
