import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/theme.dart';

void showCustomSnackBar(
  BuildContext context,
  String message, {
  IconData? icon,
  Color? backgroundColor,
  Color? textColor,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();

  final snackBar = SnackBar(
    content: Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: textColor ?? Themes.white0(context),
              size: 24,
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Text(message,
                style: Themes.buttonTextlogin(context).copyWith(
                  color: textColor ?? Themes.white0(context),
                )),
          ),
        ],
      ),
    ),
    backgroundColor: backgroundColor?.withValues(alpha: 0.9) ??
        Themes.black1(context).withValues(alpha: 0.9),
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
