// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:riverpod/riverpod.dart';
import 'package:zion3/models/address_model.dart';

class AppUser {
  final String uid;
  final String firstName;
  final String lastName;
  final String phoneNo;
  final String email;
  final String blockStatus;
  final String profilePic;
  final String tripStatus;
  final int totalKms;
  final int totalMin;
  final List<AddressModel> recentPlaces;
  final Map<String, AddressModel> savedPlaces;

  AppUser({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.phoneNo,
    required this.email,
    required this.blockStatus,
    required this.profilePic,
    required this.tripStatus,
    required this.totalKms,
    required this.totalMin,
    required this.recentPlaces,
    required this.savedPlaces,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['Uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      phoneNo: map['PhoneNo'] ?? '',
      email: map['Email'] ?? '',
      blockStatus: map['BlockStatus'] ?? '',
      profilePic: map['ProfilePic'] ?? '',
      tripStatus: map['TripStatus'] ?? '',
      totalKms: map['TotalKms'] ?? 0,
      totalMin: map['TotalMin'] ?? 0,

      // Safely parse list of maps
      recentPlaces: (map['RecentPlaces'] as List<dynamic>? ?? [])
          .map((e) => AddressModel.fromMap(Map<String, dynamic>.from(e)))
          .toList(),

      // Safely parse map of maps
      savedPlaces: Map<String, dynamic>.from(map['SavedPlaces'] ?? {})
          .map((key, value) => MapEntry(
                key,
                AddressModel.fromMap(Map<String, dynamic>.from(value)),
              )),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'PhoneNo': phoneNo,
      'Email': email,
      'BlockStatus': blockStatus,
      'ProfilePic': profilePic,
      'TripStatus': tripStatus,
      'TotalKms': totalKms,
      'TotalMin': totalMin,
      'RecentPlaces': recentPlaces.map((e) => e.toMap()).toList(),
      'SavedPlaces':
          savedPlaces.map((key, value) => MapEntry(key, value.toMap())),
    };
  }

  AppUser copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? phoneNo,
    String? email,
    String? blockStatus,
    String? profilePic,
    String? tripStatus,
    int? totalKms,
    int? totalMin,
    List<AddressModel>? recentPlaces,
    Map<String, AddressModel>? savedPlaces,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNo: phoneNo ?? this.phoneNo,
      email: email ?? this.email,
      blockStatus: blockStatus ?? this.blockStatus,
      profilePic: profilePic ?? this.profilePic,
      tripStatus: tripStatus ?? this.tripStatus,
      totalKms: totalKms ?? this.totalKms,
      totalMin: totalMin ?? this.totalMin,
      recentPlaces: recentPlaces ?? this.recentPlaces,
      savedPlaces: savedPlaces ?? this.savedPlaces,
    );
  }
}

class UserNotifier extends StateNotifier<AppUser?> {
  UserNotifier() : super(null);

  void setUser(AppUser userData) {
    state = userData;
  }

  void clearUser() {
    state = null;
  }

  void addnames(String first, String last) {
    if (state == null) return;
    state = state!.copyWith(firstName: first, lastName: last);
  }

  void addSavedPlace(String key, AddressModel address) {
    if (state == null) return;

    final updatedSavedPlaces = {
      ...state!.savedPlaces,
      key: address,
    };

    state = state!.copyWith(savedPlaces: updatedSavedPlaces);
  }

  void addRecentPlace(AddressModel newPlace, {int maxPlaces = 5}) {
    if (state == null) return;

    final updatedPlaces = [newPlace, ...state!.recentPlaces];

    // Remove duplicates by address ID or title (optional)
    final unique = <String, AddressModel>{};
    for (var place in updatedPlaces) {
      unique[place.place_id!] = place; // Or use `place.id` if you have one
    }

    final finalList = unique.values.toList().take(maxPlaces).toList();

    state = state!.copyWith(recentPlaces: finalList);
  }
}

final UserProvider = StateNotifierProvider<UserNotifier, AppUser?>((ref) {
  return UserNotifier();
});
