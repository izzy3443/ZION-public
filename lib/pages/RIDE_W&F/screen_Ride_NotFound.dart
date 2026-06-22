import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/icon_button.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/controller_Price_Page.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Search.dart';

import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';
import 'package:zion3/theme.dart';

class RideNotFound extends ConsumerWidget {
  RideNotFound({super.key});

  final PricePageService pageService = PricePageService();

  retry(WidgetRef ref) async {
    pageService.findNearbyDrivers(ref);
    ref.read(RequestingDriverNumber.notifier).update((state) => 0);
    ref.read(rideContainerProvider.notifier).update((state) => 0);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sad Face Icon
          Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Themes.selected_red, // soft red tint
            ),
            child: const Center(
              child: Icon(
                Icons.sentiment_dissatisfied_rounded,
                size: 40,
                color: Themes.fire_red,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "Sorry! All drivers are busy.",
            textAlign: TextAlign.center,
            style: Themes.headline2(context).copyWith(
              color: Themes.black0(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Please try again",
            textAlign: TextAlign.center,
            style: Themes.subtitlesubText(context),
          ),
          SizedBox(height: 18.h),
          customIconTextButton(
            'Retry',
            Icons.refresh,
            onPressed: () {
              retry(ref);
            },
            context: context,
          ),
        ],
      ),
    );
  }
}
