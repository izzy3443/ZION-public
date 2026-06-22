import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion3/global/paths.dart';

class RideOption {
  final String mode;
  final String name;
  final String imagePath; // image asset instead of IconData
  final double price;
  final String duration;
  final int capacity;
  final String variant;

  RideOption({
    required this.mode,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.duration,
    required this.capacity,
    required this.variant,
  });

  factory RideOption.fromJson(Map<String, dynamic> json) {
    return RideOption(
      mode: json['mode'],
      name: json['name'],
      imagePath: getImagePathFromName(json['iconName']),
      price: (json['price'] as num).toDouble(),
      duration: json['duration'],
      capacity: json['capacity'],
      variant: json['variant'],
    );
  }

  static String getImagePathFromName(String iconName) {
    switch (iconName) {
      case 'airport_shuttle': // auto
        return auto_front2;
      case 'two_wheeler':
        return auto_top;
      case 'directions_car':
        return car_front;
      default:
        return 'assets/images/default_vehicle.png';
    }
  }
}

double getBearing(LatLng from, LatLng to) {
  final double lat1 = from.latitude * (pi / 180);
  final double lon1 = from.longitude * (pi / 180);
  final double lat2 = to.latitude * (pi / 180);
  final double lon2 = to.longitude * (pi / 180);

  final double dLon = lon2 - lon1;
  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  final bearingRad = atan2(y, x);
  final bearingDeg = (bearingRad * 180 / pi + 360) % 360;
  return bearingDeg;
}
