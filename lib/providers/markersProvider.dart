import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final markerSetNotifierProvider =
    StateNotifierProvider<MarkerStateNotifier, Set<Marker>>(
  (ref) => MarkerStateNotifier(),
);

class MarkerStateNotifier extends StateNotifier<Set<Marker>> {
  MarkerStateNotifier() : super({});

  void addMarker(Marker marker) {
    state = {...state, marker};
  }

  // if driver check if he is in the set if he is then throw in the set or else not kept in the new set
  // if he is not driver then throw in the ser
  // flitering out the contians in the set

  void updateOrAddMarkerDriver({
    required String markerId,
    required LatLng newPosition,
    required BitmapDescriptor icon,
    required double bearing,
  }) {
    bool exists = false;

    final updatedMarkers = state.map((marker) {
      if (marker.markerId.value == markerId) {
        exists = true;
        return marker.copyWith(
            positionParam: newPosition, rotationParam: bearing);
      }
      return marker;
    }).toSet();

    if (!exists) {
      final newMarker = Marker(
        markerId: MarkerId(markerId),
        position: newPosition,
        icon: icon,
        rotation: bearing,
        flat: true,
        anchor: const Offset(0.5, 0.5),
        infoWindow: const InfoWindow(title: "Driver Location"),
      );
      updatedMarkers.add(newMarker);
    }

    state = updatedMarkers;
  }

  void addMarkerIfNotExists(Marker marker) {
    if (!state
        .any((existingMarker) => existingMarker.markerId == marker.markerId)) {
      state = {...state, marker}; // Add the marker if it doesn't exist
    }
  }

  void removeMarkerWhere(String input) {
    state = state.where((element) {
      return !element.markerId.value.contains(input);
    }).toSet();
  }

// we are using set here just make sure
  void removeMarkersWhere(Set<String> currentDriverIds) {
    state = state.where((marker) {
      // Preserve non-driver markers and drivers in the current list
      if (!marker.markerId.value.startsWith('driver_')) return true;
      return currentDriverIds.contains(marker.markerId.value);
    }).toSet();
  }

  void clearMarkers() {
    state = <Marker>{};
  }
}
