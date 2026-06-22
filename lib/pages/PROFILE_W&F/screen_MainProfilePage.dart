import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Activity_card.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/UI/trailing.dart';
import 'package:zion3/main.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/PROFILE_W&F/controller_MainProfile.dart';
import 'package:zion3/pages/PROFILE_W&F/screen-Saved_Places_Screen.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/PROFILE_W&F/screen_profile_editing.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_getStartedPage.dart';
import 'package:zion3/theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    fetchUserTotalRides(
      ref,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(UserProvider)!;
    final isLoading = ref.watch(isProfileLoading);
    // Set status bar to transparent with dark icons

    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: !isLoading
            ? SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(user.firstName, user.lastName),
                    _buildBalanceCard(user, context),
                    // _buildQuickActions(),
                    _buildActivityOverview(user),
                    _buildMenuOptions(),
                    SizedBox(height: 20.h),
                  ],
                ),
              )
            : Center(
                child: LoadingCircle(false, context),
              ),
      ),
    );
  }

  Widget _buildHeader(String firstname, String lastname) {
    return Padding(
      padding: EdgeInsets.fromLTRB(22.w, 20.h, 20.w, 25.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: Themes.white1(context), // Background color
                ),
                child: Icon(
                  Icons.person,
                  size: 40,
                  color: Themes.gray3(context), // Default profile icon color
                ),
              ),
              SizedBox(width: 15.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, Welcome Back!',
                    style: Themes.subtitlesubText(context).copyWith(
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "$firstname $lastname",
                    style: Themes.headline2(context),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration GradientContaierDecoration(BuildContext context) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Themes.black2(context),
          Themes.black4(context),
        ],
      ),
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [
        BoxShadow(
          color: Themes.black0(context).withValues(alpha: 0.15),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(AppUser user, BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 25.h),
      padding: EdgeInsets.all(20.r),
      decoration: GradientContaierDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Rides',
                style: Themes.subtitleText(context).copyWith(
                  color: Themes.white0(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Themes.white0(context).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text('ZION',
                    style: Themes.SuperSmallContainerText(context).copyWith(
                        letterSpacing: -0.7,
                        fontWeight: FontWeight.w600,
                        color: Themes.white0(context))),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          //Themes.white0(context).withValues(alpha: 0.7)
          Text(
            'With Zion',
            style: Themes.buttonTextlogin(context).copyWith(
              color: Themes.gray3(context),
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '$TotalRides Rides',
            style: Themes.buttonTextlogin(context).copyWith(
              fontSize: 36.sp,
              fontWeight: FontWeight.w500,
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () {
              ref.read(pageIndexProvider.notifier).setPageIndex(2);
            },
            child: Row(
              children: [
                _buildActionButton(
                  icon: Icons.history,
                  label: 'Ride History',
                  backgroundColor: Themes.fire_red,
                ),
                SizedBox(width: 12.w),
                _buildActionButton(
                  icon: Icons.info_outline,
                  label: 'Details',
                  backgroundColor:
                      Themes.white0(context).withValues(alpha: 0.2),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 45.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: Themes.white0(context).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(15.r),
                  ),
                  child: Icon(
                    Icons.more_horiz,
                    color: Themes.white0(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Container(
        height: 45.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Themes.white0(context),
              size: 18,
            ),
            SizedBox(width: 8.w),
            Text(
              label,
              style: Themes.buttonTextlogin(context).copyWith(
                color: Themes.white0(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityOverview(AppUser user) {
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 25.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Build_title_('Activity Overview'),
          SizedBox(height: 15.h),
          Row(
            children: [
              Expanded(
                child: buildActivityCard(
                    title: 'Time Spent',
                    value: "${user.totalMin.toString()} Min",
                    subtitle: 'with Zion',
                    icon: Icons.access_time,
                    color: Themes.black4(context),
                    textColor: Themes.white0(context),
                    showProgress: false,
                    context: context),
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: buildActivityCard(
                    title: 'Distance Traveled',
                    value: "${user.totalKms.toString()} Km",
                    subtitle: "With Zion",
                    icon: Icons.directions_car_outlined,
                    color: Themes.cream1(context),
                    textColor: Themes.black0(context),
                    showProgress: false,
                    context: context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions() {
    return Container(
      child: Column(
        children: [
          reusableListItem(
              icon: Icons.person,
              title: 'Edit Profile',
              subtitle: 'Name and more',
              iconColor: Themes.blue0,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const EditProfilePage();
                    },
                  ),
                );
              },
              context: context,
              trailing: trailing(context)),
          reusableListItem(
              icon: Icons.location_on,
              title: 'Add Saved Places',
              subtitle: 'Home, Work, and 3 others',
              iconColor: Themes.tree_green,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) {
                      return const SavedPlacesScreen();
                    },
                  ),
                );
              },
              context: context,
              trailing: trailing(context)),
          reusableListItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              subtitle: 'Get support & send feedback',
              iconColor: Themes.fire_red,
              onTap: () {},
              trailing: trailing(context),
              context: context),
          SizedBox(height: 12.h), // Add spacing between items
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            child: GestureDetector(
              onTap: () async {
                final navigator = Navigator.of(context);
                try {
                  await FirebaseAuth.instance.signOut();

                  if (!mounted) return;

                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const GetStartedPage()),
                    (route) => false,
                  );
                } catch (e) {
                  showCustomSnackBar(
                    context,
                    "Logout failed. Please try again.",
                  );
                }
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 15.h),
                decoration: BoxDecoration(
                  color: Themes.white0(context),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: boxShadow(context),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.logout,
                        size: 20,
                        color: Themes.fire_red,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'Log Out',
                        style: Themes.MidContainerText(context).copyWith(
                          color: Themes.fire_red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  // Activity Overview
  Widget Build_title_(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: Themes.headline2(context),
        ),
        TextButton(
          onPressed: () {
            ref.read(pageIndexProvider.notifier).setPageIndex(2);
          },
          child: Text(
            'See All',
            style: Themes.subtitlesubText(context).copyWith(
              color: Themes.fire_red,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
