import 'package:dio/dio.dart';
import '../../core/network/api_result.dart';
import '../models/property_model.dart';
import '../services/property_api_service.dart';

/// Property repository - API service ni wrap qilib ApiResult qaytaradi
class PropertyRepository {
  final PropertyApiService _apiService = PropertyApiService();

  /// Kategoriyalar (property types)
  Future<ApiResult<List<CategoryModel>>> getPropertyTypes() async {
    try {
      final result = await _apiService.getPropertyTypes();
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Property ro'yxati
  Future<ApiResult<List<Property>>> getProperties({
    String? propertyTypeId,
    String? minPrice,
    String? maxPrice,
    String? currency,
    String? fromDate,
    String? toDate,
    String? search,
    int? adults,
    int? children,
    bool? pets,
    String? ordering,
    List<String>? serviceGuids,
    int? limit,
    int? offset,
  }) async {
    final params = <String, dynamic>{};
    if (propertyTypeId != null) params['property_type'] = propertyTypeId;
    if (minPrice != null) params['min_price'] = minPrice;
    if (maxPrice != null) params['max_price'] = maxPrice;
    if ((minPrice != null || maxPrice != null) && currency != null) {
      params['currency'] = currency;
    }
    if (fromDate != null) params['from_date'] = fromDate;
    if (toDate != null) params['to_date'] = toDate;
    if (search != null) params['search'] = search;
    if (adults != null) params['adults'] = adults;
    if (children != null) params['children'] = children;
    if (pets != null) params['pets'] = pets;
    if (ordering != null) params['ordering'] = ordering;
    if (serviceGuids != null && serviceGuids.isNotEmpty) {
      params['property_services'] = serviceGuids;
    }
    if (limit != null) params['limit'] = limit;
    if (offset != null) params['offset'] = offset;

    try {
      final result = await _apiService.getProperties(params);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Property detail
  Future<ApiResult<Property>> getPropertyDetail(String guid) async {
    try {
      final data = await _apiService.getPropertyDetail(guid);
      return ApiSuccess(Property.fromJson(data));
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Property xizmatlari
  Future<ApiResult<List<PropertyService>>> getPropertyServices(
    String propertyTypeId,
  ) async {
    try {
      final result = await _apiService.getPropertyServices(propertyTypeId);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Storylar
  Future<ApiResult<List<StoryModel>>> getStories(String propertyTypeId) async {
    try {
      final result = await _apiService.getStories(propertyTypeId);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Story media ko'rilganini belgilash
  Future<ApiResult<void>> trackMediaView(String storyId, String mediaId) async {
    try {
      await _apiService.trackMediaView(storyId, mediaId);
      return const ApiSuccess(null);
    } on DioException catch (_) {
      // Silent fail - tracking muhim emas
      return const ApiSuccess(null);
    }
  }

  /// Reviewlar
  Future<ApiResult<List<ReviewModel>>> getReviews(String propertyGuid) async {
    try {
      final result = await _apiService.getReviews(propertyGuid);
      return ApiSuccess(result);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }

  /// Review yozish
  Future<ApiResult<void>> postReview({
    required String propertyGuid,
    required int rating,
    required String comment,
  }) async {
    try {
      await _apiService.postReview(
        propertyGuid: propertyGuid,
        rating: rating,
        comment: comment,
      );
      return const ApiSuccess(null);
    } on DioException catch (e) {
      return ApiFailure(mapDioError(e));
    } catch (e) {
      return ApiFailure(e.toString());
    }
  }
}
