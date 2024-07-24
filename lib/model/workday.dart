import 'package:flutter/foundation.dart';

class Workday with ChangeNotifier {
  final int id;
  // ignore: non_constant_identifier_names
  final DateTime created;
  final DateTime clock_in_start;
  final DateTime clock_in_end;
  final DateTime clock_out_end;
  final DateTime clock_out_start;
  final DateTime default_init;
  final DateTime default_exit;
  final String clock_in_location;
  final String clock_out_location;

  Workday(
      {required this.id,
      // ignore: non_constant_identifier_names
      required this.created,
      required this.clock_in_start,
      required this.clock_in_end,
      required this.clock_out_end,
      required this.clock_out_start,
      required this.default_init,
      required this.default_exit,
      required this.clock_in_location,
      required this.clock_out_location});

  factory Workday.fromJson(Map<String, dynamic> json) {
    return Workday(
      id: json['id'],
      created: json['created'] != null ? json['created'] : null,
      clock_in_start:
          json['clock_in_start'] != null ? json['clock_in_start'] : null,
      clock_in_end: json['clock_in_end'] != null ? json['clock_in_end'] : null,
      clock_out_start:
          json['clock_out_start'] != null ? json['clock_out_start'] : null,
      clock_out_end:
          json['clock_out_end'] != null ? json['clock_out_end'] : null,
      default_init: json['default_entry_time'] != null
          ? json['default_entry_time']
          : null,
      default_exit:
          json['default_exit_time'] != null ? json['default_exit_time'] : null,
      clock_in_location: json['clock_in_location'],
      clock_out_location: json['clock_out_location'],
    );
  }
}
