import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/features&calls/online_drivers.storage.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/provider_Price_Page.dart';

import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';
import 'package:zion3/providers/markersProvider.dart';

String curretnDriverId = "";
DocumentReference? tripReqRef;
StateProvider<int> RequestingDriverNumber = StateProvider<int>((ref) => 0);

Future<void> createTripRequest(WidgetRef ref) async {
  var pickupLocation = ref.read(addressProvider).pickup;
  var dropoffLocation = ref.read(addressProvider).dropoff;
  var userProvider = ref.read(UserProvider)!;
  String fairAmount = ref.read(fairAmountDisplayProvider);

  tripReqRef = FirebaseFirestore.instance.collection("trip_req").doc();
  final otp = 1000 + Random().nextInt(9000);

  Map<String, dynamic> tripData = {
    "TripId": tripReqRef!.id,
    "DateTime": DateTime.now().toString(),
    "UserId": userProvider.uid,
    "FareAmount": fairAmount,
    "pickup_latlng": {
      "latitude": pickupLocation!.lat,
      "longitude": pickupLocation.long
    },
    "dropoff_latlng": {
      "latitude": dropoffLocation!.lat,
      "longitude": dropoffLocation.long
    },
    "pickup_address": pickupLocation.Place_name,
    "dropoff_address": dropoffLocation.Place_name,
    "DriverId": "waiting",
    "Status": "new",
    "Otp": otp.toString(),
  };

  await tripReqRef!.set(tripData);
}

Future<void> searchDriver(WidgetRef ref) async {
  List<OnlineNearByDrivers> availableDrivers =
      List.from(ManageDriversMethods.nearby_drivers_list);

  if (availableDrivers.isEmpty) {
    ref.read(RequestingDriverNumber.notifier).update((state) => 0);
    ref.read(rideContainerProvider.notifier).update((state) => 2);
    return;
  }

  await findNextAvailableDriver(availableDrivers, ref);
}

Future<void> findNextAvailableDriver(
    List<OnlineNearByDrivers> driversList, WidgetRef ref) async {
  if (driversList.isEmpty) {
    tripReqRef =
        FirebaseFirestore.instance.collection("trip_req").doc(tripReqRef!.id);
    await tripReqRef!.delete();
    ref.read(rideContainerProvider.notifier).update((state) => 2);
    // ref.read(panelIndexProvider.notifier).update((state) => 2);
    return;
  }
  ref.read(RequestingDriverNumber.notifier).update((state) => state + 1);
  var currentDriver = driversList.removeAt(0);
  curretnDriverId = currentDriver.uid_driver.toString();

  await sendNotificationToDriver(
      currentDriver, ref); // Wait for driver response

  if (state_of_app == "requesting") {
    await findNextAvailableDriver(driversList, ref); // Try next driver
  } else {}
}

Future<void> sendNotificationToDriver(
  OnlineNearByDrivers currentDriver,
  WidgetRef ref,
) async {
  final result = await callFunction(
      currentDriver.uid_driver.toString(),
      tripReqRef!.id,
      "${ref.read(UserProvider)!.firstName}.${ref.read(UserProvider)!.lastName} ",
      ref.read(addressProvider).pickup!.Place_name!,
      ref.read(addressProvider).dropoff!.Place_name!,
      ref.read(fairAmountDisplayProvider),
      ref.read(selectedRideProvider)!.duration);

  if (result["status"] == "accepted") {
    state_of_app = "accepted";

    ref.read(markerSetNotifierProvider.notifier).clearMarkers();
    ref.read(RequestingDriverNumber.notifier).update((state) => 0);
    ref.read(rideContainerProvider.notifier).update((state) => 1);
  }
}

Future<Map<String, dynamic>> callFunction(
    String driverId,
    String tripId,
    String passengerName,
    String pickup,
    String dropoff,
    String fairAmount,
    String duration) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('notifyDriverAndWait')
        .call({
      'driverId': driverId,
      'tripId': tripId,
      'passengerName': passengerName,
      'pickup': pickup,
      'dropoff': dropoff,
      'fairAmount': fairAmount,
      'duration': duration, // ✅ include duration
    });
    return result.data as Map<String, dynamic>;
  } catch (e) {
    rethrow;
  }
}

void user_req_cancel() {
  if (state_of_app != "requesting") {
    DocumentReference currentDriverRef =
        FirebaseFirestore.instance.collection("drivers").doc(curretnDriverId);

    currentDriverRef.update({"TripStatus": "cancelled"});
    return;
  }
}
