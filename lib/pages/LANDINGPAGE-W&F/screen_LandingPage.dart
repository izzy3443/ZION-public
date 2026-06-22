import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:zion3/pages/LANDINGPAGE-W&F/screen_HOMEMAP.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/screen_Price_Page.dart';

import 'package:zion3/main.dart';
import 'package:zion3/pages/HOMEPAGE_W&F/screen_homePage.dart';

import 'package:zion3/pages/RIDE_W&F/Ride_main.dart';
import 'package:zion3/pages/START_DEST_W&F/screen_CustomMarker.dart';
import 'package:zion3/pages/START_DEST_W&F/screen_start_dest.dart';

final googleMapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

class Homepage extends StatelessWidget {
  const Homepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const HomeMap(),
          Consumer(
            builder: (_, ref, __) {
              final pageIndex = ref.watch(panelIndexProvider);
              return Align(
                alignment: Alignment.bottomCenter,
                child: _buildSelectedPage(ref, pageIndex),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedPage(WidgetRef ref, int index) {
    switch (index) {
      case 0:
        return const HomepageFrontend();
      case 1:
        return const StartDestPage();
      case 2:
        return const Price_Page();
      case 3:
        return const RideSheet();
      case 4:
        return const ConfirmLocationSheet();
      default:
        return const SizedBox();
    }
  }
}
