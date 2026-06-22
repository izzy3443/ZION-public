import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/models/user_model.dart';

final StateProvider<bool> isProfileLoading = StateProvider<bool>((ref) => true);
String? TotalRides;

Future<void> fetchUserTotalRides(WidgetRef ref) async {
  final userId = ref.read(UserProvider)!.uid;

  try {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('trip_req')
        .where('UserId', isEqualTo: userId)
        .get();

    final count = querySnapshot.docs.length;

    // Save it
    TotalRides = count.toString();

    // Set the flag true
    ref.read(isProfileLoading.notifier).state = false;
  } catch (e) {
    ref.read(isProfileLoading.notifier).state = false;
  }
}
