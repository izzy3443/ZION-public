import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/snackBar.dart';

import 'package:zion3/pages/RIDE_W&F/controller_Ride_Details.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/RIDE_W&F/provider_Ride_Details.dart';
import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';
import 'package:zion3/theme.dart';

final selectedReasonProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final isLoadingProvider = StateProvider.autoDispose<bool>((ref) => false);

class CancelRideDialog extends ConsumerStatefulWidget {
  const CancelRideDialog({super.key});

  @override
  ConsumerState<CancelRideDialog> createState() => _CancelRideDialogState();
}

class _CancelRideDialogState extends ConsumerState<CancelRideDialog> {
  @override
  Widget build(BuildContext context) {
    final selectedReason = ref.watch(selectedReasonProvider);
    final isLoading = ref.watch(isLoadingProvider);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Themes.selected_red,
              ),
              child: const Icon(
                Icons.sentiment_very_dissatisfied_rounded,
                size: 42,
                color: Themes.fire_red,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              "Cancel your ride?",
              textAlign: TextAlign.center,
              style: Themes.headline2(context)
                  .copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              "Why are you cancelling?",
              textAlign: TextAlign.center,
              style: Themes.subtitlesubText(context),
            ),
            SizedBox(height: 24.h),
            buildReasonOption(
                ref, "Driver is taking too long", Icons.timer_rounded),
            buildReasonOption(
                ref, "Driver is not available", Icons.no_transfer_rounded),
            buildReasonOption(ref, "Changed my mind", Icons.close_rounded),
            buildReasonOption(ref, "Found alternate ride",
                Icons.directions_car_filled_rounded),
            buildReasonOption(ref, "Other", Icons.edit_note_rounded),
            SizedBox(height: 12.h),
            customButton(
                text: "Cancel Ride",
                onPressed: selectedReason == null
                    ? null
                    : () => onPressedCancel(
                          selectedReason,
                          ref,
                        ),
                isLoading: isLoading,
                textStyle: Themes.buttonText(context)
                    .copyWith(fontWeight: FontWeight.w500),
                context: context)
          ],
        ),
      ),
    );
  }

  void onPressedCancel(
    String selectedReason,
    WidgetRef ref,
  ) async {
    ref.read(isLoadingProvider.notifier).state = true;

    try {
      final uid = ref.read(UserProvider)!.uid;
      final driverUid = ref.read(driverTripInfoProvider)!.uid;

      final callable = FirebaseFunctions.instance.httpsCallable('cancelTrip');

      final response = await callable.call({
        'tripId': currentTripID,
        'userId': uid,
        'driverId': driverUid,
        'cancelReason': selectedReason,
        'cancelledBy': "user",
      });

      if (!mounted) return; // ✅ CRITICAL FIX

      final result = response.data;

      ref.read(isLoadingProvider.notifier).state = false;

      if (result['success'] == true) {
        // HERERERE
        Navigator.pop(context);
        ref.read(panelIndexProvider.notifier).update((state) => 2);
        ref.read(rideContainerProvider.notifier).update((state) => 0);
        ref.read(driverTripInfoProvider.notifier).clear();
        ref.read(fairAmountDisplayProvider.notifier).state = "";
        ref.read(TripDetailsLoaded.notifier).state = false;
      } else {
        showCustomSnackBar(context, "Trip cancel failed");
      }
    } on FirebaseFunctionsException catch (_) {
      if (!mounted) return;

      ref.read(isLoadingProvider.notifier).state = false;
      Navigator.pop(context);
      showCustomSnackBar(context, "Something went wrong");
    } catch (_) {
      if (!mounted) return;

      ref.read(isLoadingProvider.notifier).state = false;
      Navigator.pop(context);
      showCustomSnackBar(context, "Something went wrong");
    }
  }

  Widget buildReasonOption(WidgetRef ref, String label, IconData icon) {
    final selected = ref.watch(selectedReasonProvider);
    final isSelected = selected == label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => ref.read(selectedReasonProvider.notifier).state = label,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            decoration: BoxDecoration(
              color: isSelected ? Themes.selected_red : Themes.white1(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? Themes.fire_red : Colors.transparent,
                width: 1.4,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: Themes.fire_red),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    label,
                    style: Themes.SmallContainerText(context).copyWith(
                      color: Themes.black1(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded,
                      color: Themes.fire_red),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
