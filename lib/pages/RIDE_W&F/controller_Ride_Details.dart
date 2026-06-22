import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:riverpod/riverpod.dart';

import 'package:zion3/features&calls/directions_calls.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/screen_LandingPage.dart';

import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/address_model.dart';

import 'package:zion3/pages/PRICE_PAGE_W&F/utils_Price_Page.dart';
import 'package:zion3/pages/RIDE_W&F/provider_Ride_Details.dart';

import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';
import 'package:zion3/pages/custom_marker.dart';

import 'package:zion3/providers/markersProvider.dart';
import 'package:zion3/providers/polylineProvider.dart';
import 'package:zion3/quick_functions/bounds_homepage.dart';
import 'package:zion3/theme.dart';

final tripStatusDisplay = StateProvider((state) => "");
String? existingTripID;
String currentTripID = "";
StreamSubscription<DocumentSnapshot>? tripStreamSubscription;
LatLng? previousDriverPosition;

enum TripEvent {
  cancelled,
  paid,
  driverEnRoute,
}

final tripRuntimeControllerProvider = Provider<TripRuntimeController>((ref) {
  final controller = TripRuntimeController(ref);

  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
});

class MarkerIconCache {
  static bool _loaded = false;

  static Future<void> ensureLoaded() async {
    if (_loaded) return;

    await loadCustomMarkers();
    _loaded = true;
  }
}

class TripRuntimeController {
  TripRuntimeController(this.ref);

  final Ref ref;
  StreamSubscription<DocumentSnapshot>? _subscription;

  LatLng? _previousDriverPosition;
  bool _cameraAnimated = false;
  final List<LatLng> _polyline = [];

  // void listen(String tripId, BuildContext context) {
  //   _subscription?.cancel();

  //   final doc = FirebaseFirestore.instance.collection("trip_req").doc(tripId);

  //   _subscription = doc.snapshots().listen(
  //     (snapshot) {
  //       _onSnapshot(snapshot, context);
  //     },
  //     onError: (e) {},
  //   );
  // }

  void listen(
    String tripId, {
    required void Function(TripEvent event) onEvent,
  }) {
    _subscription?.cancel();
    ref.read(TripDetailsLoaded.notifier).state = false;

    final doc = FirebaseFirestore.instance.collection("trip_req").doc(tripId);
    print("Listening to trip updates for trip ID: $tripId");
    print("Current trip ID in controller: $currentTripID");
    print(
        " so the trip id ABOVE IS LIKE THE ONE WE ARE LISTENING TO THE ONE WHICH IS SNAPSHOT ONE SO IT SHOULD NOT BE SAME AS BEFORE");
    _subscription = doc.snapshots().listen(
      (snapshot) async {
        final event = await _onSnapshot(snapshot);
        if (event != null) {
          onEvent(event);
        }
      },
      onError: (e) {
        debugPrint("Trip listener error: $e");
      },
    );
  }

