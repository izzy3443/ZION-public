import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/theme.dart';

Widget pullUpBar(BuildContext context) {
  return Container(
    height: 6.7, // Adjust the height as needed
    width: 70.w, // Adjust the width as needed
    margin: EdgeInsets.symmetric(vertical: 8.h),
    decoration: BoxDecoration(
      color: Themes.white3(context), // Pull bar color
      borderRadius: BorderRadius.circular(4.r),
    ),
  );
}

Widget pullUpBarLite(BuildContext context) {
  return Container(
    height: 6.7, // Adjust the height as needed
    width: 70.w, // Adjust the width as needed
    margin: EdgeInsets.symmetric(vertical: 0.h),
    decoration: BoxDecoration(
      color: Themes.white3(context), // Pull bar color
      borderRadius: BorderRadius.circular(4.r),
    ),
  );
}
