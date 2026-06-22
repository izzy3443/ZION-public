import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart'; // 🔥 ADD
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zion3/global/keys.dart';
import 'package:zion3/global/paths.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/pages/MainPage.dart';
import 'package:zion3/pages/LOGIN-W&F/screen_getStartedPage.dart';
import 'package:zion3/permissions/firebase_init.dart';
import 'package:zion3/permissions/geo_location.dart';
import 'package:zion3/permissions/notification_permission.dart';
import 'package:zion3/splashScreen.dart';

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final showBottomNavProvider = StateProvider<bool>((ref) => true);

final addressProvider = StateNotifierProvider<Appinfonotifer, appinfo>((ref) {
  return Appinfonotifer();
});

final pageIndexProvider = StateNotifierProvider<PageIndexNotifier, int>((ref) {
  return PageIndexNotifier();
});

class PageIndexNotifier extends StateNotifier<int> {
  PageIndexNotifier() : super(0);

  void setPageIndex(int index) {
    state = index;
  }
}

Future<void> preloadMapStyles() async {
  lightMapStyle =
      await rootBundle.loadString('assets/map_styles/light_map_style.json');
  darkMapStyle =
      await rootBundle.loadString('assets/map_styles/dark_map_style.json');
}

final panelIndexProvider = StateProvider<int>((ref) => 0);

/// 🔥 MAIN ENTRY POINT WITH CRASHLYTICS + APP CHECK
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  /// 🔐 APP CHECK (DEBUG MODE FOR DEVELOPMENT)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  /// 🔥 Enable Crashlytics
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);

  /// Catch Flutter framework errors
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  /// Catch async errors
  runZonedGuarded(() {
    runApp(
      const ProviderScope(child: AppRoot()),
    );
  }, (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

/// Root with ScreenUtil
class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(414, 896),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return const MyApp();
      },
    );
  }
}

/// Splash-aware App
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  Future<void> initializeApp() async {
    try {
      await initializeFirebase();
      await requestNotificationPermission();
      await requestLocationPermission();
      await preloadMapStyles();

      setState(() => isLoading = false);
    } catch (e, stack) {
      FirebaseCrashlytics.instance.recordError(e, stack, fatal: true);
    }
  }

  Widget authCheck() {
    if (FirebaseAuth.instance.currentUser == null) {
      return const GetStartedPage();
    } else {
      return const MainPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: isLoading ? const SplashScreen() : authCheck(),
    );
  }
}
