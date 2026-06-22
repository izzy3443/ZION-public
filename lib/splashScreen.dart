import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3), // Push content down

            // App Logo or Name
            Center(
              child: Text(
                'ZION',
                style: TextStyle(
                  fontFamily: 'opensanhebreww',
                  letterSpacing: -3.777,
                  fontSize: 67.sp,
                  fontWeight: FontWeight.w500,
                  color: Themes.fire_red,
                ),
              ),
            ),

            const Spacer(flex: 2), // Push loading indicator further down

            // Loading Indicator
            LoadingCircle(false, context),

            const Spacer(flex: 1), // Add bottom spacing
          ],
        ),
      ),
    );
  }
}
