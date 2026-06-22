import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/main.dart';
import 'package:zion3/pages/MainPage.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Chat.dart';

import 'package:zion3/pages/RIDE_W&F/controller_Ride_Details.dart'
    hide TripRuntimeController;
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Search.dart';

import 'package:zion3/pages/RIDE_W&F/screen_RideChat.dart';
import 'package:zion3/pages/RIDE_W&F/provider_Ride_Details.dart';

import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';
import 'package:zion3/providers/markersProvider.dart';
import 'package:zion3/providers/polylineProvider.dart';

import 'package:zion3/theme.dart';

// final GoogleMapController mapController;
// required this.mapController
class rideDetails extends ConsumerStatefulWidget {
  const rideDetails({super.key});

  @override
  ConsumerState<rideDetails> createState() => _rideDetailsState();
}

class _rideDetailsState extends ConsumerState<rideDetails> {
  @override
  // void initState() {
  //   super.initState();

  //   currentTripID = existingTripID ?? tripReqRef!.id;
  //   print("Current Trip IDDDDDDDDDD in Ride Details: $currentTripID");
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     ref.read(tripRuntimeControllerProvider).listen(currentTripID, context);
  //   });
  // }

  @override
  void initState() {
    super.initState();
    currentTripID = existingTripID ?? tripReqRef!.id;
    print("Current Trip IDDDDDDDDDD in Ride Details: $currentTripID");
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(tripRuntimeControllerProvider).listen(
        currentTripID,
        onEvent: (event) {
          if (!mounted) return;

          switch (event) {
            case TripEvent.cancelled:
              ref.read(rideContainerProvider.notifier).state = 0;
              showCustomSnackBar(context, "Driver cancelled the ride");
              break;

            case TripEvent.paid:
              ref.invalidate(rideContainerProvider);
              ref.invalidate(panelIndexProvider);
              ref.invalidate(showBottomNavProvider);

              ref.read(polylinesSetNotifierProvider.notifier).clearPolylines();
              ref.read(markerSetNotifierProvider.notifier).clearMarkers();
              print(" before clearing trip id from source ${tripReqRef!.id}");
              ref.read(driverTripInfoProvider.notifier).clear();
              print(ref.read(driverTripInfoProvider)?.toMap());
              print(
                  "Trip marked as paid. Navigating to main page. cleareddddddddd");
              print(ref.read(driverTripInfoProvider)?.toMap());
              ref.read(TripDetailsLoaded.notifier).state = false;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const MainPage()),
              );
              break;
            case TripEvent.driverEnRoute:
              showCustomSnackBar(
                  context, "Slow internet. Driver is on the way");
              break;
          }
        },
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    ref.invalidate(tripRuntimeControllerProvider);
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isLoaded = ref.watch(TripDetailsLoaded);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: const BorderRadius.all(Radius.circular(25)),
      ),
      child: isLoaded ? _TripContent() : _LoadingView(),
    );
  }

  Widget otpWidgets(String otp) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: otp.split("").map((digit) {
        return Container(
          width: 30.w,
          height: 30.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: Themes.black0(context),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Center(
            child: Text(
              digit,
              style: TextStyle(
                  fontFamily: "outfit",
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: Themes.white0(context)),
            ),
          ),
        );
      }).toList(),
    );
  }

  // void show(BuildContext context, String rideId, String currentUserId) {
  //   Navigator.of(context).push(
  //     MaterialPageRoute(
  //       builder: (_) => ChatPage(
  //         rideId: rideId,
  //         currentUserId: currentUserId,
  //         receiverId: ref.read(driverTripInfoProvider)?.uid ?? "",
  //       ),
  //     ),
  //   );
  // }
}

class _LoadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Center(child: LoadingCircle(true, context)),
    );
  }
}

class _TripContent extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const _TripStatusText(),
        SizedBox(height: 12.h),
        const _DriverAndOtpRow(),
        SizedBox(height: 18.h),
        const _VehicleDetailsRow(),
        SizedBox(height: 18.h),
        const _ChatAndCallRow(),
        SizedBox(height: 15.h),
      ],
    );
  }
}

class _TripStatusText extends ConsumerWidget {
  const _TripStatusText();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(tripStatusDisplay);

    return Text(
      status,
      style: Themes.headline2(context)
          .copyWith(color: Themes.fire_red, fontSize: 28.sp),
    );
  }
}

