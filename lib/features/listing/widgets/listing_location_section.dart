import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart' as latlong;
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';

class ListingLocationSection extends StatelessWidget {
  final Property property;

  const ListingLocationSection({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    final location = property.location;
    final lat = double.tryParse(location?.latitude ?? '');
    final lng = double.tryParse(location?.longitude ?? '');

    if (lat == null || lng == null) {
      return _AddressOnlySection(property: property);
    }

    final point = latlong.LatLng(lat, lng);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'location_on_object'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 270,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 15,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://core-renderer-tiles.maps.yandex.net/tiles?l=map&x={x}&y={y}&z={z}&scale=1&lang=ru_RU',
                    userAgentPackageName: 'uz.weel.weelbooking',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 80,
                        height: 80,
                        child: Icon(
                          Icons.location_on,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _LocationAddress(property: property),
        ],
      ),
    );
  }
}

/// Faqat manzil ko'rsatiladigan variant (koordinatalar yo'q holatda)
class _AddressOnlySection extends StatelessWidget {
  final Property property;

  const _AddressOnlySection({required this.property});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'location_on_object'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.6,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          _LocationAddress(property: property),
        ],
      ),
    );
  }
}

/// Manzil qatori — DRY prinsipi uchun ajratildi
class _LocationAddress extends StatelessWidget {
  final Property property;

  const _LocationAddress({required this.property});

  @override
  Widget build(BuildContext context) {
    final location = property.location;
    final address = location?.fullAddress.isNotEmpty == true
        ? location!.fullAddress
        : property.displayLocation;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(
            Icons.location_on_outlined,
            size: 16,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            address,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              letterSpacing: -0.32,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
