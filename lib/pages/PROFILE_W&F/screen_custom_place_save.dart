import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/pages/PROFILE_W&F/controller_place_search_screen.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/theme.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/TextField.dart';

class AddPlaceDetailsScreen extends ConsumerStatefulWidget {
  final AddressModel model;

  const AddPlaceDetailsScreen({
    super.key,
    required this.model,
  });

  @override
  ConsumerState<AddPlaceDetailsScreen> createState() =>
      _AddPlaceDetailsScreenState();
}

class _AddPlaceDetailsScreenState extends ConsumerState<AddPlaceDetailsScreen> {
  final TextEditingController _placeNameController = TextEditingController();
  StateProvider<bool> isCustomPlaceLoading = StateProvider((state) => false);

  Future<void> addAddressDB() async {
    ref.read(isCustomPlaceLoading.notifier).state = true;

    try {
      await saveAddressSavedPlaces(
        ref,
        _placeNameController.text,
        widget.model,
      );

      if (!mounted) return;

      Navigator.pop(context);
    } finally {
      ref.read(isCustomPlaceLoading.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Add Place',
          style: Themes.headline2(context).copyWith(
            fontSize: 24.sp,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Address Container

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Container(
              decoration: BoxDecoration(
                  color: Themes.white0(context),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: boxShadow(context)),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Themes.fire_red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: const Icon(
                            Icons.location_on_outlined,
                            color: Themes.fire_red,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.model.Place_name!,
                                style: Themes.subtitleText(context).copyWith(
                                  fontSize: 17.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                widget.model.Place_name_sec!,
                                style: Themes.subtitlesubText(context)
                                    .copyWith(fontSize: 14.sp),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: Themes.gray3(context),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Place Name TextField
          Padding(
            padding: EdgeInsets.all(16.0.r),
            child: textField(
              _placeNameController,
              context,
              'Name this place (e.g. Home, Work, Gym)',
              icon: Icons.edit_location,
            ),
          ),

          const Spacer(),

          // Save Button
          Padding(
            padding: EdgeInsets.all(16.0.r),
            child: customButton(
                onPressed: () {
                  AddLocation();
                },
                text: 'Save Place',
                isLoading: ref.watch(isCustomPlaceLoading),
                context: context),
          ),
        ],
      ),
    );
  }

  void AddLocation() async {
    final placeName = _placeNameController.text.trim();
    if (placeName.isNotEmpty) {
      await addAddressDB();
    } else {
      showCustomSnackBar(context, "Please enter a name for this place");
    }
  }
}
