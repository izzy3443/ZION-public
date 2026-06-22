import 'package:flutter_riverpod/flutter_riverpod.dart';

// AddressModel class definition
class AddressModel {
  String? Place_name_sec;
  double? lat;
  double? long;
  String? Place_name;
  String? place_id;

  AddressModel(
      {this.lat,
      this.long,
      this.Place_name,
      this.Place_name_sec,
      this.place_id});

  Map<String, dynamic> toMap() {
    return {
      "Place_name": Place_name ?? "none",
      "Place_name_sec": Place_name_sec ?? "none",
      "lat": lat,
      "long": long,
      "place_id": place_id,
    };
  }

  AddressModel.fromMap(Map<String, dynamic> Map) {
    Place_name = Map["Place_name"];
    Place_name_sec = Map['Place_name_sec'];
    place_id = Map['place_id'];
    lat = Map['lat'];
    long = Map['long'];
  }
  factory AddressModel.fromJson(Map<dynamic, dynamic> json) {
    return AddressModel.fromMap(Map<String, dynamic>.from(json));
  }
}

// appinfo class definition
class appinfo {
  AddressModel? pickup;
  AddressModel? dropoff;
  AddressModel? currentLocation;

  appinfo({this.pickup, this.dropoff, this.currentLocation});

  appinfo copyWith({
    AddressModel? pickup,
    AddressModel? dropoff,
    AddressModel? currentLocation,
  }) {
    return appinfo(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      currentLocation: currentLocation ?? this.currentLocation,
    );
  }

  @override
  String toString() => 'appinfo(pickup: $pickup, dropoff: $dropoff)';

  @override
  bool operator ==(covariant appinfo other) {
    if (identical(this, other)) return true;

    return other.pickup == pickup && other.dropoff == dropoff;
  }

  @override
  int get hashCode => pickup.hashCode ^ dropoff.hashCode;
}

// Appinfonotifer class definition
class Appinfonotifer extends StateNotifier<appinfo> {
  Appinfonotifer() : super(appinfo());

  void add_pickup(AddressModel pickup) {
    state = state.copyWith(pickup: pickup);
  }

  void add_dropoff(AddressModel dropoff) {
    state = state.copyWith(dropoff: dropoff);
  }

  void Location(AddressModel currentLocation) {
    state = state.copyWith(currentLocation: currentLocation);
  }
}
