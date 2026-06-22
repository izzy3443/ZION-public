import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/models/user_model.dart';

// Firebase instances
final FirebaseAuth auth = FirebaseAuth.instance;
final FirebaseFirestore firestore = FirebaseFirestore.instance;

// Riverpod provider
final authProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService(auth, firestore);
});

/// What the UI should do AFTER auth
enum AuthNextStep {
  uploadProfile,
  goToHome,
}

class FirebaseAuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseAuthService(this._auth, this._firestore);

  // ----------------------------------
  // PHONE SIGN IN (NO CONTEXT)
  // ----------------------------------
  Future<void> phoneSignIn({
    required String phoneNumber,
    required void Function(AuthCredential credential) onAutoVerified,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,

        // Auto verification (Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          onAutoVerified(credential);
        },

        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },

        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },

        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  // ----------------------------------
  // SIGN IN + CHECK USER STATUS
  // ----------------------------------
  Future<AuthNextStep?> signInAndCheckStatus(
    AuthCredential credential,
    WidgetRef ref,
  ) async {
    final UserCredential userCredential =
        await _auth.signInWithCredential(credential);

    final User? user = userCredential.user;
    if (user == null) return null;

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _firestore.collection('users').doc(user.uid).get();

    // NEW USER
    if (!doc.exists) {
      await _createNewUser(user, ref);
      return AuthNextStep.uploadProfile;
    }

    // EXISTING USER
    final data = doc.data();
    final firstName = data?['firstName'];

    if (firstName == null || firstName.isEmpty) {
      return AuthNextStep.uploadProfile;
    }

    return AuthNextStep.goToHome;
  }

  // ----------------------------------
  // CREATE USER
  // ----------------------------------
  Future<void> _createNewUser(User user, WidgetRef ref) async {
    final Map<String, dynamic> userData = {
      'Uid': user.uid,
      'firstName': user.displayName ?? '',
      'lastName': '',
      'PhoneNo': user.phoneNumber ?? '',
      'Email': user.email ?? '',
      'TripStatus': 'NONE',
      'BlockStatus': 'no',
      'TotalKms': 0,
      'TotalMin': 0,
      'Trips': [],
      'SavedPlaces': {},
    };

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(userData, SetOptions(merge: true));

    ref.read(UserProvider.notifier).setUser(
          AppUser.fromMap(userData),
        );
  }
}
