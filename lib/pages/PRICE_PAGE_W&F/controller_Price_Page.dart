import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:zion3/features&calls/online_drivers.storage.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/models/directions_model.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/screen_LandingPage.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/utils_Price_Page.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/provider_Price_Page.dart';
import 'package:zion3/pages/custom_marker.dart';
import 'package:zion3/providers/markersProvider.dart';
import 'package:zion3/providers/polylineProvider.dart';

import 'package:zion3/quick_functions/bounds_homepage.dart';
import 'package:zion3/features&calls/online_drivers.storage.dart'
    as driversStorage;
import 'package:zion3/theme.dart';

late List<RideOption> rideOptions;

enum RouteSetupFailure {
  pickupOrDropMissing,
  unknown,
}

class PricePageService {
  Map<String, LatLng> previousDriverPositions = {};
  StreamSubscription? _driverStreamSubscription;

  // Future<void> setupRouteAndFindDrivers({
  //   required WidgetRef ref,
  // }) async {
  //   await setupAddressesAndRetrieveRoute(ref);
  //   findNearbyDrivers(ref);
  // }

  Future<void> setupRouteAndFindDrivers({
    required WidgetRef ref,
  }) async {
    await setupAddressesAndRetrieveRoute(ref);
    findNearbyDrivers(ref);
  }

  void disposeResources() {
    _driverStreamSubscription?.cancel();
    _driverStreamSubscription = null;
  }

  Future<void> setupAddressesAndRetrieveRoute(WidgetRef ref) async {
    final addressState = ref.read(addressProvider);
    final pickupLoc = addressState.pickup;
    final destLoc = addressState.dropoff;

    if (pickupLoc == null || destLoc == null) {
      throw RouteSetupFailure.pickupOrDropMissing;
    }

    try {
      await retrieveDirectionsAndUpdateMap(
        ref,
        pickupLoc,
        destLoc,
      );
    } catch (e) {
      rethrow; // 🔥 IMPORTANT → propagate
    }
  }

  // Future<void> retrieveDirectionsAndUpdateMap(
  //   WidgetRef ref,
  //   AddressModel pickupLoc,
  //   AddressModel destLoc,
  // ) async {
  //   try {
  //     final callable = FirebaseFunctions.instance
  //         .httpsCallable('rideOptionsAndAddressModel');

  //     final response = await callable.call({
  //       'origin': {
  //         'lat': pickupLoc.lat,
  //         'lng': pickupLoc.long,
  //       },
  //       'destination': {
  //         'lat': destLoc.lat,
  //         'lng': destLoc.long,
  //       },
  //     });

  //     final data = response.data;

  //     final directionModel = DirectionsModel.fromJson(data['directions']);

  //     final rideOptionsJson = (data['rideOptions'] as List)
  //         .map((e) => Map<String, dynamic>.from(e))
  //         .toList();

  //     rideOptions = rideOptionsJson.map(RideOption.fromJson).toList();

  //     ref.read(selectedRideProvider.notifier).update((_) => rideOptions[1]);

  //     await updateMapVisuals(
  //       ref,
  //       pickupLoc,
  //       destLoc,
  //       LatLng(pickupLoc.lat!, pickupLoc.long!),
  //       LatLng(destLoc.lat!, destLoc.long!),
  //       directionModel,
  //     );
  //   } catch (e) {
  //     throw RouteSetupFailure.unknown;
  //   }
  // }

  Future<void> retrieveDirectionsAndUpdateMap(
    WidgetRef ref,
    AddressModel pickupLoc,
    AddressModel destLoc,
  ) async {
    final callable =
        FirebaseFunctions.instance.httpsCallable('rideOptionsAndAddressModel');

    try {
      final response = await callable.call({
        'origin': {
          'lat': pickupLoc.lat,
          'lng': pickupLoc.long,
        },
        'destination': {
          'lat': destLoc.lat,
          'lng': destLoc.long,
        },
      });

      final data = response.data;

      final directionModel = DirectionsModel.fromJson(data['directions']);

      final rideOptionsJson = (data['rideOptions'] as List)
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      rideOptions = rideOptionsJson.map(RideOption.fromJson).toList();

      ref.read(selectedRideProvider.notifier).update((_) => rideOptions[1]);

      await updateMapVisuals(
        ref,
        pickupLoc,
        destLoc,
        LatLng(pickupLoc.lat!, pickupLoc.long!),
        LatLng(destLoc.lat!, destLoc.long!),
        directionModel,
      );
    } on FirebaseFunctionsException catch (e) {
      throw e; // 🔥 IMPORTANT → propagate
    } catch (e) {
      throw RouteSetupFailure.unknown;
    }
  }

