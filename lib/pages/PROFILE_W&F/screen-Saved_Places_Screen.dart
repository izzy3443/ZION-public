import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/trailing.dart';
import 'package:zion3/models/address_model.dart';

import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/PROFILE_W&F/screen-place_edit.dart';
import 'package:zion3/pages/PROFILE_W&F/screen_place_search_screen.dart';
import 'package:zion3/UI/smallUI.dart';

import 'package:zion3/theme.dart';

class SavedPlacesScreen extends ConsumerWidget {
  const SavedPlacesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(UserProvider);
    final savedPlaces = user?.savedPlaces ?? {};

    final customPlacesList = savedPlaces.entries
        .where((entry) =>
            entry.key.toLowerCase() != "home" &&
            entry.key.toLowerCase() != "work")
        .toList();

    return Scaffold(
      backgroundColor: Themes.white0(context),
      appBar: AppBar(
        backgroundColor: Themes.white0(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Themes.black0(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Saved Places',
          style: Themes.headline2(context).copyWith(
            fontSize: 24.sp,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Text(
                'Favorites',
                style: Themes.subtitleText(context).copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Themes.black1(context),
                ),
              ),
            ),
            reusableListItem(
              icon: Icons.work_outline,
              title: 'Work',
              subtitle:
                  savedPlaces["Work"]?.Place_name ?? "Add your work address",
              iconColor: Colors.blue,
              onTap: () => GoToNextPage("Work", false, context),
              trailing: trailing(context),
              context: context,
            ),
            reusableListItem(
              icon: Icons.home_outlined,
              title: 'Home',
              subtitle:
                  savedPlaces["Home"]?.Place_name ?? "Add your home address",
              iconColor: Themes.tree_green,
              onTap: () => GoToNextPage("Home", false, context),
              trailing: trailing(context),
              context: context,
            ),
            SizedBox(height: 24.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              child: Row(
                children: [
                  Text(
                    'Other saved places',
                    style: Themes.subtitleText(context).copyWith(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Themes.black1(context),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (customPlacesList.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Themes.redAccent1.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${customPlacesList.length}',
                        style: const TextStyle(
                          color: Themes.redAccent1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (customPlacesList.isEmpty)
              Padding(
                padding: EdgeInsets.all(20.0.r),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 64,
                        color: Themes.gray3(context),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No saved places yet',
                        style: Themes.subtitleText(context).copyWith(
                          color: Themes.gray3(context),
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: customPlacesList.length,
                itemBuilder: (context, index) {
                  final entry = customPlacesList[index];
                  return reusableListItem(
                    icon: Icons.location_on_outlined,
                    title: entry.key,
                    subtitle: entry.value.Place_name!,
                    iconColor: Themes.fire_red,
                    onTap: () => GoToNextCustomPage(
                        entry.key, entry.value, true, context),
                    trailing: trailing(context),
                    context: context,
                  );
                },
              ),
            SizedBox(height: 16.h),
            SizedBox(height: 8.h),
            _buildAddSavedPlaceButton(context),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildAddSavedPlaceButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        decoration: BoxDecoration(
          color: Themes.white0(context),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Themes.redAccent1.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Themes.black0(context).withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.r),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const PlaceSearchScreen(CustomPlaceName: true)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              child: Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Themes.redAccent1,
                    size: 24,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Add Saved Place',
                    style: TextStyle(
                      fontFamily: 'outfit',
                      fontSize: 16.sp,
                      color: Themes.redAccent1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    color: Themes.redAccent1,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void GoToNextPage(String name, bool custom, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceSearchScreen(
          PlaceName: name,
          CustomPlaceName: custom,
        ),
      ),
    );
  }

  void GoToNextCustomPage(
      String name, AddressModel model, bool custom, BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) =>
              PlaceDetailsScreen(placeKey: name, model: model)),
    );
  }
}
