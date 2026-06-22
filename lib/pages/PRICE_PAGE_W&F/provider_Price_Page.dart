import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/pages/PRICE_PAGE_W&F/utils_Price_Page.dart';

final selectedRideProvider = StateProvider<RideOption?>((ref) => null);

final noDriverFoundProvider = StateProvider<bool>((ref) => false);
final dataFetchingProvider = StateProvider<bool>((ref) => false);
//77.7
