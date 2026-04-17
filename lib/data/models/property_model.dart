class PropertyImage {
  final String guid;
  final int order;
  final String imageUrl;

  PropertyImage({required this.guid, required this.order, required this.imageUrl});
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
}

class PropertyRoom {
  final int bedrooms;
  final int beds;
  final int bathrooms;
  final int maxGuests;

  PropertyRoom({required this.bedrooms, required this.beds, required this.bathrooms, required this.maxGuests});
}

class PropertyService {
  final String guid;
  final String title;
  final String iconUrl;

  PropertyService({required this.guid, required this.title, this.iconUrl = ''});
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
}

class CategoryModel {
  final String guid;
  final String title;
  final String iconUrl;

  CategoryModel({required this.guid, required this.title, this.iconUrl = ''});
}

class StoryMedia {
  final String mediaUrl;
  final bool isImage;

  StoryMedia({required this.mediaUrl, this.isImage = true});
}

class StoryModel {
  final String guid;
  final Property property;
  final List<StoryMedia> media;
  final bool isWatched;

  StoryModel({required this.guid, required this.property, this.media = const [], this.isWatched = false});
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
}

class CardModel {
  final String guid;
  final String cardNumber;
  final String expiryDate;
  final String cardHolder;
  final String type;

  CardModel({
    required this.guid,
    required this.cardNumber,
    required this.expiryDate,
    this.cardHolder = '',
    this.type = 'uzcard',
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.id, required this.text, this.isMe = false, required this.time});
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
