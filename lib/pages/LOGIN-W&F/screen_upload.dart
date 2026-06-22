import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/TextField.dart';
import 'package:zion3/auth/E-firestore.dart';

import 'package:zion3/pages/LOGIN-W&F/controller_upload.dart';
import 'package:zion3/pages/MainPage.dart';
import 'package:zion3/theme.dart';

class Upload extends ConsumerStatefulWidget {
  const Upload({super.key});

  @override
  ConsumerState<Upload> createState() => _UploadState();
}

class _UploadState extends ConsumerState<Upload> {
  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    super.dispose();
  }

  Future<void> checknetwork_and_data_confirm() async {
    ref.read(isUploadLoading.notifier).state = true;

    try {
      await sendDataToDatabase(ref);

      // ✅ CORRECT mounted check
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      handleFirestoreException(context, e);
    } finally {
      ref.read(isUploadLoading.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: Padding(
        padding: EdgeInsets.all(16.0.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 47.h,
            ),
            Text(
              'First Name',
              style: Themes.subtitle(context),
            ),
            SizedBox(height: 5.h),
            textField(
              firstNameController,
              context,
              "Enter Your First Name",
            ),
            SizedBox(height: 20.h),
            Text(
              'Last Name',
              style: Themes.subtitle(context).copyWith(fontSize: 18.sp),
            ),
            SizedBox(height: 5.h),
            textField(
              lastNameController,
              context,
              "Enter Your Last Name",
            ),
            SizedBox(height: 20.h),
            customButton(
              onPressed: () => checknetwork_and_data_confirm(),
              text: "Continue",
              isLoading: ref.watch(isUploadLoading),
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}
