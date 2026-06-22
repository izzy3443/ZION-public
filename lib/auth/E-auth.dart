import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zion3/UI/snackBar.dart';

void handleFirebaseAuthException(
  BuildContext context,
  FirebaseAuthException e,
) {
  switch (e.code) {
    case 'invalid-verification-code':
      showCustomSnackBar(context, 'Incorrect OTP. Try again.',
          icon: Icons.error);
      break;
    case 'session-expired':
      showCustomSnackBar(context, 'OTP expired. Request a new code.',
          icon: Icons.schedule);
      break;
    case 'user-disabled':
      showCustomSnackBar(context, 'Account disabled. Contact support.',
          icon: Icons.block);
      break;
    case 'invalid-verification-id':
      showCustomSnackBar(context, 'Session error. Try signing in again.',
          icon: Icons.warning);
      break;
    case 'invalid-phone-number':
      showCustomSnackBar(context, 'Invalid phone number format.',
          icon: Icons.phone_disabled);
      break;
    case 'too-many-requests':
      showCustomSnackBar(
          context, 'Too many requests. Please wait a few minutes.',
          icon: Icons.access_time);
      break;
    case 'quota-exceeded':
      showCustomSnackBar(
          context, 'You’ve reached the SMS limit. Try again later.',
          icon: Icons.sms_failed);
      break;
    case 'network-request-failed':
      showCustomSnackBar(context, 'Please check your internet connection.',
          icon: Icons.wifi_off);
      break;
    default:
      showCustomSnackBar(context, 'Something went wrong',
          icon: Icons.error_outline);
  }
}
