import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zion3/features&calls/api_geo.dart';
import 'package:zion3/global/keys.dart';
import 'package:zion3/models/address_model.dart';
import 'package:zion3/models/predection_model.dart';
import 'package:zion3/models/user_model.dart';

String mapGooglePlacesError(dynamic status) {
  switch (status) {
    case 'REQUEST_DENIED':
      return 'API request denied. Check API key or billing.';
    case 'OVER_QUERY_LIMIT':
      return 'You have exceeded the request limit. Try again later.';
    case 'NOT_FOUND':
      return 'Place not found.';
    case 'ZERO_RESULTS':
      return 'No places found.';
    case 'INVALID_REQUEST':
      return 'Invalid request sent to Google.';
    default:
      return 'Something went wrong. Please try again.';
  }
}

final StateProvider<bool> isSuggestionsLoading =
    StateProvider<bool>((ref) => false);

// Future<void> fetchPlaceSuggestions(
//   String input,
//   WidgetRef ref,
//   BuildContext context,
//   AutoDisposeStateProvider<List<PredectionModel>> provider,
// ) async {
//   if (input.length < 2) {
//     print("Please enter more than 2 letters.");
//     return;
//   }
//   final String apikeyios = Config.get("GOOGLE_MAPS_API_KEY");
//   ref.read(isSuggestionsLoading.notifier).state = true;
//   final String apiPlaces =
//       'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(input)}&key=$apikeyios&components=country:in&location=17.4065,78.4772&radius=177000';

//   try {
//     final response = await API.send_req_to_Api(apiPlaces);
//     final status = response['status'];

//     if (status == 'OK') {
//       final List<PredectionModel> placesList = (response['predictions'] as List)
//           .map((e) => PredectionModel.fromJson(e))
//           .toList();
//       ref.read(provider.notifier).update((state) => placesList);
//       ref.read(isSuggestionsLoading.notifier).state = false;
//     } else {
//       ref.read(isSuggestionsLoading.notifier).state = false;
//       throw Exception(mapGooglePlacesError(status));
//     }
//   } catch (e) {
//     rethrow;
//   }
// }

// Future<AddressModel> fetchPlaceIdDetails(String placeId, String secText) async {
//   final String apikeyios = Config.get("GOOGLE_MAPS_API_KEY");
//   try {
//     String uriPlaceDetails =
//         "https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apikeyios";
//     var response = await API.send_req_to_Api(uriPlaceDetails);
//     final status = response["status"];
//     if (status == "OK") {
//       return AddressModel(
//           lat: response["result"]["geometry"]["location"]["lat"],
//           long: response["result"]["geometry"]["location"]["lng"],
//           Place_name: response["result"]["name"],
//           Place_name_sec: secText,
//           place_id: placeId);
//     } else {
//       throw Exception(mapGooglePlacesError(status));
//     }
//   } catch (e) {
//     // showCustomSnackBar(
//     //     context, 'Something went wrong. Please try again later.');
//     rethrow;
//   }
// }

Future<AddressModel> fetchPlaceIdDetails(String placeId, String secText) async {
  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('fetchPlaceIdDetails')
        .call({
      "placeId": placeId,
      "secText": secText,
    });

    return AddressModel.fromJson(result.data);
  } catch (e) {
    rethrow; // same behavior as before
  }
}

Future<void> fetchPlaceSuggestions(
  String input,
  WidgetRef ref,
  BuildContext context,
  AutoDisposeStateProvider<List<PredectionModel>> provider,
) async {
  if (input.length < 2) return;

  ref.read(isSuggestionsLoading.notifier).state = true;

  try {
    final result = await FirebaseFunctions.instance
        .httpsCallable('fetchPlaceSuggestions')
        .call({"input": input});

    // final List places = result.data;

    // final placesList = places.map((e) => PredectionModel.fromJson(e)).toList();
    final List<dynamic> places = result.data;

    final placesList = places.map((e) {
      return PredectionModel.fromJson(
        Map<String, dynamic>.from(e as Map),
      );
    }).toList();
    ref.read(provider.notifier).state = placesList;
  } catch (e) {
    rethrow; // same behavior as before
  } finally {
    ref.read(isSuggestionsLoading.notifier).state = false;
  }
}

Future<void> addToRecentPlace_C(AddressModel address, WidgetRef ref) async {
  final functions = FirebaseFunctions.instance;
  final callable = functions.httpsCallable('StartDestAddRecentPlaces');

  final userId = ref.read(UserProvider)!.uid;

  final response = await callable.call({
    "userId": userId,
    "address": address.toMap(),
  });
  // add it locally also ig might be helpful... is it needed idk...

  if (response.data["status"] == "success") {
    ref.read(UserProvider.notifier).addRecentPlace(address);
  } else {
    throw Exception("Failed to add recent place");
  }
}
