import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/pullUpBar.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_Cancel.dart';
import 'package:zion3/pages/RIDE_W&F/screen_Ride_Fair.dart';
import 'package:zion3/pages/RIDE_W&F/screen_Ride_NotFound.dart';
import 'package:zion3/pages/RIDE_W&F/screen_Ride_Search.dart';
import 'package:zion3/pages/RIDE_W&F/screen_Route_Details.dart';
import 'package:zion3/pages/RIDE_W&F/screen_Ride_Details.dart';

import 'package:zion3/theme.dart';

final StateProvider<int> rideContainerProvider = StateProvider<int>((ref) => 0);
final StateProvider<bool> isCancelEnabled = StateProvider<bool>((ref) => true);

class RideSheet extends StatelessWidget {
  const RideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.4,
      maxChildSize: 0.7,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Themes.white0(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            children: [
              SizedBox(height: 8.h),
              Center(child: pullUpBarLite(context)),
              const _RideContainerSwitcher(),
              SizedBox(height: 8.h),
              const RouteContainer(),
              SizedBox(height: 8.h),
              const PaymentFareCard(),
              SizedBox(height: 8.h),
              const _CancelButtonSection(),
              SizedBox(height: 26.h),
            ],
          ),
        );
      },
    );
  }
}

class _RideContainerSwitcher extends ConsumerWidget {
  const _RideContainerSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rideContainerState = ref.watch(rideContainerProvider);

    return switch (rideContainerState) {
      0 => const RideSearchScreen(),
      1 => const rideDetails(),
      2 => RideNotFound(),
      _ => const RideSearchScreen(),
    };
  }
}

class _CancelButtonSection extends ConsumerWidget {
  const _CancelButtonSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCancelEnable = ref.watch(isCancelEnabled);

    if (!isCancelEnable) return const SizedBox.shrink();

    return cancel_button(ref, context);
  }
}
