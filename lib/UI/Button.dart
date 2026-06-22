import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/theme.dart';

Widget customButton({
  required String text,
  Function()? onPressed,
  Color? backgroundColor,
  TextStyle? textStyle,
  bool isLoading = false,
  String? alternateText,
  bool? showAlternateText = false,
  BuildContext? context,
}) {
  final isDisabled = onPressed == null || isLoading;

  return ElevatedButton(
    onPressed: isDisabled ? null : onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: isDisabled
          ? Themes.gray1(context!)
          : (backgroundColor ?? Themes.fire_red),
      minimumSize: const Size(double.infinity, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
      elevation: 4,
    ),
    child: isLoading
        ? SizedBox(
            width: 27.w,
            height: 27.h,
            child: Center(child: LoadingCircle(false, context!)),
          )
        : Text(
            showAlternateText == true ? (alternateText ?? "Alternative") : text,
            style: textStyle ?? Themes.buttonText(context!),
          ),
  );
}
