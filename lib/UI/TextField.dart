import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/theme.dart';

Widget textField(
  TextEditingController textFieldController,
  BuildContext context,
  String hintText, {
  FocusNode? focusNode, // Optional focus node
  IconData? icon, // Optional icon
  void Function(String)? onChanged,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Themes.white0(context),
      borderRadius: BorderRadius.circular(16.r),
      boxShadow: boxShadow(context),
    ),
    child: TextField(
      focusNode: focusNode,
      cursorColor: Themes.black1(context),
      controller: textFieldController,
      style: Themes.TextFieldMainText(context),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: Themes.TextFieldHintText(context),
        prefixIcon: icon != null
            ? Icon(icon, color: Themes.black1(context))
            : null, // Show only if icon is not null
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      ),
      onChanged: onChanged,
    ),
  );
}
