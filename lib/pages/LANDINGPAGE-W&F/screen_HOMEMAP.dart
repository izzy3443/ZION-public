import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/features&calls/api_geo.dart';

import 'package:zion3/global/paths.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/screen_LandingPage.dart';
import 'package:zion3/main.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/controller_LandingPage.dart';
import 'package:zion3/pages/HOMEPAGE_W&F/provider_location.dart';

import 'package:zion3/pages/START_DEST_W&F/provider_CustomMarker.dart';
import 'package:zion3/providers/markersProvider.dart';
import 'package:zion3/providers/polylineProvider.dart';

class HomeMap extends ConsumerStatefulWidget {
  const HomeMap({super.key});

  @override
  ConsumerState<HomeMap> createState() => _HomeMapState();
}

class _HomeMapState extends ConsumerState<HomeMap> {
  late GoogleMapController _mapController;
  CameraPosition? lastCustomPosition;

  final API geoLocationInstance = API();

  @override
  void initState() {
    super.initState();
    _initFunctions();
  }

  Future<void> _initFunctions() async {
    try {
      await fetchAndStoreUserData(context, ref);

      await generateNotificationToken(ref);
    } catch (e) {
      if (!mounted) return;

      showCustomSnackBar(
        context,
        "Failed to initialize notifications",
      );
    }
  }

  Future<void> _getCurrentLocationFirst() async {
    try {
      final position = await ref.read(userLocationProvider.future);

      if (!mounted) return;

      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: position, zoom: 15),
        ),
      );

      final locationModel =
          await geoLocationInstance.convertGeoToHumanReadable(position);

      if (!mounted) return;

      ref.read(addressProvider.notifier).add_pickup(locationModel!);
      ref.read(addressProvider.notifier).Location(locationModel);
    } catch (e) {
      if (!mounted) return;

      showCustomSnackBar(
        context,
        "Something Went Wrong fetching current location",
      );
    }
  }

  Future<void> _onCameraIdle() async {
    final panelIndex = ref.read(panelIndexProvider);
    print(
        " READ THIS AND CONFIUEM THE PANEL NUMBER BACAUSE WE NEED TO CONFIEMMMMMM");

    if (panelIndex != 4) return;

    final center = lastCustomPosition?.target;
    if (center == null) return;

    ref.read(isLoadingProvider_customMarker.notifier).state = true;

    try {
      final model = await geoLocationInstance.convertGeoToHumanReadable(center);

      ref.read(MarkerlocationModelProvider.notifier).state = model;
      ref.read(isLoadingProvider_customMarker.notifier).state = false;
    } catch (e) {
      showCustomSnackBar(
        context,
        e.toString(),
      );
    }
  }

  void _onCameraMove(CameraPosition position) {
    if (ref.read(panelIndexProvider) != 4) return; // 🔒 HARD GUARD
    ref.read(isLoadingProvider_customMarker.notifier).state = true;
    lastCustomPosition = position;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return GoogleMap(
      style: isDark ? darkMapStyle : lightMapStyle,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      polylines: ref.watch(polylinesSetNotifierProvider),
      markers: ref.watch(markerSetNotifierProvider),
      onCameraMove: _onCameraMove,
      onCameraIdle: _onCameraIdle,
      initialCameraPosition:
          const CameraPosition(target: LatLng(0, 0), zoom: 2),
      onMapCreated: (controller) {
        _mapController = controller;
        ref.read(googleMapControllerProvider.notifier).state = controller;

        _getCurrentLocationFirst();
      },
    );
  }
}
