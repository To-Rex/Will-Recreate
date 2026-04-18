import 'package:dio/dio.dart';
import '../../core/network/dio_client.dart';
import '../../core/utils/safe_parse.dart';
import '../models/property_model.dart';

/// Property (mulk) API endpointlari bilan ishlash
class PropertyApiService {
  final Dio _dio = DioClient.dio;

  /// Property turlarini olish (kategoriyalar)
  Future<List<CategoryModel>> getPropertyTypes() async {
    final res = await _dio.get('/property/types/');
    return safeListParse(res.data, CategoryModel.fromJson);
  }

  /// Property ro'yxatini olish (filter, search bilan)
  Future<List<Property>> getProperties(Map<String, dynamic> params) async {
    final res = await _dio.get('/property/properties/', queryParameters: params);
    return safeListParse(res.data, Property.fromJson);
  }

  /// Property detail olish
  Future<Map<String, dynamic>> getPropertyDetail(String guid) async {
    final res = await _dio.get('/property/properties/$guid');
    return safeMap(res.data);
  }

  /// Property xizmatlari (services)
  Future<List<PropertyService>> getPropertyServices(String propertyTypeId) async {
    final res = await _dio.get(
      '/property/services/',
      queryParameters: {'property_type': propertyTypeId},
    );
    return safeListParse(res.data, PropertyService.fromJson);
  }

  /// Storylarni olish
  Future<List<StoryModel>> getStories(String propertyTypeId) async {
    final res = await _dio.get(
      '/story/public/stories/',
      queryParameters: {'property_type': propertyTypeId},
    );
    return safeListParse(res.data, StoryModel.fromJson);
  }

  /// Story media ko'rilganini belgilash
  Future<void> trackMediaView(String storyId, String mediaId) async {
    await _dio.get('/story/stories/$storyId/$mediaId/');
  }

  /// Reviewlarni olish
  Future<List<ReviewModel>> getReviews(String propertyGuid) async {
    final res = await _dio.get('/property/properties/$propertyGuid/reviews/');
    return safeListParse(res.data, ReviewModel.fromJson);
  }

  /// Review yozish
  Future<void> postReview({
    required String propertyGuid,
    required int rating,
    required String comment,
  }) async {
    await _dio.post(
      '/property/properties/$propertyGuid/reviews/',
      data: {'rating': rating, 'comment': comment},
    );
  }

  /// Tavsiya etilgan propertylar
  Future<List<Property>> getRecommendations({String? propertyTypeId, int? limit}) async {
    final params = <String, dynamic>{};
    if (propertyTypeId != null) params['property_type'] = propertyTypeId;
    if (limit != null) params['limit'] = limit;

    final res = await _dio.get('/property/recommendations/', queryParameters: params);
    return safeListParse(res.data, Property.fromJson);
  }
}
