import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion3/main.dart';

import 'package:zion3/theme.dart';

class StartDestHeader extends ConsumerWidget {
  const StartDestHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Container(
        decoration: BoxDecoration(
          color: Themes.white0(context),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30.r),
            topRight: Radius.circular(30.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                color: Themes.black0(context),
                size: 24,
              ),
              onPressed: () {
                FocusScope.of(context).unfocus();
                ref.read(panelIndexProvider.notifier).state = 0;

                ref.read(showBottomNavProvider.notifier).state = true;
              },
            ),
            Text(
              "Your Route",
              style: Themes.headline(context).copyWith(fontSize: 24.sp),
            ),
            IconButton(
              icon: Icon(
                Icons.swap_vert,
                color: Themes.black0(context),
                size: 24,
              ),
              onPressed: () {
                // swap logic later
              },
            ),
          ],
        ),
      ),
    );
  }
}
