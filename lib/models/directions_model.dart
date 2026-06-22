class DirectionsModel {
  String? distanceTextString;
  String? durationTextString;
  int? distanceValueDigits;
  int? durationValueDigits;
  String? encodedPoints;

  DirectionsModel({
    this.distanceTextString,
    this.durationTextString,
    this.distanceValueDigits,
    this.durationValueDigits,
    this.encodedPoints,
  });

  factory DirectionsModel.fromJson(Map<dynamic, dynamic> json) {
    return DirectionsModel(
      distanceTextString: json['distanceTextString'],
      durationTextString: json['durationTextString'],
      distanceValueDigits: json['distanceValueDigits'],
      durationValueDigits: json['durationValueDigits'],
      encodedPoints: json['encodedPoints'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distanceTextString': distanceTextString,
      'durationTextString': durationTextString,
      'distanceValueDigits': distanceValueDigits,
      'durationValueDigits': durationValueDigits,
      'encodedPoints': encodedPoints,
    };
  }
}
