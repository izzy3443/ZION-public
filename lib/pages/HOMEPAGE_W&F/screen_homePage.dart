import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/tile_place.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/UI/Loading_UI.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/pages/PROFILE_W&F/screen_place_search_screen.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/HOMEPAGE_W&F/controller_homePage.dart';
import 'package:zion3/theme.dart';

class HomepageFrontend extends ConsumerWidget {
  // final VoidCallback nav;
  const HomepageFrontend({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.2,
      maxChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Themes.white0(context),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(30).r,
              topRight: const Radius.circular(30).r,
            ),
          ),
          child: BuildExpandedContent(scrollController, ref, context),
        );
      },
    );
  }
}

Widget BuildExpandedContent(
    ScrollController scrollController, WidgetRef ref, BuildContext context) {
  return BuildAllContent(scrollController, ref, context);
}

Widget BuildAllContent(
    ScrollController scrollController, WidgetRef ref, BuildContext context) {
  return Column(
    children: [
      SizedBox(height: 10.h),
      PullUpBar(context),
      SizedBox(height: 10.h),
      ref.watch(UserProvider) != null
          ? Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                controller: scrollController,
                children: [
                  BuildSearchContainer(ref, context),
                  SizedBox(height: 10.h),
                  // Show saved places row
                  buildSavedPlacesRow(
                      ref.watch(UserProvider)!.savedPlaces, ref, context),

                  // Show recent places list
                  buildPlacesList(ref.watch(UserProvider)!.recentPlaces,
                      scrollController, ref, context),
                ],
              ),
            )
          : Padding(
              padding: EdgeInsets.symmetric(horizontal: 27.w),
              child: LoadingLine(true, context),
            ),
    ],
  );
}

Widget buildPlacesList(List<AddressModel>? RecentPlaces,
    ScrollController scrollController, ref, BuildContext context) {
  // Ensure we handle the case where RecentPlaces is null or empty
  if (RecentPlaces == null || RecentPlaces.isEmpty) {
    return NoRecentPlaces(ref, context); // Show "No Recent Places" UI
  }

  return buildRecentList(
    RecentPlaces,
    onTap: (place) => GotoPricePage(place, ref),
    context,
  );
}

Widget PullUpBar(BuildContext context) {
  return Container(
    width: 40.w,
    height: 5.h,
    decoration: BoxDecoration(
      color: Themes.gray3(context),
      borderRadius: BorderRadius.circular(2.5.r),
    ),
  );
}

Widget BuildSearchContainer(WidgetRef ref, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: GestureDetector(
      onTap: () {
        ref.read(showBottomNavProvider.notifier).update((_) => false);
        ref.read(panelIndexProvider.notifier).update((_) => 1);
      }, // Action when tapped
      child: Container(
        height: 60.7, // Matches TextField height
        decoration: BoxDecoration(
            color: Themes.white2(context),
            borderRadius: BorderRadius.circular(17.r),
            boxShadow: boxShadow(context)),
        child: Row(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Icon(
                Icons.search,
                size: 28,
                color: Themes.black3(context),
              ),
            ),
            Expanded(
              child: Text(
                "Where are you going",
                style: Themes.subtitleText(context).copyWith(
                  color: Themes.gray3(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget buildSavedPlacesRow(Map<String, AddressModel> savedPlaces, WidgetRef ref,
    BuildContext context) {
  final lowerCasedPlaces = {
    for (var entry in savedPlaces.entries) entry.key.toLowerCase(): entry.value
  };

  final fixedLabels = ['home', 'work'];
  final dynamicLabels = lowerCasedPlaces.keys
      .where((label) => !fixedLabels.contains(label))
      .toList();

  final allLabels = [...fixedLabels, ...dynamicLabels];

  return Padding(
    padding: const EdgeInsets.only(left: 20, right: 20),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: allLabels.map((label) {
          final lowerLabel = label.toLowerCase();
          final address = lowerCasedPlaces[lowerLabel];

          IconData icon;
          switch (lowerLabel) {
            case 'home':
              icon = Icons.home_rounded;
              break;
            case 'work':
              icon = Icons.work_rounded;
              break;
            default:
              icon = Icons.location_on_rounded;
          }

          return PlaceTile(
            label: lowerLabel[0].toUpperCase() + lowerLabel.substring(1),
            icon: icon,
            onTap: () => onTapSavedPlaces(address, ref, lowerLabel, context),
            context: context,
          );
        }).toList(),
      ),
    ),
  );
}

void onTapSavedPlaces(AddressModel? address, WidgetRef ref, String lowerLabel,
    BuildContext context) {
  if (address != null) {
    GotoPricePage(address, ref);
  } else {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PlaceSearchScreen(
          PlaceName: lowerLabel[0].toUpperCase() + lowerLabel.substring(1),
          CustomPlaceName: false,
        ),
      ),
    );
  }
}

Widget NoRecentPlaces(WidgetRef ref, BuildContext context) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.w),
    child: Container(
      height: 100.h, // Matches TextField height
      decoration: BoxDecoration(
          color: Themes.white2(context),
          borderRadius: BorderRadius.circular(17.r),
          boxShadow: boxShadow(context)),
      child: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: 'No Recent Places\n',
                  style: Themes.headline3(context)
                      .copyWith(color: Themes.fire_red)),
              TextSpan(
                  text: 'Get Started With Zion',
                  style: Themes.headline3(context)),
            ],
          ),
        ),
      ),
    ),
  );
}
