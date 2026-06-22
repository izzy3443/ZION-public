import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/main.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Search.dart';
import 'package:zion3/pages/START_DEST_W&F/controller_start_dest.dart';
import 'package:zion3/theme.dart';

class RideSearchScreen extends ConsumerStatefulWidget {
  const RideSearchScreen({super.key});

  @override
  _RideSearchScreenState createState() => _RideSearchScreenState();
}

class _RideSearchScreenState extends ConsumerState<RideSearchScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await createTripRequest(ref);
        await searchDriver(ref);
        if (ref.read(addressProvider).dropoff == null) {}
        await addToRecentPlace_C(
          ref.read(addressProvider).dropoff!,
          ref,
        );
      } catch (e) {
        if (!mounted) return;

        showCustomSnackBar(context, "Failed to start ride request");
      }
    });
  }

  void cancle_req() async {
    state_of_app = "normal";
    user_req_cancel();
    ref.read(RequestingDriverNumber.notifier).update((state) => 0);
    tripReqRef =
        FirebaseFirestore.instance.collection("trip_req").doc(tripReqRef!.id);
    await tripReqRef!.delete();
    ref.read(panelIndexProvider.notifier).update((state) => 2);
  }

  @override
  Widget build(BuildContext context) {
    return
        // Bottom Sheet
        Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Center(child: pullUpBarLite()),
          Text(
            'Connecting you to driver ${ref.watch(RequestingDriverNumber)} ...',
            style: Themes.headline2(context)
                .copyWith(color: Themes.black0(context)),
          ),
          SizedBox(height: 8.h),
          Text(
            'Finding you available drivers nearby',
            style: Themes.subtitlesubText(context),
          ),
          SizedBox(height: 24.h),

          // Progress Bar
          LinearProgressIndicator(
            minHeight: 5.h,
            borderRadius: const BorderRadius.all(Radius.circular(17)),
            backgroundColor: Themes.white3(context),
            valueColor: const AlwaysStoppedAnimation<Color>(Themes.fire_red),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
    //   ],
    // ),
  }
}
