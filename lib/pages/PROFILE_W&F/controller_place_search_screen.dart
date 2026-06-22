import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zion3/models/address_model.dart';
import 'package:zion3/models/user_model.dart';

Future<void> saveAddressSavedPlaces(
    WidgetRef ref, String type, AddressModel address) async {
  final docRef = FirebaseFirestore.instance
      .collection('users')
      .doc(ref.read(UserProvider)!.uid);

  try {
    await docRef.update({
      "SavedPlaces.$type": {
        "Place_name": address.Place_name ?? "none",
        "Place_name_sec": address.Place_name_sec ?? "none",
        "lat": address.lat,
        "long": address.long,
        "place_id": address.place_id,
      }
    });

    // Optional: you could skip the second update if the above does the same
    await docRef.update({
      "SavedPlaces.$type": address.toMap(),
    });

    ref.read(UserProvider.notifier).addSavedPlace(type, address);
  } catch (error) {
    rethrow;
  }
}
