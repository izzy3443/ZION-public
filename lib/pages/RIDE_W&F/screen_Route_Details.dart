import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zion3/global/paths.dart';
import 'package:zion3/main.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/RIDE_W&F/provider_Ride_Details.dart';
import 'package:zion3/theme.dart';

class RouteContainer extends ConsumerWidget {
  const RouteContainer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      // margin: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Themes.white0(context),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: boxShadow(context),
      ),
      child: ref.watch(RidesubDetailsLoading)
          ? Center(
              child: LoadingCircle(true, context),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "My route",
                  style: Themes.subtitleText(context),
                ),
                SizedBox(height: 12.h),
                _buildRouteRow(
                  iconColor: false,
                  title: "From",
                  location: ref.read(addressProvider).pickup!.Place_name!,
                  context: context,
                ),
                SizedBox(height: 12.h),
                _buildRouteRow(
                  iconColor: true,
                  title: "To",
                  location: ref.read(addressProvider).dropoff!.Place_name!,
                  context: context,
                ),
              ],
            ),
    );
  }

  Widget _buildRouteRow(
      {required bool iconColor,
      required String title,
      required String location,
      required BuildContext context}) {
    return Row(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 7.h),
          child: SvgPicture.asset(
            iconColor ? green_large_marker : red_large_marker,
            height: 36.h,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Themes.subtitlesubText(context),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                location,
                style: TextStyle(
                  fontFamily: "outfit",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Themes.black1(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(
                height: 4.h,
              ),
            ],
          ),
        ),
        // use sized box insted how about that i think using that would be better in terms of efficency
      ],
    );
  }
}
