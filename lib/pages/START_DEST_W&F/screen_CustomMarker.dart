import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/floating_button.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/global/paths.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/screen_LandingPage.dart';
import 'package:zion3/pages/START_DEST_W&F/provider_CustomMarker.dart';
import 'package:zion3/theme.dart';

class ConfirmLocationSheet extends ConsumerStatefulWidget {
  const ConfirmLocationSheet({super.key});

  @override
  ConsumerState<ConfirmLocationSheet> createState() =>
      _ConfirmLocationSheetState();
}

class _ConfirmLocationSheetState extends ConsumerState<ConfirmLocationSheet> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locationModell = marker_placement();
      ref
          .read(MarkerlocationModelProvider.notifier)
          .update((state) => locationModell);
    });

    super.initState();
  }

  AddressModel marker_placement() {
    final AddressModel locationModel;
    if (isPickupActive) {
      final pickupModel = ref.read(addressProvider).pickup;
      if (pickupModel == null) {
        print(
            "hey pick up model is null but it should not be because we are updatig in homepage");
        if (ref.read(addressProvider).currentLocation == null) {
          locationModel = null_model;
        } else {
          locationModel = ref.read(addressProvider).currentLocation!;
        }
      } else {
        locationModel = ref.read(addressProvider).pickup!;
      }
    } else {
      final dropoffModel = ref.read(addressProvider).dropoff;
      if (dropoffModel == null) {
        if (ref.read(addressProvider).currentLocation == null) {
          locationModel = null_model;
        } else {
          locationModel =
              locationModel = ref.read(addressProvider).currentLocation!;
        }
      } else {
        locationModel = ref.read(addressProvider).dropoff!;
      }
    }
    LatLng markerLatlng = LatLng(locationModel.lat!, locationModel.long!);
    final controller = ref.read(googleMapControllerProvider);
    // controller?.animateCamera(CameraUpdate.newLatLng(markerLatlng));
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final cameraPadding = screenHeight * 0.30;
    controller?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: markerLatlng,
          northeast: markerLatlng,
        ),
        cameraPadding,
      ),
    );
    return locationModel;
  }

  AddressModel null_model = AddressModel(
    lat: 7.7,
    long: 7.7,
    Place_name: "Please Move The Marker",
    Place_name_sec: "Please Move The Marker",
    place_id: "Please Move The Marker",
  );

  @override
  Widget build(BuildContext context) {
    return const Stack(
      alignment: Alignment.center,
      children: [
        _MapPinOverlay(),
        _BottomSheetContent(),
      ],
    );
  }
}

class _MapPinOverlay extends ConsumerWidget {
  const _MapPinOverlay();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider_customMarker);

    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              /// Shadow dot
              AnimatedOpacity(
                opacity: isLoading ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 120),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  width: 8.w,
                  height: 8.h,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                    boxShadow: boxShadow(context),
                  ),
                ),
              ),

              /// Pin image
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(
                  0,
                  isLoading ? -22 : 0,
                  0,
                ),
                child: Image.asset(
                  red_marker,
                  width: 50.w,
                  height: 50.h,
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomSheetContent extends ConsumerWidget {
  const _BottomSheetContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: CustomFloatingButton(
              icon: Icons.arrow_back_ios_rounded,
              onPressed: () {
                ref.read(panelIndexProvider.notifier).update((_) => 2);
              },
            ),
          ),

          /// 👇 Only this part is reactive
          const _LocationCard(),
        ],
      ),
    );
  }
}

class _LocationCard extends ConsumerWidget {
  void completeButton(WidgetRef ref) {
    final markerLocation = ref.read(MarkerlocationModelProvider);

    if (markerLocation == null) {
      return;
    }

    // ===========================
    // ✅ FINAL CONFIRM STAGE
    // ===========================
    if (isConfirm) {
      ref.read(addressProvider.notifier).add_pickup(markerLocation);

      isConfirm = false;

      ref.read(panelIndexProvider.notifier).update((_) => 2);

      return;
    }

    if (isPickupActive) {
      ref.read(addressProvider.notifier).add_pickup(markerLocation);
    } else {
      ref.read(addressProvider.notifier).add_dropoff(markerLocation);
    }

    final address = ref.read(addressProvider);

    final pickupName = address.pickup?.Place_name;
    final dropoffName = address.dropoff?.Place_name;

    if (pickupName != null && dropoffName != null) {
      isConfirm = true;
      isPickupActive = true;
    } else {}

    ref.read(panelIndexProvider.notifier).update((_) => 1);
  }

  const _LocationCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider_customMarker);
    final locationName = ref.watch(MarkerlocationModelProvider);

    return Container(
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 23),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isPickupActive ? "Confirm Pickup Spot" : "Confirm DropOff Spot",
            style: Themes.headline3(context).copyWith(
              color: isConfirm ? Themes.fire_red : Themes.black0(context),
            ),
          ),

          SizedBox(height: 12.h),

          /// Location row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: Themes.white1(context),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Themes.white2(context)),
              boxShadow: [
                BoxShadow(
                  color: Themes.fire_red.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Themes.selected_red,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 24,
                    color: Themes.fire_red,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Location',
                          style: Themes.SmallContainerText(context)),
                      SizedBox(height: 4.h),
                      Text(
                        locationName?.Place_name ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'outfit',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isLoading
                              ? Themes.gray3(context)
                              : Themes.black0(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 14.h),

          customButton(
            onPressed: () => completeButton(ref),
            text: isPickupActive ? "Confirm Pickup" : "Confirm Dropoff",
            isLoading: isLoading,
            context: context,
          ),

          SizedBox(height: 22.h),
        ],
      ),
    );
  }
}
