import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/screen_RatingScreen.dart';

import 'package:zion3/auth/E-firestore.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_getStartedPage.dart';

import 'package:zion3/pages/RIDE_W&F/controller_Ride_Details.dart';
import 'package:zion3/pages/RIDE_W&F/provider_Ride_Details.dart';
import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';

Future<void> generateNotificationToken(WidgetRef ref) async {
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    final String? deviceNotificationToken = await firebaseMessaging.getToken();

    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      throw Exception("User not logged in");
    }

    if (deviceNotificationToken == null) {
      throw Exception("FCM token is null");
    }

    await firestore
        .collection("users")
        .doc(currentUser.uid)
        .update({"deviceToken": deviceNotificationToken});

    await firebaseMessaging.subscribeToTopic("users");
  } catch (e) {
    // 🚨 DO NOT TOUCH UI HERE
    rethrow;
  }
}

Future<void> fetchAndStoreUserData(
  BuildContext context,
  WidgetRef ref,
) async {
  print(" this MEANS U WE ARE INSIDE THE FUNCTION fetchAndStoreUserData");
  print(" THIS MEANS U WE ARE INSIDE THE FUNCTION fetchAndStoreUserData");
  print(" THIS MEANS U WE ARE INSIDE THE FUNCTION fetchAndStoreUserData");
  print("WE ARE SUPPOSE TO TRIGGER THE  GET RATING ");

  try {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final refUser = FirebaseFirestore.instance.collection("users").doc(uid);

    final snapshot = await refUser.get();

    // ✅ GUARD AFTER ASYNC GAP
    if (!context.mounted) {
      print("Context not mounted, skipping navigation");
      print(
          "YOOOOOO THIS THIS CONTEXT ISSUE THAT IS WHY NO RATING AND IDK WHY ITS TAKING AFTERWARDS THO");
      return;
    }

    if (!snapshot.exists || snapshot.data() == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const GetStartedPage()),
          (route) => false,
        );
      });
      return;
    }

    final snapshotData = snapshot.data() as Map<String, dynamic>;
    final userObj = AppUser.fromMap(snapshotData);

    ref.read(UserProvider.notifier).setUser(userObj);

    // ✅ SAFE NAVIGATION
    if (snapshot["GetRating"] != null) {
      print("User has GetRating field, navigating to RateTripPage");

      if (!context.mounted) {
        print("Context not mounted, cannot navigate to RateTripPage");
        print(
            "YOOOOOO THIS THIS CONTEXT ISSUE THAT IS WHY NO RATING AND IDsssssssK WHY ITS TAKING AFTERWARDS THO");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RateTripPage(
            tripId: snapshot["GetRating"],
          ),
        ),
      );
    }

    if (snapshot["TripStatus"] != "NONE") {
      existingTripID = snapshot["TripStatus"];

      ref.read(showBottomNavProvider.notifier).state = false;
      ref.read(rideContainerProvider.notifier).state = 1;
      ref.read(RidesubDetailsLoading.notifier).state = true;
      ref.read(panelIndexProvider.notifier).state = 3;
    }
  } catch (e) {
    if (!context.mounted) return;
    handleFirestoreException(context, e);
  }
}
