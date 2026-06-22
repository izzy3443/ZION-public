import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const CameraPosition googleplexintitalposition = CameraPosition(
    bearing: 192.8334901395799,
    target: LatLng(37.43296265331129, -122.08832357078792),
    tilt: 59.440717697143555,
    zoom: 19.151926040649414);

// class Config {
//   static Map<String, dynamic>? _config;

//   static Future<void> load(String env) async {
//     final data = await rootBundle.loadString('assets/config/$env.json');
//     _config = json.decode(data);
//   }

//   static String get(String key) {
//     if (_config == null) {
//       throw Exception("Config not loaded. Call Config.load() first.");
//     }
//     return _config![key];
//   }
// }
