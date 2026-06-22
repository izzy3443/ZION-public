import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';

final userLocationProvider = FutureProvider<LatLng>((ref) async {
  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      ),
    );

    return LatLng(position.latitude, position.longitude);
  } catch (e) {
    if (Location_permission_Status == false) {
      throw "Enable GPS for better usability";
    } else {
      throw "Weak GPS signal";
    }
  }
});
