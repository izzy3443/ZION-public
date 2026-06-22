import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/RIDE_W&F/provider_Ride_Details.dart';
import 'package:zion3/theme.dart';

class PaymentFareCard extends ConsumerWidget {
  const PaymentFareCard({super.key});

  @override
  Widget build(BuildContext context, ref) {
    String fairAmount = ref.watch(fairAmountDisplayProvider);
    return ref.watch(RidesubDetailsLoading)
        ? Center(
            child: LoadingCircle(true, context),
          )
        : Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Themes.white0(context),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: boxShadow(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Payment\nMethod-fare",
                    style: Themes.subtitleText(context)),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    const Icon(
                      Icons.currency_rupee, // Cash/Money Icon
                      size: 36,
                      color: Themes.tree_green, // You can change the color
                    ),
                    SizedBox(width: 8.w),
                    Text("Cash",
                        style: Themes.subtitleText(context).copyWith(
                            fontSize: 18.sp, color: Themes.black3(context))),
                    const Spacer(),
                    Text(
                      "${fairAmount.toString()} ₹ ",
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Themes.black0(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
