import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/theme.dart';

Widget buildActivityCard({
  required String title,
  required String value,
  required String subtitle,
  required IconData icon,
  required Color color,
  required Color textColor,
  required BuildContext context,
  bool showProgress = false,
}) {
  return Container(
    padding: EdgeInsets.all(15.r),
    decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: boxShadow(context)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: textColor == Themes.white0(context)
                    ? Themes.white0(context).withValues(alpha: 0.2)
                    : Themes.black0(context).withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                color: textColor,
                size: 20,
              ),
            ),
            const Spacer(),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          title,
          style: (Themes.SmallContainerText(context)).copyWith(
            color: textColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          style: Themes.headline3(context).copyWith(
            color: textColor,
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 5.h),
        Text(subtitle,
            style: Themes.SuperSmallContainerText(context)
                .copyWith(color: textColor.withValues(alpha: 0.7))),
      ],
    ),
  );
}
