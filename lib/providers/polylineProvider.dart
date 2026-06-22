import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final StateProvider<Set<Polyline>> polylinesSetProvider =
    StateProvider((ref) => {});

final polylinesSetNotifierProvider =
    StateNotifierProvider<PolylinesNotifier, Set<Polyline>>((ref) {
  return PolylinesNotifier();
});

class PolylinesNotifier extends StateNotifier<Set<Polyline>> {
  PolylinesNotifier() : super({});

  void addPolyline(Polyline polyline) {
    state = {...state, polyline};
  }

  void replacePolyline(
    List<LatLng> polylinecordinates,
    Color color,
  ) {
    state = {
      Polyline(
        polylineId: const PolylineId("polylineID"),
        color: color,
        points: polylinecordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.squareCap,
        geodesic: true,
      )
    };
  }

  // Optional: Clear all polylines
  void clearPolylines() {
    state = {}; // Reset state to an empty set
  }
}
