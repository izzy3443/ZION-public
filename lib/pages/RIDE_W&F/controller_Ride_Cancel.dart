import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/pages/RIDE_W&F/screen_Ride_Cancel.dart';
import 'package:zion3/UI/icon_button.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/main.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Search.dart';

import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';

Widget cancel_button(WidgetRef ref, BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(8.0.r),
    child: customIconTextButton(
      'Cancel ride',
      Icons.directions_car,
      onPressed: () => cancle_req(ref, context),
      context: context,
    ),
  );
}

void cancle_req(WidgetRef ref, BuildContext context) async {
  if (ref.read(rideContainerProvider) == 0) {
    state_of_app = "normal";
    user_req_cancel();
    ref.read(RequestingDriverNumber.notifier).update((state) => 0);

    // tripReqRef =
    //     FirebaseFirestore.instance.collection("trip_req").doc(tripReqRef!.id);
    await tripReqRef!.delete();
    ref.read(panelIndexProvider.notifier).update((state) => 2);
  } else if (ref.read(rideContainerProvider) == 1) {
    showCancelRideSheet(context, ref);
  } else if (ref.read(rideContainerProvider) == 2) {
    ref.read(panelIndexProvider.notifier).update((state) => 2);
  }
}

void showCancelRideSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (context) {
      // Reset state when sheet is opened
      return const CancelRideDialog();
    },
  );
}
