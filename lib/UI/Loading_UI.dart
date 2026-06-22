import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/theme.dart';

void ShowLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => Center(
      child: CircularProgressIndicator(
        // 70% completed
        backgroundColor: Themes.white3(context),
        valueColor: const AlwaysStoppedAnimation<Color>(Themes.fire_red),
        strokeWidth: 6.7,
        strokeCap: StrokeCap.round, // Makes it thicker
      ),
    ),
  );
}

Widget LoadingCircle(bool background, BuildContext context) {
  return CircularProgressIndicator(
    // 70% completed
    backgroundColor: background ? Themes.white3(context) : null,
    valueColor: const AlwaysStoppedAnimation<Color>(Themes.fire_red),
    strokeWidth: 6.7,
    strokeCap: StrokeCap.round, // Makes it thicker
  );
}

Widget LoadingLine(bool background, BuildContext context) {
  return LinearProgressIndicator(
    borderRadius: BorderRadius.circular(7.r),
    backgroundColor: background ? Themes.white3(context) : null,
    valueColor: const AlwaysStoppedAnimation<Color>(Themes.fire_red),
    minHeight: 4.7, // Adjust thickness
  );
}
