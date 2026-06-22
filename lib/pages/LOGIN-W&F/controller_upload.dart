import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:zion3/models/user_model.dart';

final TextEditingController firstNameController = TextEditingController();
final TextEditingController lastNameController = TextEditingController();
final AutoDisposeStateProvider<bool> isUploadLoading =
    StateProvider.autoDispose<bool>((ref) => false);
final AutoDisposeStateProvider<bool> formValidProvider =
    StateProvider.autoDispose<bool>((ref) => false);

void setupFieldListeners(WidgetRef ref) {
  // Initial validation check
  _updateValidationState(ref);

  // Add listeners to both controllers
  firstNameController.addListener(() => _updateValidationState(ref));
  lastNameController.addListener(() => _updateValidationState(ref));
}

// Helper function to update the validation state
void _updateValidationState(WidgetRef ref) {
  final isValid = firstNameController.text.trim().isNotEmpty &&
      lastNameController.text.trim().isNotEmpty;

  // Only update the state if it changed
  if (ref.read(formValidProvider) != isValid) {
    ref.read(formValidProvider.notifier).state = isValid;
  }
}

Future<void> sendDataToDatabase(WidgetRef ref) async {
  // Get current user data
  final currentUser = ref.read(UserProvider)!;
  final uid = currentUser.uid;
  final phoneNo = currentUser.phoneNo;

  final Map<String, dynamic> userDataMap = {
    'Uid': uid,
    'firstName': firstNameController.text,
    'lastName': lastNameController.text,
    'PhoneNo': phoneNo,
    'Email': currentUser.email,
    'TripStatus': 'NONE',
    'BlockStatus': currentUser.blockStatus,
    'TotalKms': 0,
    'TotalMin': 0,
    'Trips': [],
    "GetRating": null,
    'SavedPlaces': {},
  };

  final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

  await userRef.set(userDataMap, SetOptions(merge: true));

  ref.read(UserProvider.notifier).addnames(
        firstNameController.text,
        lastNameController.text,
      );
}
