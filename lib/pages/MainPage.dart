import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/main.dart';
import 'package:zion3/pages/RECENT_RIDES_W&F/screen_recentRides.dart';
import 'package:zion3/pages/LANDINGPAGE-W&F/screen_LandingPage.dart';
import 'package:zion3/pages/PROFILE_W&F/screen_MainProfilePage.dart';

import 'package:zion3/theme.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(pageIndexProvider);
    final showBottomNav = ref.watch(showBottomNavProvider);

    return Scaffold(
      body: Stack(
        children: [
          //  Keep Homepage alive, just hide/show
          Offstage(
            offstage: selectedIndex != 0,
            child: const Homepage(),
          ),

          // Show profile only when selected
          if (selectedIndex == 1) const ProfileScreen(),

          // Show recent rides only when selected
          if (selectedIndex == 2) const DriverTripsHistoryPage(),
        ],
      ),
      bottomNavigationBar: showBottomNav
          ? BottomNavigationBar(
              selectedLabelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10.sp,
              ),
              unselectedLabelStyle: TextStyle(
                fontFamily: 'Outfit',
                fontSize: 10.sp,
              ),
              selectedItemColor: Themes.black0(context),
              unselectedItemColor: Themes.gray3(context),
              backgroundColor: Themes.white0(context),
              currentIndex: selectedIndex,
              onTap: (index) {
                ref.read(pageIndexProvider.notifier).setPageIndex(index);
              },
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home, size: 30),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person, size: 30),
                  label: 'Profile',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history, size: 30),
                  label: 'Past Trips',
                ),
              ],
            )
          : null,
    );
  }
}
