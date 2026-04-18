import '../../core/utils/safe_parse.dart';

class PropertyImage {
  final String guid;
  final int order;
  final String imageUrl;

  PropertyImage({required this.guid, required this.order, required this.imageUrl});

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      guid: safeString(json['guid']),
      order: safeInt(json['order'], 1),
      imageUrl: safeString(json['image_url']),
    );
  }

  Map<String, dynamic> toJson() => {
    'guid': guid,
    'order': order,
    'image_url': imageUrl,
  };
}

class PropertyLocation {
  final String latitude;
  final String longitude;
  final String country;
  final String city;
  final String? region;
  final String? district;
  final String? fullAddress;

  PropertyLocation({
    required this.latitude,
    required this.longitude,
    this.country = '',
    this.city = '',
    this.region,
    this.district,
    this.fullAddress,
  });

  factory PropertyLocation.fromJson(Map<String, dynamic> json) {
    // property_location yoki to'g'ridan-to'g'ri maydonlardan parse
    final locJson = json['property_location'];
    if (locJson is Map) {
      return PropertyLocation(
        latitude: safeString(locJson['latitude']),
        longitude: safeString(locJson['longitude']),
        country: safeString(locJson['country']),
        city: safeString(locJson['city']),
        region: _extractTitle(locJson['region']),
        district: _extractTitle(locJson['district']),
      );
    }
    return PropertyLocation(
      latitude: safeString(json['latitude']),
      longitude: safeString(json['longitude']),
      country: safeString(json['country']),
      city: safeString(json['city']),
      region: _extractTitle(json['region']),
      district: _extractTitle(json['district']),
    );
  }

  static String? _extractTitle(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    if (value is Map) {
      final title = value['title'] ?? value['name'];
      if (title is String && title.isNotEmpty) return title;
    }
    return null;
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'country': country,
    'city': city,
    'region': region,
    'district': district,
  };
}

class PropertyRoom {
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final int maxGuests;

  PropertyRoom({required this.bedrooms, required this.beds, required this.bathrooms, required this.maxGuests});

  factory PropertyRoom.fromJson(Map<String, dynamic> json) {
    return PropertyRoom(
      bedrooms: safeInt(json['rooms'], 1),
      beds: safeInt(json['beds'], 1),
      bathrooms: safeInt(json['bathrooms'], 1),
      maxGuests: safeInt(json['guests'], 1),
    );
  }
}

class PropertyService {
  final String guid;
  final String title;
  final String iconUrl;

  PropertyService({required this.guid, required this.title, this.iconUrl = ''});

  factory PropertyService.fromJson(Map<String, dynamic> json) {
    return PropertyService(
      guid: safeString(json['guid']),
      title: safeString(json['title']),
      iconUrl: safeString(json['icon_url']),
    );
  }

  Map<String, dynamic> toJson() => {
    'guid': guid,
    'title': title,
    'icon_url': iconUrl,
  };
}

class Property {
  final String guid;
  final String title;
  final PropertyLocation location;
  final List<PropertyImage> images;
  final double averageRating;
  final int commentCount;
  final String? description;
  final List<PropertyService> services;
  final PropertyRoom? room;
  final bool isAllowedAlcohol;
  final bool isAllowedPets;
  final bool isAllowedCorporate;
  final bool isQuietHours;
  final bool isPopular;
  final String? checkInTime;
  final String? checkOutTime;
  final String propertyTypeGuid;
  final String propertyTypeName;
  final double? price;
  final String? categoryGuid;

  Property({
    required this.guid,
    required this.title,
    required this.location,
    this.images = const [],
    this.averageRating = 0,
    this.commentCount = 0,
    this.description,
    this.services = const [],
    this.room,
    this.isAllowedAlcohol = false,
    this.isAllowedPets = false,
    this.isAllowedCorporate = false,
    this.isQuietHours = true,
    this.isPopular = false,
    this.checkInTime,
    this.checkOutTime,
    this.propertyTypeGuid = '',
    this.propertyTypeName = '',
    this.price,
    this.categoryGuid,
  });

