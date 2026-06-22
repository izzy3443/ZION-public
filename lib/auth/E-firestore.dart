import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:zion3/UI/snackBar.dart';

void handleFirestoreException(BuildContext context, dynamic error) {
  if (error is FirebaseException) {
    switch (error.code) {
      case 'permission-denied':
        showCustomSnackBar(context, 'Access denied. Please contact support.');
        break;
      case 'unavailable':
        showCustomSnackBar(context, 'No internet. Try again.');
        break;
      case 'not-found':
        showCustomSnackBar(context, 'No data found.');
        break;
      default:
        showCustomSnackBar(context, 'Something went wrong. Try again later.');
    }
  } else {
    // Non-Firebase exception
    showCustomSnackBar(context, 'Unexpected error occurred.');
  }
}
