import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Themes {
  // Centralized Light Theme Constants (with X suffix)
  static const white0X = Color.fromRGBO(255, 255, 255, 1.0);
  static const white1X = Color.fromRGBO(245, 245, 245, 1.0);
  static const white2X = Color.fromRGBO(232, 232, 237, 1.0);
  static const white3X = Color.fromRGBO(231, 230, 231, 1.0);
  static const gray1X = Color.fromRGBO(205, 205, 205, 1.0);
  static const gray2X = Color.fromRGBO(185, 185, 185, 1.0);
  static const gray3X = Color.fromRGBO(145, 145, 145, 1.0);
  static const gray44X = Color.fromRGBO(132, 141, 151, 1.0);
  static const black0X = Color.fromRGBO(0, 0, 0, 1.0);
  static const black1X = Color.fromRGBO(68, 68, 69, 1.0);
  static const black2X = Color.fromRGBO(22, 22, 23, 1.0);
  static const black3X = Color.fromRGBO(30, 30, 30, 1.0);
  static const black4LightX = Color.fromRGBO(48, 48, 48, 1.0);
  static const cream1LightX = Color.fromRGBO(255, 248, 225, 1.0);

// Accent (constant across both themes)
  static const fire_red = Color.fromRGBO(230, 57, 70, 1.0);
  static const tree_green = Color.fromRGBO(50, 187, 120, 1.0);
  static const selected_red = Color(0xFFFFF5F5);
  static const redAccent1 = Color.fromRGBO(255, 82, 82, 1.0);
  static const blue0 = Color.fromRGBO(0, 122, 255, 1.0);
  // Dynamic Colors with context
  static Color white0(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black2X : white0X;

  static Color white1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black3X : white1X;

  static Color white2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black4LightX : white2X;

  static Color white3(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black4LightX : white3X;

  static Color gray1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray2X : gray1X;

  static Color gray2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray3X : gray2X;

  static Color gray3(BuildContext context) => gray3X;

  static Color gray44(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray3X : gray44X;

  static Color black0(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? white0X : black0X;

  static Color black1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray1X : black1X;

  static Color black2(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray3X : black2X;

  static Color black3(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray1X : black3X;

  static Color black4(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black1X : black4LightX;

  static Color cream1(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? black3X : cream1LightX;

  static TextStyle TextFieldPlaceHolder(BuildContext context) => TextStyle(
        fontSize: 34.sp,
        fontFamily: 'outfit',
        color: Themes.gray3(context),
        fontWeight: FontWeight.w600,
      );

  static TextStyle TextFieldText(BuildContext context) => TextStyle(
        fontSize: 34.sp,
        fontFamily: 'outfit',
        color: black0(context),
        fontWeight: FontWeight.w600,
      );

  static TextStyle headlinePro(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 32.sp,
        letterSpacing: -0.2,
        fontWeight: FontWeight.w500,
        color: black0(context),
      );

  static TextStyle headline(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 28.sp,
        letterSpacing: -1.7,
        fontWeight: FontWeight.w500,
        color: black0(context),
      );

  static TextStyle headline2(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 22.sp,
        letterSpacing: -1.0,
        fontWeight: FontWeight.w600,
        color: black0(context),
      );

  static TextStyle headline3(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 24.sp,
        letterSpacing: -0.5,
        fontWeight: FontWeight.w600,
        color: black0(context),
      );

  static TextStyle headline4(BuildContext context) => TextStyle(
        height: -0.0,
        fontWeight: FontWeight.w500,
        color: gray3(context),
        fontFamily: 'outfit',
        fontSize: 24.sp,
        letterSpacing: -0.5,
      );

  static TextStyle subHeadLine(BuildContext context) => TextStyle(
        height: -0.0,
        fontWeight: FontWeight.w500,
        color: gray3(context),
        fontFamily: 'outfit',
        fontSize: 24.sp,
        letterSpacing: -0.5,
      );

  static TextStyle bodyText1(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 16.sp,
        color: black0(context),
        fontWeight: FontWeight.w200,
      );

  static TextStyle buttonText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 18.sp,
        color: white0(context),
      );

  static TextStyle subtitleText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 20.sp,
        color: black0(context),
        fontWeight: FontWeight.w500,
      );

  static TextStyle subtitlesubText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 16.sp,
        color: gray3(context),
        fontWeight: FontWeight.w500,
      );

  static TextStyle buttonTextlogin(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 16.sp,
        color: white0(context),
        fontWeight: FontWeight.w400,
      );

  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 20.sp,
        color: black0(context),
      );

  static TextStyle smallButtonText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 16.sp,
        color: black0(context),
      );

  static TextStyle MidContainerText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 17.sp,
        color: black0(context),
        fontWeight: FontWeight.w500,
      );

  static TextStyle SmallContainerText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 14.sp,
        color: gray3(context),
        fontWeight: FontWeight.w400,
      );

  static TextStyle SuperSmallContainerText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 12.sp,
        color: gray3(context),
        fontWeight: FontWeight.w400,
      );

  static TextStyle TextFieldHintText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 18.sp,
        color: gray3(context),
        fontWeight: FontWeight.w400,
      );

  static TextStyle TextFieldMainText(BuildContext context) => TextStyle(
        fontFamily: 'outfit',
        fontSize: 18.sp,
        color: black0(context),
        fontWeight: FontWeight.w400,
      );
}
  // Themes
  // static var darkModeAppTheme = ThemeData.dark().copyWith(
  //   bottomNavigationBarTheme: BottomNavigationBarThemeData(
  //     // Set the custom font for labels
  //     selectedLabelStyle: TextStyle(
  //       fontFamily: 'Outfit',
  //       fontSize: 8.sp, // Adjust font size if needed
  //     ),
  //     unselectedLabelStyle: TextStyle(
  //       fontFamily: 'Outfit',
  //       fontSize: 8.sp, // Adjust font size if needed
  //     ),

  //     // Set the color for the selected item
  //     selectedItemColor: Colors.blue, // Change to your preferred color
  //     // Set the color for the unselected items
  //     unselectedItemColor: Colors.black, // Change to your preferred color
  //   ),
  //   scaffoldBackgroundColor: black0,
  //   cardColor: gray2,
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: black3,
  //     iconTheme: IconThemeData(
  //       color: white0,
  //     ),
  //   ),
  //   drawerTheme: const DrawerThemeData(
  //     backgroundColor: black3,
  //   ),
  //   primaryColor: Colors.red,
  // );

  // static var lightModeAppTheme = ThemeData.light().copyWith(
  //   scaffoldBackgroundColor: white0,
  //   cardColor: gray2,
  //   appBarTheme: const AppBarTheme(
  //     backgroundColor: white0,
  //     elevation: 0,
  //     iconTheme: IconThemeData(
  //       color: black0,
  //     ),
  //   ),
  //   drawerTheme: const DrawerThemeData(
  //     backgroundColor: white0,
  //   ),
  //   primaryColor: Colors.red,
  // );