  String get displayLocation {
    final parts = [location.city, location.region, location.district].where((e) => e != null && e.isNotEmpty);
    return parts.isEmpty ? 'Tashkent' : parts.join(', ');
  }

  factory Property.fromJson(Map<String, dynamic> json) {
    // Rasmlarni parse qilish
    List<PropertyImage> parseImages() {
      if (json['img'] is List) {
        final list = json['img'] as List;
        return list.asMap().entries.map((e) {
          if (e.value is String) {
            return PropertyImage(guid: '', order: e.key + 1, imageUrl: e.value);
          }
          return PropertyImage.fromJson(safeMap(e.value));
        }).toList();
      }
      if (json['property_images'] is List) {
        return safeListParse(json['property_images'], PropertyImage.fromJson);
      }
      return [];
    }

    // Xizmatlarni parse qilish
    List<PropertyService> parseServices() {
      if (json['services'] is List) {
        final list = json['services'] as List;
        if (list.every((e) => e is String)) {
          return list.map((e) => PropertyService(guid: e as String, title: '')).toList();
        }
      }
      if (json['property_services'] is List) {
        return safeListParse(json['property_services'], PropertyService.fromJson);
      }
      return [];
    }

    // Xonani parse qilish
    PropertyRoom? parseRoom() {
      if (json['property_room'] is Map) {
        return PropertyRoom.fromJson(safeMap(json['property_room']));
      }
      if (json['rooms'] != null || json['guests'] != null) {
        return PropertyRoom(
          bedrooms: safeInt(json['rooms'], 1),
          beds: safeInt(json['beds'], 1),
          bathrooms: safeInt(json['bathrooms'], 1),
          maxGuests: safeInt(json['guests'], 1),
        );
      }
      return null;
    }

    // Narxni aniqlash
    double? parsePrice() {
      final p = json['price'];
      if (p is num) return p.toDouble();
      if (p is String) return double.tryParse(p);
      // DachaPrice list bo'lishi mumkin
      if (p is List && p.isNotEmpty) {
        final first = p.first;
        if (first is Map) {
          final working = safeDouble(first['price_on_working_days']);
          return working > 0 ? working : null;
        }
      }
      return null;
    }

    // property_type maydoni
    String ptGuid = '';
    String ptName = '';
    if (json['property_type'] is Map) {
      final pt = safeMap(json['property_type']);
      ptGuid = safeString(pt['guid']);
      ptName = safeString(pt['title']);
    } else if (json['property_type'] is String) {
      ptGuid = json['property_type'];
    }

    return Property(
      guid: safeString(json['guid']),
      title: safeString(json['title']),
      location: PropertyLocation.fromJson(json),
      images: parseImages(),
      averageRating: safeDouble(json['average_rating']),
      commentCount: safeInt(json['comment_count']),
      description: safeStringOrNull(json['description']),
      services: parseServices(),
      room: parseRoom(),
      isAllowedAlcohol: safeBool(json['is_allowed_alcohol']),
      isAllowedPets: safeBool(json['is_allowed_pets']),
      isAllowedCorporate: safeBool(json['is_allowed_corporate']),
      isQuietHours: safeBool(json['is_quiet_hours'], true),
      checkInTime: safeStringOrNull(json['check_in']),
      checkOutTime: safeStringOrNull(json['check_out']),
      propertyTypeGuid: ptGuid,
      propertyTypeName: ptName,
      price: parsePrice(),
    );
  }

  Map<String, dynamic> toJson() => {
    'guid': guid,
    'title': title,
    'property_location': location.toJson(),
    'property_images': images.map((e) => e.toJson()).toList(),
    'average_rating': averageRating,
    'comment_count': commentCount,
    'description': description,
    'property_services': services.map((e) => e.toJson()).toList(),
    'property_room': room != null
        ? {'rooms': room!.bedrooms, 'beds': room!.beds, 'bathrooms': room!.bathrooms, 'guests': room!.maxGuests}
        : null,
    'is_allowed_alcohol': isAllowedAlcohol,
    'is_allowed_pets': isAllowedPets,
    'is_allowed_corporate': isAllowedCorporate,
    'is_quiet_hours': isQuietHours,
    'check_in': checkInTime,
    'check_out': checkOutTime,
    'property_type': propertyTypeGuid,
  };
}

