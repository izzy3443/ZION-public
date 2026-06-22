import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/auth/E-firestore.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/theme.dart';

class RateTripPage extends ConsumerStatefulWidget {
  final String tripId;

  const RateTripPage({super.key, required this.tripId});

  @override
  ConsumerState<RateTripPage> createState() => _RateTripPageState();
}

class _RateTripPageState extends ConsumerState<RateTripPage> {
  Map<String, dynamic>? tripData;
  // Providers
  final TextEditingController _feedbackController = TextEditingController();
  final selectedStarsProvider = StateProvider<int>((ref) => 0);
  final selectedReasonProvider = StateProvider<String?>((ref) => null);
  final isLoadingProvider = StateProvider<bool>((ref) => false);
  final isLoadingMainProvider = StateProvider<bool>((ref) => true);

  final reasonOptionsProvider = Provider<Map<int, List<String>>>((ref) => {
        1: ["Driver was rude", "Vehicle unclean", "Late arrival"],
        2: ["Slow driving", "Took longer route", "Unresponsive driver"],
        3: ["Average service", "Could be better", "Not punctual"],
        4: ["Polite driver", "Good ride", "Comfortable experience"],
        5: ["Excellent service", "Very polite", "Clean vehicle"],
      });

  Future<void> getTripData() async {
    try {
      final tripDoc = await FirebaseFirestore.instance
          .collection('trip_req')
          .doc(widget.tripId)
          .get();

      if (!tripDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Trip data not found',
        );
      }

      final trip = tripDoc.data()!;
      final driverId = trip["DriverId"];

      final driverDoc = await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .get();

      if (!driverDoc.exists) {
        throw FirebaseException(
          plugin: 'cloud_firestore',
          code: 'not-found',
          message: 'Driver data not found',
        );
      }

      final driver = driverDoc.data()!;

      tripData = {
        ...trip,
        "DriverName": "${driver["firstName"]} ${driver["lastName"]}",
        "DriverPhone": driver["PhoneNo"],
        "DriverPhoto": driver["ProfilePic"],
        "VehicleDetails": driver["VehicleDetails"],
        "VechicleNumberPlate": driver["VehicleNumberPlate"],
      };

      ref.read(isLoadingMainProvider.notifier).state = false;
    } catch (error) {
      if (!mounted) return;

      handleFirestoreException(context, error);
    }
  }

  @override
  void initState() {
    super.initState();
    getTripData();
  }

  @override
  Widget build(BuildContext context) {
    final selectedStars = ref.watch(selectedStarsProvider);
    final selectedReason = ref.watch(selectedReasonProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final reasonOptions = ref.watch(reasonOptionsProvider);
    final isLoadingMain = ref.watch(isLoadingMainProvider);

    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: isLoadingMain
            ? Center(child: LoadingCircle(false, context))
            : Padding(
                padding: EdgeInsets.all(20.r),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(tripData!['DriverPhoto']),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        tripData?['DriverName'] ?? '',
                        style: Themes.headline2(context)
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text(tripData?['VehicleDetails'] ?? '',
                          style: Themes.subtitlesubText(context)),
                      Text(tripData?['VechicleNumberPlate'] ?? '',
                          style: Themes.subtitlesubText(context)),
                      SizedBox(height: 16.h),
                      Text("Rate your trip", style: Themes.headline3(context)),
                      SizedBox(height: 8.h),

                      // Star Rating
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1;
                          return IconButton(
                            icon: Icon(
                              Icons.star_rounded,
                              size: 36,
                              color: selectedStars >= star
                                  ? Colors.amber
                                  : Themes.gray1(context),
                            ),
                            onPressed: () => ref
                                .read(selectedStarsProvider.notifier)
                                .state = star,
                          );
                        }),
                      ),

                      if (selectedStars > 0)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.h),
                            Text("Why this rating?",
                                style: Themes.subtitlesubText(context)),
                            SizedBox(height: 8.h),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: reasonOptions[selectedStars]!
                                  .map((reason) => ChoiceChip(
                                        label: Text(reason),
                                        selected: selectedReason == reason,
                                        onSelected: (_) => ref
                                            .read(
                                                selectedReasonProvider.notifier)
                                            .state = reason,
                                        selectedColor: Themes.selected_red,
                                        backgroundColor: Themes.white1(context),
                                        labelStyle: TextStyle(
                                          color: Themes.black1(context),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ],
                        ),

                      SizedBox(height: 16.h),

                      // Feedback Field
                      TextField(
                        controller: _feedbackController,
                        decoration: InputDecoration(
                          hintText: "Add optional feedback",
                          filled: true,
                          fillColor: Themes.white1(context),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                        ),
                        maxLines: 3,
                      ),

                      SizedBox(height: 24.h),

                      // Submit Button
                      customButton(
                          context: context,
                          text: "Submit",
                          isLoading: isLoading,
                          onPressed: selectedStars == 0
                              ? null
                              : () => onConfirm(selectedReason, selectedStars)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  onConfirm(String? selectedReason, int selectedStars) async {
    ref.read(isLoadingProvider.notifier).state = true;

    final feedback = [
      if (selectedReason != null) selectedReason,
      if (_feedbackController.text.isNotEmpty) _feedbackController.text.trim(),
    ].join(" | ");

    // await FirebaseFirestore.instance
    //     .collection('trip_req')
    //     .doc(tripData!['TripId'])
    //     .update({
    //   'UserRating': selectedStars,
    //   'UserFeedback': feedback,
    // });
    // await FirebaseFirestore.instance
    //     .collection('users')
    //     .doc(ref.read(UserProvider)!.uid)
    //     .update({
    //   'GetRating': null,
    // });
    // final rating = getRating();
    // await updateDriverRating(tripData!['DriverId'], selectedStars);

    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('submitTripRating');

    await callable.call({
      'tripId': tripData!['TripId'],
      'driverId': tripData!['DriverId'],
      'userId': ref.read(UserProvider)!.uid,
      'rating': selectedStars,
      'feedback': feedback,
    });
    ref.read(isLoadingProvider.notifier).state = false;
    if (!mounted) {
      return; // gpt i added this there was an async error will this solve?
    }
    Navigator.pop(context);
  }

  Future<void> updateDriverRating(String driverId, int userRating) async {
    final driverRef =
        FirebaseFirestore.instance.collection('drivers').doc(driverId);

    try {
      final snapshot = await driverRef.get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;

        double currentRating = (data['Rating'] ?? 5.0).toDouble();
        int totalRides = (data['TotalRides'] ?? 0).toInt();

        // Calculate new average
        double newAverage =
            ((currentRating * totalRides) + userRating) / (totalRides + 1);

        await driverRef.update({
          'Rating':
              double.parse(newAverage.toStringAsFixed(1)), // round to 1 decimal
        });
      }
    } catch (e) {
      debugPrint('Error updating driver rating: $e');
      // Optionally show snackbar or log error
    }
  }

  double getRating() {
    final userrating = ref.read(selectedStarsProvider);
    double rating = userrating + 1.5;
    return rating.clamp(1.0, 5.0);
  }
}
