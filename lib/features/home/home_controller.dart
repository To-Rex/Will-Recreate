import 'package:get/get.dart';
import '../../data/models/property_model.dart';
import '../../data/mock/mock_data.dart';

class HomeController extends GetxController {
  final categories = <CategoryModel>[].obs;
  final properties = <Property>[].obs;
  final stories = <StoryModel>[].obs;
  final selectedCategoryGuid = Rx<String?>(null);
  final isLoading = false.obs;
  final isLoadingProperties = false.obs;
  final isFetchingMore = false.obs;
  final selectedOrder = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadStories();
  }

  void loadCategories() {
    isLoading.value = true;
    categories.value = MockData.categories;
    if (categories.isNotEmpty) {
      selectedCategoryGuid.value = categories.first.guid;
      loadProperties(categories.first.guid);
    }
    isLoading.value = false;
  }

  void loadProperties(String categoryGuid) {
    isLoadingProperties.value = true;
    selectedCategoryGuid.value = categoryGuid;
    final filtered = MockData.properties.where((p) => p.categoryGuid == categoryGuid).toList();
    if (filtered.isEmpty) {
      properties.value = MockData.properties;
    } else {
      properties.value = filtered;
    }
    isLoadingProperties.value = false;
  }

  void loadStories() {
    stories.value = MockData.stories;
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
    // Mock: no pagination
  }

  Future<void> refreshData() async {
    loadCategories();
    loadStories();
  }
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
