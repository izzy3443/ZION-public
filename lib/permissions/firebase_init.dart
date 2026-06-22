import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:zion3/firebase_options.dart';

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDMyc-lwsfqFFI681nz_0b1lmOTQB4iU2s',
        authDomain: 'zion3-e453d.firebaseapp.com',
        projectId: 'zion3-e453d',
        storageBucket: 'zion3-e453d.appspot.com',
        messagingSenderId: '259667167780',
        appId: '1:259667167780:web:28724911ca32e7e4a966b1',
        measurementId: 'G-43NMS2CDRT',
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
