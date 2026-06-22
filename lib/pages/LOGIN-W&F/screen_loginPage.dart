import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zion3/UI/Button.dart';
import 'package:zion3/UI/TextFieldZero.dart';
import 'package:zion3/UI/snackBar.dart';

import 'package:zion3/auth/firebase_auth2.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_otpPage.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_upload.dart';
import 'package:zion3/pages/MainPage.dart';

import 'package:zion3/theme.dart';

final AutoDisposeStateProvider<bool> isButtonLoadingProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class MobileVerificationPage extends ConsumerStatefulWidget {
  const MobileVerificationPage({super.key});

  @override
  ConsumerState<MobileVerificationPage> createState() =>
      _MobileVerificationPageState();
}

class _MobileVerificationPageState
    extends ConsumerState<MobileVerificationPage> {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final AutoDisposeStateProvider<bool> isButtonEnabledProvider =
      StateProvider.autoDispose<bool>((ref) => false);

  @override
  void dispose() {
    phoneController.dispose();
    phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Auto-focus the phone field when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(phoneFocusNode);
    });

    // Add listener to check phone number length and update button state
    phoneController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    ref
        .read(isButtonEnabledProvider.notifier)
        .update((state) => phoneController.text.length == 10);
  }

  void _onContinuePressed() async {
    if (!ref.read(isButtonEnabledProvider)) return;

    ref.read(isButtonLoadingProvider.notifier).update((_) => true);

    final authService = ref.read(authProvider);

    await authService.phoneSignIn(
      phoneNumber: '+91${phoneController.text}',
      onAutoVerified: (credential) async {
        await _handleAuthResult(credential);
      },
      onCodeSent: (verificationId) {
        if (!mounted) return;

        ref.read(isButtonLoadingProvider.notifier).update((_) => false);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(
              phoneNumber: phoneController.text,
              verificationId: verificationId,
            ),
          ),
        );
      },
      onError: (error) {
        showCustomSnackBar(context, error.toString());
        if (!mounted) return;
        ref.read(isButtonLoadingProvider.notifier).update((_) => false);
        // show snackbar
      },
    );
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
    final isButtonAccepted = ref.watch(isButtonEnabledProvider);

    return Scaffold(
      backgroundColor: Themes.white0(context),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),
              Text("Let's Get Started", style: Themes.headline3(context)),
              SizedBox(height: 10.h),
              Text(
                "You will receive an SMS with a verification code on this number",
                style: Themes.subtitlesubText(context),
              ),
              SizedBox(height: 12.h),
              textFieldZero(
                phoneController,
                "Enter your mobile",
                context,
                10,
                focusNode: phoneFocusNode,
              ),
              const Spacer(flex: 3),
              customButton(
                onPressed: _onContinuePressed,
                text: "Continue",
                backgroundColor:
                    isButtonAccepted ? Themes.fire_red : Themes.gray3(context),
                isLoading: ref.watch(isButtonLoadingProvider),
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