class CategoryModel {
  final String guid;
  final String title;
  final String iconUrl;

  CategoryModel({required this.guid, required this.title, this.iconUrl = ''});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      guid: safeString(json['guid']),
      title: safeString(json['title']),
      iconUrl: safeString(json['icon_url']),
    );
  }
}

class StoryMedia {
  final String guid;
  final String mediaUrl;
  final bool isImage;

  StoryMedia({this.guid = '', required this.mediaUrl, this.isImage = true});

  factory StoryMedia.fromJson(Map<String, dynamic> json) {
    final type = safeString(json['media_type'], 'image');
    return StoryMedia(
      guid: safeString(json['guid']),
      mediaUrl: safeString(json['media_url']),
      isImage: type.toLowerCase() == 'image',
    );
  }
}

class StoryModel {
  final String guid;
  final Property property;
  final List<StoryMedia> media;
  final bool isWatched;

  StoryModel({required this.guid, required this.property, this.media = const [], this.isWatched = false});

  factory StoryModel.fromJson(Map<String, dynamic> json) {
    // Property ma'lumotlarini ajratib olish
    String propGuid = safeString(json['property_id']);
    String propTitle = safeString(json['property_title']);
    String imageUrl = '';

    if (json['property'] is Map) {
      final prop = safeMap(json['property']);
      propGuid = safeString(prop['guid'], propGuid);
      propTitle = safeString(prop['title'], propTitle);
    }

    if (json['property_image'] is String) {
      imageUrl = json['property_image'];
    } else if (json['property_image_url'] is String) {
      imageUrl = json['property_image_url'];
    }

    // Media parse
    List<StoryMedia> mediaList = [];
    if (json['media'] is List) {
      mediaList = safeListParse(json['media'], StoryMedia.fromJson);
    }

    return StoryModel(
      guid: safeString(json['guid']),
      property: Property(
        guid: propGuid,
        title: propTitle,
        location: PropertyLocation(latitude: '', longitude: ''),
        images: [PropertyImage(guid: '', order: 1, imageUrl: imageUrl)],
      ),
      media: mediaList,
    );
  }
}

class ReviewModel {
  final String guid;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<ReviewModel> replies;

  ReviewModel({
    required this.guid,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.replies = const [],
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // User ismini ajratish
    String name = 'User';
    final userData = json['client'] ?? json['user'];
    if (userData is Map) {
      final userMap = safeMap(userData);
      final first = safeString(userMap['first_name']);
      final last = safeString(userMap['last_name']);
      name = '$first $last'.trim();
      if (name.isEmpty) name = safeString(userMap['username'], 'User');
    }

    return ReviewModel(
      guid: safeString(json['guid']),
      userName: name,
      rating: safeDouble(json['rating']),
      comment: safeString(json['comment']),
      createdAt: safeDateTime(json['created_at']),
    );
  }
}

class ClientBooking {
  final String guid;
  final Property property;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final String status;
  final double? totalPrice;
  final int adults;
  final int children;
  final int babies;
  final String bookingNumber;

  ClientBooking({
    required this.guid,
    required this.property,
    this.checkIn,
    this.checkOut,
    this.status = 'pending',
    this.totalPrice,
    this.adults = 1,
    this.children = 0,
    this.babies = 0,
    this.bookingNumber = '',
  });

  factory ClientBooking.fromJson(Map<String, dynamic> json) {
    // Property parse
    Property? prop;
    if (json['property'] is Map) {
      prop = Property.fromJson(safeMap(json['property']));
    }

    return ClientBooking(
      guid: safeString(json['guid'] ?? json['booking_id']),
      property: prop ?? Property(guid: '', title: '', location: PropertyLocation(latitude: '', longitude: '')),
      checkIn: json['check_in'] != null ? safeDateTime(json['check_in']) : null,
      checkOut: json['check_out'] != null ? safeDateTime(json['check_out']) : null,
      status: safeString(json['status'], 'pending'),
      totalPrice: json['total_amount'] != null ? safeDouble(json['total_amount']) : null,
      adults: safeInt(json['adults'], 1),
      children: safeInt(json['children']),
      babies: safeInt(json['babies']),
      bookingNumber: safeString(json['booking_number']),
    );
  }
}

class CardModel {
  final int id;
  final String guid;
  final String cardNumber;
  final String expiryDate;
  final String cardHolder;
  final String type;

