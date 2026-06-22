import 'package:flutter_riverpod/flutter_riverpod.dart';

final TripDetailsLoaded = StateProvider<bool>((ref) => false);
final StateProvider<bool> RidesubDetailsLoading =
    StateProvider<bool>((ref) => false);
