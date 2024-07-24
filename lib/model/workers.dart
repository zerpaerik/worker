import '../local/database_creator.dart';

class Workers {
  late int id;
  late String btn_id;
  late String first_name;
  late String last_name;
  late String profile_image;

  Workers(this.id, this.btn_id, this.first_name, this.last_name,
      this.profile_image);

  Workers.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.id];
    this.btn_id = json[DatabaseCreator.btn_id];
    this.first_name = json[DatabaseCreator.first_name];
    this.last_name = json[DatabaseCreator.last_name];
    this.profile_image = json[DatabaseCreator.image];
  }
}
