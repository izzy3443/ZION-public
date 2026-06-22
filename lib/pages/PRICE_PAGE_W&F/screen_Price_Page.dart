import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/pullUpBar.dart';
import 'package:zion3/UI/floating_button.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/controller_Price_Page.dart';
import 'package:zion3/main.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/utils_Price_Page.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/provider_Price_Page.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/providers/markersProvider.dart';
import 'package:zion3/providers/polylineProvider.dart';
import 'package:zion3/theme.dart';

class Price_Page extends ConsumerStatefulWidget {
  const Price_Page({super.key});

  @override
  ConsumerState<Price_Page> createState() => _Price_PageState();
}

class _Price_PageState extends ConsumerState<Price_Page> {
  final PricePageService _pricePageService = PricePageService();

  @override
  // void initState() {
  //   super.initState();
  //   _pricePageService.setupRouteAndFindDrivers(
  //     ref: ref,
  //   );
  // }
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await _pricePageService.setupRouteAndFindDrivers(ref: ref);
      } catch (e) {
        _handleError(context, e);
      }
    });
  }

  void _handleError(BuildContext context, dynamic e) {
    if (e is FirebaseFunctionsException) {
      switch (e.code) {
        case "failed-precondition":
          showCustomSnackBar(context, "Trip exceeds 77 km limit");
          ref.read(panelIndexProvider.notifier).update((_) => 1);
          break;

        case "not-found":
          showCustomSnackBar(context, "No route found");
          ref.read(panelIndexProvider.notifier).update((_) => 1);
          break;

        case "resource-exhausted":
          showCustomSnackBar(context, "Too many requests, try again later");
          ref.read(panelIndexProvider.notifier).update((_) => 1);
          break;

        case "permission-denied":
          showCustomSnackBar(context, "Permission denied");
          ref.read(panelIndexProvider.notifier).update((_) => 1);
          break;

        case "unauthenticated":
          showCustomSnackBar(context, "Please login again");
          ref.read(panelIndexProvider.notifier).update((_) => 1);
          break;

        default:
          showCustomSnackBar(context, e.message ?? "Unknown error");
          ref.read(panelIndexProvider.notifier).update((_) => 1);
      }
    } else if (e == RouteSetupFailure.pickupOrDropMissing) {
      showCustomSnackBar(context, "Pickup or drop location missing");
    } else {
      showCustomSnackBar(context, "Something went wrong");
    }
  }

  @override
  void dispose() {
    _pricePageService.disposeResources();
    ref.invalidate(noDriverFoundProvider);
    ref.invalidate(dataFetchingProvider);
    super.dispose();
  }

  void GoBack() {
    ref.read(markerSetNotifierProvider.notifier).clearMarkers();
    ref.read(polylinesSetNotifierProvider.notifier).clearPolylines();
    ref.read(panelIndexProvider.notifier).update((state) => 1);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.5,
      maxChildSize: 0.67,
      builder: (context, scrollController) {
        return Column(
          children: [
            /// Back Button (static)
            Padding(
              padding: EdgeInsets.only(left: 16.w, bottom: 16.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: CustomFloatingButton(
                  icon: Icons.arrow_back_ios_rounded,
                  onPressed: GoBack,
                ),
              ),
            ),

            /// Main Sheet
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Themes.white0(context),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(17.r)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    pullUpBar(context),

                    /// Ride Options (isolated)
                    Expanded(
                      child: _RideOptionsList(
                        scrollController: scrollController,
                        pricePageService: _pricePageService,
                      ),
                    ),

                    /// Bottom Action Area (isolated)
                    const _BottomActionArea(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RideOptionsList extends ConsumerWidget {
  final ScrollController scrollController;
  final PricePageService pricePageService;

  const _RideOptionsList({
    required this.scrollController,
    required this.pricePageService,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRide = ref.watch(selectedRideProvider);

    if (selectedRide == null) {
      return Center(child: LoadingCircle(true, context));
    }

    return SingleChildScrollView(
      controller: scrollController,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: rideOptions
              .map(
                (option) => _RideOptionTile(
                  option: option,
                  selected: selectedRide,
                  onTap: () {
                    ref
                        .read(selectedRideProvider.notifier)
                        .update((_) => option);
                    pricePageService.findNearbyDrivers(ref);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _RideOptionTile extends StatelessWidget {
  final RideOption option;
  final RideOption selected;
  final VoidCallback onTap;

  const _RideOptionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = option.mode == selected.mode;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Themes.white1(context).withValues(alpha: 0.8)
              : Themes.white1(context),
          border: isSelected
              ? Border.all(color: Themes.fire_red, width: 2.w)
              : null,
          borderRadius: BorderRadius.circular(17.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(option.imagePath, height: 51.7),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(option.name, style: Themes.smallButtonText(context)),
                    Row(
                      children: [
                        Text(option.duration,
                            style: TextStyle(
                                color: Themes.gray2(context), fontSize: 14.sp)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text('•',
                              style: TextStyle(
                                  color: Themes.gray3(context),
                                  fontSize: 14.sp)),
                        ),
                        Text('${option.capacity} seats',
                            style: TextStyle(
                                color: Themes.gray3(context), fontSize: 14.sp)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Text(
              '\$${option.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontFamily: "outfit",
                fontSize: 16.sp,
                color: Themes.black0(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomActionArea extends ConsumerWidget {
  const _BottomActionArea();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRide = ref.watch(selectedRideProvider);
    final noDriverFound = ref.watch(noDriverFoundProvider);
    final dataFetching = ref.watch(dataFetchingProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT
        children: [
          const Divider(height: 0),
          SizedBox(height: 14.7.h),

          /// Cash row (DO NOT REMOVE)
          Row(
            children: [
              const Icon(Icons.currency_rupee_sharp, color: Themes.tree_green),
              SizedBox(width: 15.w),
              Text(
                "Cash / Pay To Driver",
                style: Themes.subtitle(context).copyWith(fontSize: 18.sp),
              ),
            ],
          ),

          SizedBox(height: 14.7.h),

          /// ✅ Button must be inside Row → Expanded
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedRide == null ||
                          dataFetching ||
                          noDriverFound
                      ? null
                      : () {
                          ref.read(fairAmountDisplayProvider.notifier).state =
                              selectedRide.price.toString();
                          ref
                              .read(panelIndexProvider.notifier)
                              .update((_) => 3);
                          state_of_app = "requesting";
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Themes.fire_red,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7.r),
                    ),
                  ),
                  child: dataFetching
                      ? SizedBox(
                          width: 27.w,
                          height: 27.h,
                          child: LoadingCircle(false, context),
                        )
                      : Text(
                          noDriverFound ? "No Ride Available" : "Choose Ride",
                          style: Themes.buttonText(context).copyWith(
                            color: noDriverFound
                                ? Themes.black1(context)
                                : Themes.white0(context),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
