import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/models/address_model.dart';

bool isPickupActive = false;
final isLoadingProvider_customMarker =
    StateProvider.autoDispose<bool>((ref) => false); // less try autodispose
final MarkerlocationModelProvider = StateProvider<AddressModel?>((ref) => null);
bool isConfirm = false;
