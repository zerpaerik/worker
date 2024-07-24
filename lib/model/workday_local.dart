import '../local/database_creator.dart';

class WorkdayLocal {
  late int id;
  late String estatus;
  late String token;
  late String init;
  late String end;

  WorkdayLocal(this.id, this.estatus, this.init, this.end);

  WorkdayLocal.fromJson(Map<String, dynamic> json) {
    this.id = json[DatabaseCreator.id];
    this.estatus = json[DatabaseCreator.estatus];
    this.init = json[DatabaseCreator.init];
    this.end = json[DatabaseCreator.end];
  }
}