  Future<void> updateMapVisuals(
      WidgetRef ref,
      AddressModel pickupLoc,
      AddressModel destLoc,
      LatLng pickupGeo,
      LatLng destGeo,
      DirectionsModel directionsData) async {
    // Draw polyline
    drawPolyline(ref, directionsData.encodedPoints!);

    // Update camera bounds
    updateCameraBounds(ref, pickupGeo, destGeo);

    // Add markers
    await addLocationMarkers(ref, pickupLoc, destLoc, pickupGeo, destGeo);
  }

  void drawPolyline(WidgetRef ref, String encodedPoints) {
    final polylineCoordinates = <LatLng>[];

    // Decode polyline points
    final points = PolylinePoints().decodePolyline(encodedPoints);

    // Convert points to LatLng
    for (var point in points) {
      polylineCoordinates.add(LatLng(point.latitude, point.longitude));
    }

    // Update polyline provider
    ref
        .read(polylinesSetNotifierProvider.notifier)
        .replacePolyline(polylineCoordinates, Themes.black1(ref.context));
  }

  void updateCameraBounds(WidgetRef ref, LatLng pickupGeo, LatLng destGeo) {
    final mapController = ref.read(googleMapControllerProvider);
    if (mapController == null) return;
    final bounds = boundCameraUpdate(pickupGeo.latitude, pickupGeo.longitude,
        destGeo.latitude, destGeo.longitude);

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 77));
  }

  Future<void> addLocationMarkers(WidgetRef ref, AddressModel pickupLoc,
      AddressModel destLoc, LatLng pickupGeo, LatLng destGeo) async {
    await loadCustomMarkers();

    // Create markers
    final pickupMarker = Marker(
      markerId: const MarkerId("pickupmarkerID"),
      position: pickupGeo,
      icon: pickupIcon!,
      infoWindow:
          InfoWindow(title: pickupLoc.Place_name, snippet: "Pickup Location"),
    );

    final destMarker = Marker(
      markerId: const MarkerId("destmarkerID"),
      position: destGeo,
      icon: dropoffIcon!,
      infoWindow:
          InfoWindow(title: destLoc.Place_name, snippet: "Drop Location"),
    );

    // Update markers
    final markerNotifier = ref.read(markerSetNotifierProvider.notifier);
    markerNotifier.clearMarkers();
    markerNotifier.addMarker(pickupMarker);
    markerNotifier.addMarker(destMarker);

    // Add circles
    // addLocationCircles(ref, pickupGeo, destGeo);
  }

  void findNearbyDrivers(WidgetRef ref) {
    ref.read(dataFetchingProvider.notifier).update((_) => true);
    final pickup = ref.read(addressProvider).pickup;

    if (pickup == null || pickup.lat == null || pickup.long == null) {
      ref.read(dataFetchingProvider.notifier).update((_) => false);
      return;
    }
    startDriverSearchStream(ref, pickup);
  }

  void startDriverSearchStream(WidgetRef ref, AddressModel pickup) {
    // Create a GeoFirePoint with the pickup location
    final center = GeoFirePoint(GeoPoint(pickup.lat!, pickup.long!));
    const radiusInKm = 5.0;

    final tripRequestCollections = {
      'Bike': "online_bike_driver",
      'Car': "online_car_driver",
      'Auto': "online_auto_driver",
    };

    final selectedMode = ref.read(selectedRideProvider);

    final collectionPath = tripRequestCollections[selectedMode!.mode];

    final collectionRef =
        FirebaseFirestore.instance.collection(collectionPath!);

    // Create geo query stream
    final stream = GeoCollectionReference<Map<String, dynamic>>(collectionRef)
        .subscribeWithin(
      strictMode: true,
      center: center,
      radiusInKm: radiusInKm,
      field: 'geo',
      geopointFrom: (data) =>
          (data['geo'] as Map<String, dynamic>)['geopoint'] as GeoPoint,
    );

    // Listen to stream and update drivers
    _driverStreamSubscription = stream.listen((event) {
      _handleDriverStreamEvent(ref, event, selectedMode.mode, center);
    }, onError: (error) {
      ref.read(dataFetchingProvider.notifier).update((_) => false);
    });
  }

  void _handleDriverStreamEvent(
    WidgetRef ref,
    List<DocumentSnapshot<Map<String, dynamic>>> event,
    String selectedMode,
    GeoFirePoint centerPoint, // pass pickup point here
  ) {
    final centerLat = centerPoint.latitude;
    final centerLng = centerPoint.longitude;

    final filtered = event.where((doc) {
      final tripStatus = doc.data()?['TripStatus'] as String?;
      return tripStatus == null ||
          tripStatus == "NONE" ||
          tripStatus == "cancelled";
    });
    if (filtered.isEmpty) {
      ref.read(noDriverFoundProvider.notifier).update((_) => true);
      ref.read(dataFetchingProvider.notifier).update((_) => false);
      driversStorage.ManageDriversMethods.clear();
      return;
    }

    final sortedDrivers = filtered.map((doc) {
      final geo = doc.data()?['geo']['geopoint'] as GeoPoint;
      final distance = Geolocator.distanceBetween(
          centerLat, centerLng, geo.latitude, geo.longitude);
      return {
        'doc': doc,
        'distance': distance,
      };
    }).toList()
      ..sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));

    // Clear and repopulate the list
    ManageDriversMethods.nearby_drivers_list.clear();

    for (final entry in sortedDrivers) {
      final doc = entry['doc'] as DocumentSnapshot;
      final geo = (doc.data() as Map)['geo']['geopoint'] as GeoPoint;

      ManageDriversMethods.add(doc, geo);
    }

    ref.read(noDriverFoundProvider.notifier).update((_) => false);
    ref.read(dataFetchingProvider.notifier).update((_) => false);

    updateDriverMarkersOnMap(ref, selectedMode);
  }

  void updateDriverMarkersOnMap(WidgetRef ref, String selectedMode) {
    final modeIcon = {
      'Bike': BitmapDescriptor.defaultMarker,
      'Car': carTopIcon,
      'Auto': autoTopIcon,
    };

    final driversList = ManageDriversMethods.nearby_drivers_list;
    final markerNotifier = ref.read(markerSetNotifierProvider.notifier);

    Set<String> currentDriverIds =
        driversList.map((driver) => 'driver_${driver.uid_driver}').toSet();

    // Remove old driver markers not in list
    markerNotifier.removeMarkersWhere(currentDriverIds);

    for (var driver in driversList) {
      final driverId = 'driver_${driver.uid_driver}';
      final currentPos = LatLng(driver.lat_driver, driver.long_driver);
      final previousPos = previousDriverPositions[driverId];

      // Calculate bearing (default 0 if no previous pos)
      final Random random = Random();
      double bearing = random.nextDouble() * 360;
      if (previousPos != null &&
          (previousPos.latitude != currentPos.latitude ||
              previousPos.longitude != currentPos.longitude)) {
        bearing = getBearing(previousPos, currentPos);
      }

      final driverMarker = Marker(
        markerId: MarkerId(driverId),
        position: currentPos,
        icon: modeIcon[selectedMode]!,
        rotation: bearing,
        flat: true,
        anchor: const Offset(0.5, 0.5),
      );

      markerNotifier.addMarkerIfNotExists(driverMarker);

      // Update previous position
      previousDriverPositions[driverId] = currentPos;
    }
  }
}
