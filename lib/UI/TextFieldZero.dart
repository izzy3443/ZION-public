import 'package:flutter/material.dart';
import 'package:zion3/theme.dart';

Widget textFieldZero(
  TextEditingController textFieldController,
  String hintText,
  BuildContext context,
  int maxlength, {
  FocusNode? focusNode,
}) {
  return TextField(
      maxLength: 10,
      controller: textFieldController,
      focusNode: focusNode,
      keyboardType: TextInputType.phone,
      cursorColor: Themes.gray2(context),
      cursorWidth: 2.5,
      decoration: InputDecoration(
        counterText: "",
        hintText: hintText,
        hintStyle: Themes.TextFieldPlaceHolder(context),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      style: Themes.TextFieldText(context));
}
