import 'package:get/get.dart';
import '../../data/models/property_model.dart';
import '../../data/repositories/property_repository.dart';

class HomeController extends GetxController {
  final categories = <CategoryModel>[].obs;
  final properties = <Property>[].obs;
  final stories = <StoryModel>[].obs;
  final selectedCategoryGuid = Rx<String?>(null);
  final isLoading = false.obs;
  final isLoadingProperties = false.obs;
  final isFetchingMore = false.obs;
  final selectedOrder = Rx<String?>(null);
  final errorMessage = Rx<String?>(null);

  final _propertyRepository = PropertyRepository();

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  /// Birinchi yuklanish - kategoriyalar, storylar va propertylar
  Future<void> loadInitialData() async {
    isLoading.value = true;
    errorMessage.value = null;

    // Kategoriyalarni yuklash
    final catResult = await _propertyRepository.getPropertyTypes();
    catResult.when(
      success: (data) => categories.value = data,
      failure: (msg) => errorMessage.value = msg,
    );

    // Birinchi kategoriya bo'yicha propertylarni yuklash
    if (categories.isNotEmpty) {
      selectedCategoryGuid.value = categories.first.guid;
      await _loadProperties(categories.first.guid);
      await _loadStories(categories.first.guid);
    }

    isLoading.value = false;
  }

  /// Propertylarni kategoriya bo'yicha yuklash
  Future<void> _loadProperties(String categoryGuid) async {
    isLoadingProperties.value = true;
    final result = await _propertyRepository.getProperties(
      propertyTypeId: categoryGuid,
    );
    result.when(
      success: (data) => properties.value = data,
      failure: (msg) => errorMessage.value = msg,
    );
    isLoadingProperties.value = false;
  }

  /// Storylarni yuklash
  Future<void> _loadStories(String categoryGuid) async {
    final result = await _propertyRepository.getStories(categoryGuid);
    result.when(
      success: (data) => stories.value = data,
      failure: (_) {}, // Storylar muhim emas, xato ko'rsatmaymiz
    );
  }

  void loadCategories() => loadInitialData();

  void loadProperties(String categoryGuid) {
    if (selectedCategoryGuid.value != categoryGuid) {
      selectedCategoryGuid.value = categoryGuid;
      _loadProperties(categoryGuid);
      _loadStories(categoryGuid);
    }
  }

  void loadStories() {
    if (selectedCategoryGuid.value != null) {
      _loadStories(selectedCategoryGuid.value!);
    }
  }

  void selectCategory(String guid) {
    if (selectedCategoryGuid.value != guid) {
      loadProperties(guid);
    }
  }

  void setOrder(String? order) {
    selectedOrder.value = order;
    if (order != null) {
      final list = List<Property>.from(properties);
      switch (order) {
        case 'expensive':
          list.sort((a, b) => (b.price ?? 0).compareTo(a.price ?? 0));
          break;
        case 'cheap':
          list.sort((a, b) => (a.price ?? 0).compareTo(b.price ?? 0));
          break;
        case 'rating':
          list.sort((a, b) => b.averageRating.compareTo(a.averageRating));
          break;
      }
      properties.value = list;
    }
  }

  void loadMoreProperties() {
    // Pagination keyinroq qo'shiladi
  }

  Future<void> refreshData() async {
    await loadInitialData();
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