  CardModel({
    this.id = 0,
    this.guid = '',
    required this.cardNumber,
    required this.expiryDate,
    this.cardHolder = '',
    this.type = 'uzcard',
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: safeInt(json['id']),
      guid: safeString(json['guid'] ?? json['cardId']),
      cardNumber: safeString(json['number']),
      expiryDate: safeString(json['expireDate']),
      cardHolder: safeString(json['owner']),
      type: safeString(json['brand'], 'uzcard'),
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.id, required this.text, this.isMe = false, required this.time});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: safeInt(json['id']).toString(),
      text: safeString(json['content']),
      isMe: safeString(json['sender_type']) == 'client',
      time: safeDateTime(json['created_at']),
    );
  }
}

class BookingHistoryModel {
  final String guid;
  final String propertyGuid;
  final String title;
  final String imageUrl;
  final DateTime createdAt;
  final String? category;
  final String? status;
  final String? checkIn;
  final String? checkOut;
  final String? city;
  final String? country;
  final String? location;
  final double? rating;
  final String? bookingNumber;
  final double? price;
  final String? currency;
  final String? partnerName;
  final String? partnerPhone;
  final double? latitude;
  final double? longitude;

  const BookingHistoryModel({
    required this.guid,
    required this.propertyGuid,
    required this.title,
    required this.imageUrl,
    required this.createdAt,
    this.category,
    this.status,
    this.checkIn,
    this.checkOut,
    this.city,
    this.country,
    this.location,
    this.rating,
    this.bookingNumber,
    this.price,
    this.currency,
    this.partnerName,
    this.partnerPhone,
    this.latitude,
    this.longitude,
  });

  factory BookingHistoryModel.fromJson(Map<String, dynamic> json) {
    // Property ma'lumotlari
    String propGuid = '';
    String title = '';
    String imageUrl = '';
    String? city;
    String? country;
    double? lat;
    double? lng;

    if (json['property'] is Map) {
      final prop = safeMap(json['property']);
      propGuid = safeString(prop['guid'] ?? prop['property_id']);
      title = safeString(prop['title'], 'No Title');

      // Image
      if (prop['property_images'] is List && (prop['property_images'] as List).isNotEmpty) {
        final first = (prop['property_images'] as List).first;
        if (first is String) {
          imageUrl = first;
        } else if (first is Map) {
          imageUrl = safeString(first['image_url']);
        }
      }

      // Location
      if (prop['property_location'] is Map) {
        final loc = safeMap(prop['property_location']);
        city = safeStringOrNull(loc['city']);
        country = safeStringOrNull(loc['country']);
        lat = safeDouble(loc['latitude']);
        lng = safeDouble(loc['longitude']);
      }
    }

    // Partner
    String? partnerName;
    String? partnerPhone;
    if (json['partner'] is Map) {
      final partner = safeMap(json['partner']);
      final first = safeString(partner['first_name']);
      final last = safeString(partner['last_name']);
      partnerName = '$first $last'.trim();
      partnerPhone = safeStringOrNull(partner['phone_number']);
    }

    return BookingHistoryModel(
      guid: safeString(json['guid'] ?? json['booking_id']),
      propertyGuid: propGuid,
      title: title,
      imageUrl: imageUrl,
      createdAt: safeDateTime(json['created_at']),
      category: safeStringOrNull(json['property_type']),
      status: safeStringOrNull(json['status']),
      checkIn: safeStringOrNull(json['check_in']),
      checkOut: safeStringOrNull(json['check_out']),
      city: city,
      country: country,
      rating: json['average_rating'] != null ? safeDouble(json['average_rating']) : null,
      bookingNumber: safeStringOrNull(json['booking_number']),
      price: json['total_amount'] != null ? safeDouble(json['total_amount']) : null,
      currency: safeStringOrNull(json['currency']),
      partnerName: partnerName,
      partnerPhone: partnerPhone,
      latitude: lat,
      longitude: lng,
    );
  }

