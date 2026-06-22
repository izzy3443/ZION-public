import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion3/global/paths.dart';
import 'package:zion3/quick_functions/bit_image.dart';

BitmapDescriptor? pickupIcon;
BitmapDescriptor? dropoffIcon;
BitmapDescriptor? carTopIcon;
BitmapDescriptor? autoTopIcon;

BitmapDescriptor? getVehicleIcon(String vehicleType) {
  switch (vehicleType.toLowerCase()) {
    case "car":
      return carTopIcon;
    case "auto":
      return autoTopIcon;
    default:
      return carTopIcon; // fallback if unknown
  }
}

Future<void> loadCustomMarkers() async {
  pickupIcon =
      await createResizedBitmapDescriptor(assetPath: red_marker, height: 110.h);
  dropoffIcon = await createResizedBitmapDescriptor(
      assetPath: green_marker, height: 110.h);
  carTopIcon =
      await createResizedBitmapDescriptor(assetPath: car_top, height: 110.0.h);
  autoTopIcon =
      await createResizedBitmapDescriptor(assetPath: auto_top, height: 110.h);
}
