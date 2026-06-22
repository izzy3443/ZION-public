import 'package:flutter_riverpod/flutter_riverpod.dart';

StateProvider<String> fairAmountDisplayProvider =
    StateProvider<String>((ref) => '');
bool? Location_permission_Status;
String state_of_app = "normal";

class DriverTripInfo {
  final String uid;
  final String name;
  final String phone;
  final String photo;
  final String vehicleDetails;
  final String vehicleNumber;
  final String vehicleType; // <-- NEW
  final String fareAmount;
  final String otp;
  final double rating;

  DriverTripInfo({
    required this.uid,
    required this.name,
    required this.phone,
    required this.photo,
    required this.vehicleDetails,
    required this.vehicleNumber,
    required this.vehicleType, // <-- NEW
    required this.fareAmount,
    required this.otp,
    required this.rating,
  });

  factory DriverTripInfo.fromMap(Map<String, dynamic> data) {
    return DriverTripInfo(
      uid: data["Uid"] ?? "",
      name: '${data["firstName"] ?? ""} ${data["lastName"] ?? ""}',
      phone: data["PhoneNo"] ?? "",
      photo: data["ProfilePic"] ?? "",
      vehicleDetails: data["VehicleDetails"] ?? "",
      vehicleNumber: data["VehicleNumberPlate"] ?? "",
      vehicleType: data["VehicleType"] ?? "",
      fareAmount: data["FareAmount"]?.toString() ?? "",
      otp: data["Otp"] ?? "",
      rating: (data["Rating"] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "DriverId": uid,
      "DriverName": name,
      "DriverPhone": phone,
      "DriverPhoto": photo,
      "VehicleDetails": vehicleDetails,
      "VechicleNumberPlate": vehicleNumber,
      "VehicleType": vehicleType, // <-- NEW
      "FareAmount": fareAmount,
      "Otp": otp,
      "Rating": rating,
    };
  }
}

class DriverTripInfoNotifier extends StateNotifier<DriverTripInfo?> {
  DriverTripInfoNotifier() : super(null);

  void setDriverDetailsFromMap(Map<String, dynamic> data) {
    state = DriverTripInfo.fromMap(data);
  }

  void setFareAndOtp({required String fareAmount, required String otp}) {
    if (state == null) return;
    state = DriverTripInfo(
      uid: state!.uid,
      name: state!.name,
      phone: state!.phone,
      photo: state!.photo,
      vehicleDetails: state!.vehicleDetails,
      vehicleNumber: state!.vehicleNumber,
      rating: state!.rating,
      vehicleType: state!.vehicleType,
      fareAmount: fareAmount,
      otp: otp,
    );
  }

  void clear() {
    state = null;
  }
}

final driverTripInfoProvider =
    StateNotifierProvider<DriverTripInfoNotifier, DriverTripInfo?>(
  (ref) => DriverTripInfoNotifier(),
);
