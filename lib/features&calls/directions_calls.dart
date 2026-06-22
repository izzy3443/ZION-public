import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:zion3/features&calls/api_geo.dart';
import 'package:zion3/global/keys.dart';
import 'package:zion3/models/directions_model.dart';

// Future<DirectionsModel> getDirectionDetailsFromApi(
//     LatLng source, LatLng destination) async {
//   final String apikeyios = Config.get("GOOGLE_MAPS_API_KEY");
//   final String urlDirectionsApi =
//       'https://maps.googleapis.com/maps/api/directions/json?destination=${destination.latitude},${destination.longitude}&origin=${source.latitude},${source.longitude}&mode=driving&key=$apikeyios';

//   final responseFromDirectionApi = await API.send_req_to_Api(urlDirectionsApi);

//   final status = responseFromDirectionApi['status'];

//   if (responseFromDirectionApi['status'] == 'OK') {
//     final leg = responseFromDirectionApi['routes'][0]['legs'][0];

//     final DirectionsModel detailsModel = DirectionsModel();
//     detailsModel.distanceTextString = leg['distance']['text'];
//     detailsModel.distanceValueDigits = leg['distance']['value'];
//     detailsModel.durationTextString = leg['duration']['text'];
//     detailsModel.durationValueDigits = leg['duration']['value'];
//     detailsModel.encodedPoints =
//         responseFromDirectionApi['routes'][0]['overview_polyline']['points'];

//     return detailsModel;
//   }
//   switch (status) {
//     case 'NOT_FOUND':
//       throw 'Invalid pickup or drop-off location';
//     case 'ZERO_RESULTS':
//       throw 'No route could be found between these locations.';
//     case 'OVER_QUERY_LIMIT':
//       throw 'Too many requests. Try again later.';
//     case 'REQUEST_DENIED':
//       throw 'Request denied';
//     default:
//       throw 'Unable to fetch directions';
//   }
// }

Future<DirectionsModel> getDirectionDetailsFromApi(
    LatLng source, LatLng destination) async {
  final result = await FirebaseFunctions.instance
      .httpsCallable('getDirectionDetailsFromApi')
      .call({
    "source": {
      "lat": source.latitude,
      "lng": source.longitude,
    },
    "destination": {
      "lat": destination.latitude,
      "lng": destination.longitude,
    },
  });

  return DirectionsModel.fromJson(result.data);
}
