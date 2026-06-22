import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/snackBar.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/models/user_model.dart';
import 'package:zion3/theme.dart';

class PlaceDetailsScreen extends ConsumerStatefulWidget {
  final String placeKey;
  final AddressModel model;

  const PlaceDetailsScreen({
    super.key,
    required this.placeKey,
    required this.model,
  });

  @override
  ConsumerState<PlaceDetailsScreen> createState() => _PlaceDetailsScreenState();
}

class _PlaceDetailsScreenState extends ConsumerState<PlaceDetailsScreen> {
  bool _isDeleting = false;

  /// 🔥 UI-SIDE handler (SAFE)
  Future<void> _handleDeleteSavedPlace() async {
    setState(() => _isDeleting = true);

    try {
      await _deleteCustomSavedPlace(
        ref: ref,
        placeKey: widget.placeKey,
      );

      if (!mounted) return;

      showCustomSnackBar(
        context,
        "Deleted place successfully",
        backgroundColor: Themes.tree_green,
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      showCustomSnackBar(
        context,
        "Failed to delete place. Please try again.",
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
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
          widget.placeKey,
          style: Themes.headline2(context).copyWith(
            fontSize: 24.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 12.h),

          /// 📍 Location Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w),
            child: Container(
              decoration: BoxDecoration(
                color: Themes.white0(context),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: boxShadow(context),
              ),
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
                            widget.model.Place_name ?? "Unnamed place",
                            style: Themes.subtitleText(context).copyWith(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            widget.model.Place_name_sec ?? "",
                            style: Themes.subtitlesubText(context)
                                .copyWith(fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          /// ❌ Delete Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: customButton(
              onPressed: _isDeleting ? null : _handleDeleteSavedPlace,
              text: "Delete Place",
              isLoading: _isDeleting,
              backgroundColor: Themes.fire_red,
              context: context,
            ),
          ),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

Future<void> _deleteCustomSavedPlace({
  required WidgetRef ref,
  required String placeKey,
}) async {
  final user = ref.read(UserProvider);
  final uid = user?.uid;

  if (uid == null || placeKey.isEmpty) {
    throw Exception("Invalid user or place key");
  }

  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);

  await docRef.update({
    'SavedPlaces.$placeKey': FieldValue.delete(),
  });

  final updatedPlaces = {...user!.savedPlaces};
  updatedPlaces.remove(placeKey);

  ref.read(UserProvider.notifier).setUser(
        user.copyWith(savedPlaces: updatedPlaces),
      );
}
