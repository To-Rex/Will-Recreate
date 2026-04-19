import 'package:flutter/material.dart';

/// Service nomiga qarab mos IconData qaytaradi
IconData getServiceIcon(String title) {
  final lower = title.toLowerCase();
  if (lower.contains('парковк') || lower.contains('avtoturargoh') || lower.contains('parking')) {
    return Icons.local_parking;
  }
  if (lower.contains('бассейн') || lower.contains('basseyn') || lower.contains('pool')) {
    return Icons.pool;
  }
  if (lower.contains('мангал') || lower.contains('mangal') || lower.contains('grill')) {
    return Icons.local_fire_department;
  }
  if (lower.contains('кондиционер') || lower.contains('konditsioner') || lower.contains('ac')) {
    return Icons.ac_unit;
  }
  if (lower.contains('саун') || lower.contains('бан') || lower.contains('sauna')) {
    return Icons.hot_tub;
  }
  if (lower.contains('wifi') || lower.contains('wi-fi') || lower.contains('интернет')) {
    return Icons.wifi;
  }
  if (lower.contains('кухн') || lower.contains('oshxona') || lower.contains('kitchen')) {
    return Icons.kitchen;
  }
  if (lower.contains('телевизор') || lower.contains('tv')) {
    return Icons.tv;
  }
  if (lower.contains('nonushta') || lower.contains('breakfast')) {
    return Icons.free_breakfast;
  }
  return Icons.check_circle_outline;
}
