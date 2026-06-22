import 'dart:convert';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:zion3/global/keys.dart';
import 'package:zion3/models/address_model.dart';

class API {
  static Future send_req_to_Api(String apiUrl) async {
    final http.Response responceFromApi = await http.get(Uri.parse(apiUrl));

    try {
      if (responceFromApi.statusCode == 200) {
        final String dataFromApi = responceFromApi.body;
        return jsonDecode(dataFromApi);
      } else {
        throw 'Unexpected Error: ${responceFromApi.statusCode}';
      }
    } catch (errorMSG) {
      return 'Unexpected Error';
    }
  }

//   Future<AddressModel?> convertGeoToHumanReadable(LatLng position) async {
//     try {
//       // String humanReadAddress = '';
//       // final String apikeyios = Config.get("GOOGLE_MAPS_API_KEY");

//       // final String geoApiUrl =
//       //     'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apikeyios';

//       // // Send the request to the API
//       // var responseFromApi = await send_req_to_Api(geoApiUrl);

//       // final status = responseFromApi['status'];

//       // if (status != "OK") {
//       //   switch (status) {
//       //     case 'ZERO_RESULTS':
//       //       throw 'No address found for this location.';
//       //     case 'REQUEST_DENIED':
//       //       throw 'Request denied. Please check your API key or permissions.';
//       //     default:
//       //       throw 'Failed fetching address';
//       //   }
//       // }

//       // if (responseFromApi['results'] != null &&
//       //     responseFromApi['results'].isNotEmpty) {
//       //   humanReadAddress = responseFromApi['results'][0]['formatted_address'];
//       //   return AddressModel(
//       //     Place_name: humanReadAddress,
//       //     lat: position.latitude,
//       //     long: position.longitude,
//       //   );
//       // } else {
//       //   throw 'No address data found.';
//       // }
//     } catch (e) {
//       print(' THIS SISISISISIS THE MAINNNNN ERROROROROROROR BELOWOWOWOWOW');
//       print(e);

//       // This ensures only user-friendly messages go back up
//       throw 'Weak internet connection Failed to fetch address.';
//     }
//   }
// }

  Future<AddressModel?> convertGeoToHumanReadable(LatLng position) async {
    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('convertGeoToHumanReadable')
          .call({
        "lat": position.latitude,
        "lng": position.longitude,
      });

      final data = result.data;

      return AddressModel(
        Place_name: data['placeName'],
        lat: data['lat'],
        long: data['lng'],
      );
    } catch (e) {
      throw 'Weak internet connection Failed to fetch address.';
    }
  }
}
