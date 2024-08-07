import 'package:flutter/foundation.dart';

class WorkdayRegister with ChangeNotifier {
  final int id;
  final String btn_id;
  final String first_name;
  final String last_name;
  final String clock_in;
  final DateTime workday_entry_time;
  final String clock_out;
  final DateTime workday_departure_time;
  final DateTime lunch_start_time;
  final DateTime lunch_end_time;
  final String lunch_duration;
  final DateTime standby_start_time;
  final DateTime standby_end_time;
  final String standby_duration;
  final DateTime travel_start_time;
  final DateTime travel_end_time;
  final String travel_duration;
  final bool was_driver;
  final bool was_lead;
  final String comments;
  // ignore: non_constant_identifier_names

  WorkdayRegister(
      {required this.id,
      required this.btn_id,
      required this.first_name,
      required this.last_name,
      required this.clock_in,
      required this.workday_entry_time,
      required this.clock_out,
      required this.workday_departure_time,
      required this.lunch_start_time,
      required this.lunch_end_time,
      required this.lunch_duration,
      required this.standby_start_time,
      required this.standby_end_time,
      required this.standby_duration,
      required this.travel_start_time,
      required this.travel_end_time,
      required this.travel_duration,
      required this.was_driver,
      required this.was_lead,
      required this.comments});

  factory WorkdayRegister.fromJson(Map<String, dynamic> json) {
    return WorkdayRegister(
      id: json['id'],
      btn_id: json['btn_id'],
      first_name: json['first_name'],
      last_name: json['last_name'],
      clock_in: json['clock_in'] != null ? json['clock_in'] : null,
      workday_entry_time: json['workday_entry_time'] != null
          ? DateTime.parse(json['workday_entry_time'].toString())
          : DateTime.now(),
      clock_out: json['clock_out'] != null ? json['clock_out'] : null,
      workday_departure_time: json['workday_departure_time'] != null
          ? DateTime.parse(json['workday_departure_time'].toString())
          : DateTime.now(),
      lunch_start_time: json['lunch_start_time'].toString() != 'null'
          ? DateTime.parse(json['lunch_start_time'].toString())
          : DateTime.now(),
      lunch_end_time: json['lunch_end_time'].toString() != 'null'
          ? DateTime.parse(json['lunch_end_time'].toString())
          : DateTime.now(),
      lunch_duration: json['lunch_duration'],
      travel_duration: json['travel_duration'],
      standby_start_time: json['standby_start_time'].toString() != 'null'
          ? DateTime.parse(json['standby_start_time'].toString())
          : DateTime.now(),
      standby_end_time: json['standby_end_time'].toString() != 'null'
          ? DateTime.parse(json['standby_end_time'].toString())
          : DateTime.now(),
      standby_duration: json['standby_duration'],
      travel_start_time: json['travel_start_time'].toString() != 'null'
          ? DateTime.parse(json['travel_start_time'].toString())
          : DateTime.now(),
      travel_end_time: json['travel_end_time'].toString() != 'null'
          ? DateTime.parse(json['travel_end_time'].toString())
          : DateTime.now(),
      was_driver: json['was_driver'],
      was_lead: json['was_lead'],
      comments: json['comments'].toString(),
    );
  }
}
