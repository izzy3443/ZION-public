import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/main.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/UI/smallUI.dart';
import 'package:zion3/pages/START_DEST_W&F/provider_CustomMarker.dart';
import 'package:zion3/theme.dart';

Widget buildRecentList(
  List<AddressModel> recentPlaces,
  BuildContext context, {
  Function(AddressModel)? onTap,
}) {
  if (recentPlaces.isEmpty) {
    return const SizedBox(); // Handle empty case
  }
  return Column(
    children: List.generate(recentPlaces.length, (index) {
      final place = recentPlaces[index];
      return GestureDetector(
        onTap: () => onTap?.call(place), // Pass the place map when tapped
        child: reusableListItem(
            icon: Icons.history_outlined,
            title: place.Place_name ?? "Unknown Place",
            subtitle: place.Place_name_sec ?? "Unknown Place",
            iconColor: Themes.fire_red,
            context: context),
      );
    }),
  );
}

GotoPricePage(AddressModel place, WidgetRef ref) async {
  // Handle the tap event here
  AddressModel model = place;
  ref.read(addressProvider.notifier).add_dropoff(model);
  ref.read(showBottomNavProvider.notifier).update((state) => false);
  if (ref.read(addressProvider).pickup == null) {
    ref.read(panelIndexProvider.notifier).update((_) => 1);
  } else {
    isConfirm = true;
    isPickupActive = true;
    ref.read(panelIndexProvider.notifier).update((_) => 4);
  }
}