class _DriverAndOtpRow extends ConsumerWidget {
  const _DriverAndOtpRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverTripInfoProvider);

    if (driver == null) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _DriverCard(driver: driver),
        _OtpRow(otp: driver.otp),
      ],
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DriverTripInfo driver;
  const _DriverCard({required this.driver});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 177.w,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      decoration: BoxDecoration(
        color: Themes.white2(context),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Themes.gray3(context),
            backgroundImage:
                driver.photo.isNotEmpty ? NetworkImage(driver.photo) : null,
            child: driver.photo.isEmpty
                ? Icon(Icons.person, size: 27, color: Themes.gray44(context))
                : null,
          ),
          SizedBox(width: 12.w),
          SizedBox(
            width: 77.w, // 🔥 THIS FIXES OVERFLOW
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  driver.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w300,
                    fontFamily: "outfit",
                    color: Themes.black0(context),
                  ),
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    Icon(Icons.star, size: 14, color: Themes.black0(context)),
                    SizedBox(width: 4.w),
                    Text(
                      driver.rating.toString(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w300,
                        color: Themes.black0(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpRow extends StatelessWidget {
  final String otp;

  const _OtpRow({required this.otp});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "PIN",
          style: Themes.subtitlesubText(context),
        ),
        SizedBox(width: 7.w),
        Row(
          children: otp.split("").map((digit) {
            return Container(
              width: 30.w,
              height: 30.h,
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              decoration: BoxDecoration(
                color: Themes.black0(context),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Center(
                child: Text(
                  digit,
                  style: TextStyle(
                    fontFamily: "outfit",
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w500,
                    color: Themes.white0(context),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _VehicleDetailsRow extends ConsumerWidget {
  const _VehicleDetailsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverTripInfoProvider);
    if (driver == null) return const SizedBox();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _InfoBox(text: driver.vehicleDetails),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Themes.white2(context),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: Themes.black0(context),
              width: 1.w,
            ),
          ),
          child: Text(
            driver.vehicleNumber,
            style: Themes.TextFieldMainText(context)
                .copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  final String text;

  const _InfoBox({
    required this.text,
    // ✅ default value
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: Themes.white2(context),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: Text(
        text,
        style: Themes.TextFieldMainText(context).copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// class _ChatAndCallRow extends ConsumerWidget {
//   const _ChatAndCallRow();

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final driver = ref.watch(driverTripInfoProvider);

//     return Row(
//       children: [
//         Expanded(
//           child: GestureDetector(
//             onTap: () {
//               Navigator.of(context).push(
//                 MaterialPageRoute(
//                   builder: (_) => ChatPage(
//                     rideId: currentTripID,
//                     currentUserId: ref.read(UserProvider)!.uid,
//                     receiverId: driver?.uid ?? "",
//                   ),
//                 ),
//               );
//             },
//             child: Container(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//               decoration: BoxDecoration(
//                 color: Themes.white2(context),
//                 borderRadius: BorderRadius.circular(25.r),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.chat_bubble, color: Themes.gray3(context)),
//                   SizedBox(width: 12.w),
//                   Text(
//                     "Any pickup notes?",
//                     style: TextStyle(
//                         fontSize: 16.sp, color: Themes.gray3(context)),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//         SizedBox(width: 10.w),
//         GestureDetector(
//           onTap: () {
//             launchUrl(Uri.parse("tel://${driver?.phone}"));
//           },
//           child: Container(
//             width: 42.w,
//             height: 42.h,
//             decoration: BoxDecoration(
//               color: Themes.white2(context),
//               borderRadius: BorderRadius.circular(50.r),
//             ),
//             child: Icon(Icons.phone, color: Themes.black0(context), size: 22),
//           ),
//         ),
//       ],
//     );
//   }
// }

class _ChatAndCallRow extends ConsumerWidget {
  const _ChatAndCallRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final driver = ref.watch(driverTripInfoProvider);
    final currentUserId = ref.read(UserProvider)!.uid;

    final unreadCount = ref
            .watch(unreadMessageCountProvider((
              rideId: currentTripID,
              userId: currentUserId,
            )))
            .valueOrNull ??
        0;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatPage(
                    rideId: currentTripID,
                    currentUserId: currentUserId,
                    receiverId: driver?.uid ?? "",
                  ),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: Themes.white2(context),
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                children: [
                  // 👇 Badge wraps just the icon
                  Badge(
                    isLabelVisible: unreadCount > 0,
                    label: unreadCount > 4
                        ? Text("4+", style: TextStyle(fontSize: 10.sp))
                        : null, // null = just the dot when count is low
                    backgroundColor: Colors.red,
                    child:
                        Icon(Icons.chat_bubble, color: Themes.gray3(context)),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    "Any pickup notes?",
                    style: TextStyle(
                        fontSize: 16.sp, color: Themes.gray3(context)),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: () => launchUrl(Uri.parse("tel://${driver?.phone}")),
          child: Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: Themes.white2(context),
              borderRadius: BorderRadius.circular(50.r),
            ),
            child: Icon(Icons.phone, color: Themes.black0(context), size: 22),
          ),
        ),
      ],
    );
  }
}