  BookingHistoryModel copyWith({
    String? guid,
    String? propertyGuid,
    String? title,
    String? imageUrl,
    DateTime? createdAt,
    String? category,
    String? status,
    String? checkIn,
    String? checkOut,
    String? city,
    String? country,
    String? location,
    double? rating,
    String? bookingNumber,
    double? price,
    String? currency,
    String? partnerName,
    String? partnerPhone,
    double? latitude,
    double? longitude,
  }) {
    return BookingHistoryModel(
      guid: guid ?? this.guid,
      propertyGuid: propertyGuid ?? this.propertyGuid,
      title: title ?? this.title,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      status: status ?? this.status,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      city: city ?? this.city,
      country: country ?? this.country,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      bookingNumber: bookingNumber ?? this.bookingNumber,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      partnerName: partnerName ?? this.partnerName,
      partnerPhone: partnerPhone ?? this.partnerPhone,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}

/// Auth modellari
class OtpRequestResponse {
  final String detail;
  final String phoneNumber;
  final String expiresIn;

  OtpRequestResponse({required this.detail, required this.phoneNumber, required this.expiresIn});

  factory OtpRequestResponse.fromJson(Map<String, dynamic> json) {
    return OtpRequestResponse(
      detail: safeString(json['detail']),
      phoneNumber: safeString(json['phone_number']),
      expiresIn: safeString(json['expires_in'], '60'),
    );
  }
}

class VerifyResponse {
  final String accessToken;
  final String refreshToken;
  final ClientInfo client;

  VerifyResponse({required this.accessToken, required this.refreshToken, required this.client});

  factory VerifyResponse.fromJson(Map<String, dynamic> json) {
    return VerifyResponse(
      accessToken: safeString(json['access']),
      refreshToken: safeString(json['refresh']),
      client: ClientInfo.fromJson(safeMap(json['client'])),
    );
  }
}

class ClientInfo {
  final String guid;
  final String phoneNumber;
  final String firstName;
  final String lastName;

  ClientInfo({required this.guid, required this.phoneNumber, required this.firstName, required this.lastName});

  String get fullName => '$firstName $lastName'.trim();

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    return ClientInfo(
      guid: safeString(json['guid']),
      phoneNumber: safeString(json['phone_number']),
      firstName: safeString(json['first_name']),
      lastName: safeString(json['last_name']),
    );
  }
}

/// Booking request/response modellari
class BookingRequest {
  final String propertyId;
  final String? cardId;
  final String checkIn;
  final String checkOut;
  final int adults;
  final int children;
  final int babies;

  BookingRequest({
    required this.propertyId,
    this.cardId,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
    required this.babies,
  });

  Map<String, dynamic> toJson() => {
    'property_id': propertyId,
    if (cardId != null) 'card_id': cardId,
    'check_in': checkIn,
    'check_out': checkOut,
    'adults': adults,
    'children': children,
    'babies': babies,
  };
}

class BookingResponse {
  final String id;

  BookingResponse({required this.id});

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final id = json['booking_id'] ?? json['guid'] ?? json['id'];
    return BookingResponse(id: id.toString());
  }
}

/// Kalendar modeli
class CalendarDate {
  final DateTime date;
  final String status;

  CalendarDate({required this.date, required this.status});

  factory CalendarDate.fromJson(Map<String, dynamic> json) {
    return CalendarDate(
      date: safeDateTime(json['date']),
      status: safeString(json['status'], 'available'),
    );
  }

  bool get isAvailable => status == 'available';
  bool get isBooked => status == 'booked';
  bool get isBlocked => status == 'blocked';
  bool get isHeld => status == 'held';
}

/// Kartani qo'shish javobi
class AddCardResponse {
  final String session;

  AddCardResponse({required this.session});

  factory AddCardResponse.fromJson(Map<String, dynamic> json) {
    return AddCardResponse(session: safeString(json['session']));
  }
}
