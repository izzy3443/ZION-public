// login_options_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_loginPage.dart';

import 'package:zion3/theme.dart';

class GetStartedPage extends ConsumerWidget {
  const GetStartedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              Text(
                'ZION',
                style: TextStyle(
                  fontFamily: 'outfit',
                  letterSpacing: -4.777,
                  fontSize: 48.sp,
                  fontWeight: FontWeight.w500,
                  color: Themes.fire_red,
                ),
              ),
              SizedBox(height: 48.h),
              Text('Get started', style: Themes.headlinePro(context)),
              SizedBox(height: 8.h),
              Text('Choose your preferred way to\ncontinue',
                  style: Themes.headline4(context)),
              SizedBox(height: 48.h),
              _buildOptionButton(
                icon: Icons.phone_outlined,
                text: 'Continue with Mobile number',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MobileVerificationPage(),
                    ),
                  );
                },
                context: context,
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      {IconData? icon,
      String? imagePath,
      required String text,
      required VoidCallback onTap,
      required BuildContext context}) {
    return Container(
      decoration: BoxDecoration(
        color: Themes.white1(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  size: 24,
                  color: Colors.black87,
                )
              else if (imagePath != null)
                Image.asset(
                  imagePath,
                  width: 24.w,
                  height: 24.h,
                ),
              SizedBox(width: 16.w),
              Text(text,
                  style: Themes.TextFieldMainText(context)
                      .copyWith(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}
