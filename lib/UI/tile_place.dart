import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/theme.dart'; // Only if you're using `ref`

Widget PlaceTile({
  required String label,
  required BuildContext context,
  IconData? icon,
  void Function()? onTap,
  Color? backgroundColor,
  Color? iconColor,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 12, bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: backgroundColor ?? Themes.white2(context),
          borderRadius: BorderRadius.circular(17.r),
          boxShadow: boxShadow(context),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: iconColor ?? Themes.black0(context),
              ),
              SizedBox(width: 6.w),
            ],
            Text(
              label[0].toUpperCase() + label.substring(1),
              style: Themes.MidContainerText(context)
                  .copyWith(color: Themes.gray3(context)),
            ),
          ],
        ),
      ),
    ),
  );
}
