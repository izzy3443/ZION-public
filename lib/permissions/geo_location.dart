import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> requestLocationPermission() async {
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever ||
      permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    // if denyed forever then the pop up will never show up
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Location_permission_Status = false;

      return;
    }
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      Location_permission_Status = true;

      return;
    }
  } else if (permission == LocationPermission.always ||
      permission == LocationPermission.whileInUse) {
    Location_permission_Status = true;

    return;
  }
}
