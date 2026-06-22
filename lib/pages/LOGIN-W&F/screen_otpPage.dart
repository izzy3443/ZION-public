import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/TextFieldZero.dart';
import 'package:zion3/auth/firebase_auth2.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_upload.dart';
import 'package:zion3/pages/MainPage.dart';
import 'package:zion3/theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final String verificationId;

  const OtpPage(
      {super.key, required this.phoneNumber, required this.verificationId});

  @override
  ConsumerState<OtpPage> createState() => _OtpPageState();
}

final AutoDisposeStateProvider<bool> isButtonLoadingOtpProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class _OtpPageState extends ConsumerState<OtpPage> {
  TextEditingController otpController = TextEditingController();
  final AutoDisposeStateProvider<bool> isButtonEnabledProvider =
      StateProvider.autoDispose<bool>((ref) => false);
  final FocusNode otpFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(otpFocusNode);
    });
    otpController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    ref.read(isButtonEnabledProvider.notifier).state =
        otpController.text.length == 6;
  }

  @override
  void dispose() {
    otpController.dispose();
    otpFocusNode.dispose();
    otpController.removeListener(_updateButtonState);
    super.dispose();
  }

  // void onPressFunction() async {
  //   ref.read(isButtonLoadingOtpProvider.notifier).update((state) => true);
  //   ref.read(authProvider).onOtpPressedFunctions(
  //       context, widget.verificationId, otpController, ref);
  // }

  void onPressFunction() async {
    ref.read(isButtonLoadingOtpProvider.notifier).update((_) => true);

    final credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpController.text.trim(),
    );

    await _handleAuthResult(credential);

    if (!mounted) return;
    ref.read(isButtonLoadingOtpProvider.notifier).update((_) => false);
  }

  Future<void> _handleAuthResult(AuthCredential credential) async {
    final authService = ref.read(authProvider);

    final AuthNextStep? nextStep =
        await authService.signInAndCheckStatus(credential, ref);

    if (!mounted || nextStep == null) return;

    switch (nextStep) {
      case AuthNextStep.uploadProfile:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Upload()),
        );
        break;

      case AuthNextStep.goToHome:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isButtonActive = ref.watch(isButtonEnabledProvider);
    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text(
                'Almost There!',
                style: Themes.headline3(context).copyWith(fontSize: 27.sp),
              ),
              SizedBox(height: 10.h),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Enter the code sent to your number ',
                      style: Themes.subtitlesubText(context),
                    ),
                    TextSpan(
                      text: widget.phoneNumber,
                      style: Themes.subtitle(context),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              textFieldZero(
                otpController,
                'Enter 6-digit OTP',
                context,
                6,
                focusNode: otpFocusNode,
              ),
              const Spacer(flex: 3),
              customButton(
                onPressed: isButtonActive ? onPressFunction : null,
                backgroundColor:
                    isButtonActive ? Themes.fire_red : Themes.gray3(context),
                text: "Confirm",
                isLoading: ref.watch(isButtonLoadingOtpProvider),
                context: context,
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