  Future<TripEvent?> _onSnapshot(
    DocumentSnapshot snapshot,
  ) async {
    if (!snapshot.exists) {
      return null;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    final status = data["Status"];

    if (status == null) {
      return null;
    }

    if (status == "cancelledByDriver") {
      // _handleCancelled(context);
      return TripEvent.cancelled;
    }

    if (data["DriverLocation"] == null) {
      return null;
    }

    try {
      await _hydrateDriverAndTripData(data);
    } catch (e) {
      return TripEvent.driverEnRoute;
    }

    switch (status) {
      case "accepted":
        await _routeToPickup(data);
        break;

      case "picked_up":
        await _routeToDropoff(data);
        ref.read(isCancelEnabled.notifier).state = false;
        break;

      case "arrived":
        ref.read(tripStatusDisplay.notifier).state = "Driver has arrived";
        break;

      case "ended":
        ref.read(fairAmountDisplayProvider.notifier).state = data["FareAmount"];
        break;

      case "Paid":
        return TripEvent.paid;

      default:
        break;
    }
    return null;
  }

  Future<void> _routeToPickup(Map<String, dynamic> data) async {
    await _updateMap(
      start: _driverLatLng(data),
      end: _pickupLatLng(data),
      statusText: "Arriving in",
    );
  }

  Future<void> _routeToDropoff(Map<String, dynamic> data) async {
    await _updateMap(
      start: _driverLatLng(data),
      end: _dropoffLatLng(data),
      statusText: "Arriving in",
    );
  }

  Future<void> _updateMap({
    required LatLng start,
    required LatLng end,
    required String statusText,
  }) async {
    await MarkerIconCache.ensureLoaded();

    final direction = await getDirectionDetailsFromApi(start, end);

    _polyline
      ..clear()
      ..addAll(
        PolylinePoints()
            .decodePolyline(direction.encodedPoints!)
            .map((e) => LatLng(e.latitude, e.longitude)),
      );

    ref
        .read(polylinesSetNotifierProvider.notifier)
        .replacePolyline(_polyline, Themes.black1X);

    final vecType = ref.read(driverTripInfoProvider)?.vehicleType ?? "Car";
    final vecIcon = getVehicleIcon(vecType)!;

    double bearing = 0;
    if (_previousDriverPosition != null && _previousDriverPosition != start) {
      bearing = getBearing(_previousDriverPosition!, start);
    }
    _previousDriverPosition = start;

    final markerNotifier = ref.read(markerSetNotifierProvider.notifier);

    markerNotifier.updateOrAddMarkerDriver(
      markerId: "driver_marker",
      newPosition: start,
      icon: vecIcon,
      bearing: bearing,
    );

    final destMarker = Marker(
      markerId: const MarkerId("destMarker"),
      position: end,
      icon: dropoffIcon ?? BitmapDescriptor.defaultMarker,
    );

    markerNotifier.removeMarkerWhere("destMarker");
    markerNotifier.addMarker(destMarker);

    if (!_cameraAnimated) {
      _cameraAnimated = true;

      final controller = ref.read(googleMapControllerProvider);
      controller?.animateCamera(
        CameraUpdate.newLatLngBounds(
          boundCameraUpdate(
            start.latitude,
            start.longitude,
            end.latitude,
            end.longitude,
          ),
          70,
        ),
      );
    }

    ref.read(tripStatusDisplay.notifier).state =
        "$statusText ${direction.durationTextString}";
  }

  LatLng _driverLatLng(Map<String, dynamic> d) =>
      LatLng(d["DriverLocation"]["latitude"], d["DriverLocation"]["longitude"]);

  LatLng _pickupLatLng(Map<String, dynamic> d) =>
      LatLng(d["pickup_latlng"]["latitude"], d["pickup_latlng"]["longitude"]);

  LatLng _dropoffLatLng(Map<String, dynamic> d) =>
      LatLng(d["dropoff_latlng"]["latitude"], d["dropoff_latlng"]["longitude"]);

  Future<void> _hydrateDriverAndTripData(
    Map<String, dynamic> snapshot,
  ) async {
    if (ref.read(TripDetailsLoaded)) {
      return;
    }

    try {
      final driverId = snapshot["DriverId"];
      if (driverId == null || driverId == "waiting") {
        return;
      }

      final driverDoc = await FirebaseFirestore.instance
          .collection("drivers")
          .doc(driverId)
          .get();

      final driverData = driverDoc.data();
      if (driverData == null) {
        return;
      }

      ref
          .read(driverTripInfoProvider.notifier)
          .setDriverDetailsFromMap(driverData);

      ref.read(driverTripInfoProvider.notifier).setFareAndOtp(
            fareAmount: snapshot["FareAmount"]?.toString() ?? "",
            otp: snapshot["Otp"] ?? "",
          );
      print("Driver and trip data hydrated in provider");
      print(ref.read(driverTripInfoProvider)?.toMap());

      ref.read(addressProvider.notifier).add_pickup(
            AddressModel(
              Place_name: snapshot["pickup_address"],
              lat: snapshot["pickup_latlng"]["latitude"],
              long: snapshot["pickup_latlng"]["longitude"],
            ),
          );

      ref.read(addressProvider.notifier).add_dropoff(
            AddressModel(
              Place_name: snapshot["dropoff_address"],
              lat: snapshot["dropoff_latlng"]["latitude"],
              long: snapshot["dropoff_latlng"]["longitude"],
            ),
          );

      ref.read(fairAmountDisplayProvider.notifier).state =
          snapshot["FareAmount"];

      ref.read(RidesubDetailsLoading.notifier).state = false;
      ref.read(TripDetailsLoaded.notifier).state = true;
    } catch (e) {
      rethrow;
      // return TripEvent.driverEnRoute;
      // showCustomSnackBar(
      //   context,
      //   "Slow internet. Driver is on the way",
      // );
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
