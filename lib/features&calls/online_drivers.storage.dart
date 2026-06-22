import 'package:cloud_firestore/cloud_firestore.dart';

class OnlineNearByDrivers {
  final String uid_driver;
  final double lat_driver;
  final double long_driver;

  OnlineNearByDrivers({
    required this.uid_driver,
    required this.lat_driver,
    required this.long_driver,
  });
}

class ManageDriversMethods {
  static List<OnlineNearByDrivers> nearby_drivers_list = [];
  ///////////////////
  static void clear() {
    nearby_drivers_list.clear();
  }

  static void add(DocumentSnapshot doc, GeoPoint geo) {
    nearby_drivers_list.add(
      OnlineNearByDrivers(
        uid_driver: doc.id,
        lat_driver: geo.latitude,
        long_driver: geo.longitude,
      ),
    );
  }
}
