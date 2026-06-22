class PredectionModel {
  String? place_id;
  String? main_text;
  String? sec_text;
  String? place_name;

  PredectionModel({this.place_id, this.main_text, this.sec_text});

  PredectionModel.fromJson(Map<String, dynamic> json) {
    place_name = json["description"];
    place_id = json['place_id'];
    main_text = json['structured_formatting']['main_text'];
    sec_text = json['structured_formatting']['secondary_text'];
  }
  PredectionModel.fromMap(Map<String, dynamic> Map) {
    place_name = Map["Place_name"];
    place_id = Map['place_id'];
    main_text = Map["Place_name"];
    sec_text = Map['Place_name_sec'];
  }
}
