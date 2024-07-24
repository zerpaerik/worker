import '../local/database_creator.dart';

class Config {
  late int id;
  late String language;
  late String token;
  late String role;
  late String contract;
  late String first_name;
  late String last_name;
  late String offline;
  late String image;
  late String btn_id;
  late String email;
  late String profile_image;
  late String id_type;
  late String doc_type;
  late String dependents;
  late String contact;
  late String addres;

  Config(
      this.id,
      this.language,
      this.token,
      this.role,
      this.contract,
      this.first_name,
      this.last_name,
      this.offline,
      this.image,
      this.btn_id,
      this.email,
      this.profile_image,
      this.id_type,
      this.doc_type,
      this.dependents,
      this.contact,
      this.addres);

  Config.fromJson(Map<String, dynamic> json) {
    id = json[DatabaseCreator.id];
    language = json[DatabaseCreator.language];
    token = json[DatabaseCreator.token] ?? '';
    role = json[DatabaseCreator.role] ?? '';
    contract = json[DatabaseCreator.contract] ?? '';
    first_name = json[DatabaseCreator.first_name] ?? '';
    last_name = json[DatabaseCreator.last_name] ?? '';
    offline = json[DatabaseCreator.offline] ?? '';
    addres = json[DatabaseCreator.addres] ?? '';
    image = json[DatabaseCreator.image] ?? '';
    btn_id = json[DatabaseCreator.btn_id] ?? '';
    email = json[DatabaseCreator.email] ?? '';
    profile_image = json[DatabaseCreator.profile_image] ?? '';
    id_type = json[DatabaseCreator.id_type] ?? '';
    doc_type = json[DatabaseCreator.doc_type] ?? '';
    dependents = json[DatabaseCreator.dependents] ?? '';
    contact = json[DatabaseCreator.contact] ?? '';
    addres = json[DatabaseCreator.addres] ?? '';
  }
}
