import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/snackBar.dart';

import 'package:zion3/pages/RIDE_W&F/controller_Ride_mainn.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/predection_model.dart';
import 'package:zion3/pages/START_DEST_W&F/provider_CustomMarker.dart';
import 'package:zion3/pages/START_DEST_W&F/provider_start_dest.dart';

import 'package:zion3/pages/START_DEST_W&F/controller_start_dest.dart';
import 'package:zion3/pages/START_DEST_W&F/widget_start_dest_1.dart';
import 'package:zion3/pages/START_DEST_W&F/widget_start_dest_2.dart';
import 'package:zion3/pages/START_DEST_W&F/widget_start_dest_3.dart';

import 'package:zion3/theme.dart';

class StartDestPage extends ConsumerStatefulWidget {
  const StartDestPage({super.key});

  @override
  ConsumerState<StartDestPage> createState() => _StartDestPageState();
}

class _StartDestPageState extends ConsumerState<StartDestPage> {
  final FocusNode dropOffFocusNode = FocusNode();
  final FocusNode pickUpFocusNode = FocusNode();

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController dropoffController = TextEditingController();

  String placeholder = "";
  Timer? _debounce;

  @override
  @override
  void initState() {
    super.initState();

    // Hide bottom nav once (no rebuild issue)
    ref.read(showBottomNavProvider.notifier).state = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final address = ref.read(addressProvider);

      // Restore text fields
      pickupController.text = address.pickup?.Place_name ?? '';
      dropoffController.text = address.dropoff?.Place_name ?? '';

      if (address.pickup == null) {
        // PICKUP FLOW
        isPickupActive = true;
        placeholder = "Pickup";

        if (Location_permission_Status == false) {
          pickupController.clear();
          placeholder = "PickUp \n! Please grant location access";
        }

        FocusScope.of(context).requestFocus(pickUpFocusNode);
      } else if (address.dropoff == null) {
        // DROPOFF FLOW
        isPickupActive = false;
        placeholder = "Dropoff";
        FocusScope.of(context).requestFocus(dropOffFocusNode);
      } else {
        // BOTH PRESENT
        if (isConfirm) {
          ref.read(panelIndexProvider.notifier).state = 4;
        } else {
          isPickupActive = false;
          placeholder = "Dropoff";
          FocusScope.of(context).requestFocus(dropOffFocusNode);
        }
      }
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (value.length >= 3) {
        try {
          fetchPlaceSuggestions(
            value,
            ref,
            context,
            placeSuggestionsProvider,
          );
        } catch (e) {
          showCustomSnackBar(context, e.toString());
        }
      }
    });
  }

  void selectPlace(PredectionModel model) async {
    ref.read(isStartDestLoading.notifier).state = true;

    try {
      if (isPickupActive) {
        pickupController.text = model.main_text!;
        FocusScope.of(context).requestFocus(dropOffFocusNode);

        final pickupModel = await fetchPlaceIdDetails(
          model.place_id!,
          model.sec_text!,
        );

        ref.read(addressProvider.notifier).add_pickup(pickupModel);
        isPickupActive = false;
      } else {
        FocusScope.of(context).unfocus();
        dropoffController.text = model.main_text!;

        final dropoffModel = await fetchPlaceIdDetails(
          model.place_id!,
          model.sec_text!,
        );

        ref.read(addressProvider.notifier).add_dropoff(dropoffModel);
        isPickupActive = true;
        isConfirm = true;
        customeMarkerFunctions();
      }

      ref.read(placeSuggestionsProvider.notifier).state = [];
      ref.read(isStartDestLoading.notifier).state = false;
      final address = ref.read(addressProvider);
      if (address.pickup != null && address.dropoff != null) {
        isConfirm = true;
        isPickupActive = true;
        ref.read(panelIndexProvider.notifier).state = 4;
      }
    } catch (e) {
      if (!mounted) return;
      showCustomSnackBar(
        context,
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void customeMarkerFunctions() {
    ref.read(panelIndexProvider.notifier).update((state) => 4);
  }

  InputDecoration inputDecoration(
      String label, String hint, BuildContext context) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 14,
        fontFamily: 'outfit',
        fontWeight: FontWeight.w600,
        color: Themes.gray44(context),
      ),
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'outfit',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Themes.gray44(context),
      ),
      border: InputBorder.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: EdgeInsets.only(top: 16.h),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.9,
          ),
          decoration: BoxDecoration(
            color: Themes.white0(context),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(16.r),
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const StartDestHeader(),
              SizedBox(height: 12.h),
              Container(
                decoration: BoxDecoration(
                  color: Themes.white0(context),
                  borderRadius: BorderRadius.circular(17.r),
                  border: Border.all(
                    color: Themes.white1(context),
                    width: 4.w,
                  ),
                ),
                child: Column(
                  children: [
                    // PICKUP
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                      child: SizedBox(
                        height: 50.h,
                        child: TextField(
                          controller: pickupController,
                          focusNode: pickUpFocusNode,
                          cursorColor: Themes.black0(context),
                          style: Themes.SmallContainerText(context)
                              .copyWith(color: Themes.black0(context)),
                          decoration: inputDecoration(
                            "From",
                            "Enter PickUp",
                            context,
                          ),
                          onTap: () {
                            pickupController.clear();
                            isPickupActive = true;
                            ref.read(placeSuggestionsProvider.notifier).state =
                                [];
                          },
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),

                    Container(
                      height: 4.w,
                      color: Themes.white1(context),
                    ),

                    // DROPOFF
                    Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                      child: SizedBox(
                        height: 50.h,
                        child: TextField(
                          controller: dropoffController,
                          focusNode: dropOffFocusNode,
                          cursorColor: Themes.black0(context),
                          style: Themes.SmallContainerText(context)
                              .copyWith(color: Themes.black0(context)),
                          decoration: inputDecoration(
                            "To",
                            "Enter Dropoff",
                            context,
                          ),
                          onTap: () {
                            dropoffController.clear();
                            isPickupActive = false;
                            ref.read(placeSuggestionsProvider.notifier).state =
                                [];
                          },
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SuggestionsLoadingBar(),
              Expanded(
                child: StartDestSuggestionsList(
                  placeholder: placeholder,
                  onSelectPlace: selectPlace,
                  onIdleSelect: () => customeMarkerFunctions(),
                  isPickupActive: isPickupActive,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    pickupController.dispose();
    dropoffController.dispose();
    pickUpFocusNode.dispose();
    dropOffFocusNode.dispose();
    super.dispose();
  }
}
