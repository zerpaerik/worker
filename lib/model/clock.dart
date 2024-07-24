import 'package:flutter/foundation.dart';

class Clocks with ChangeNotifier {
  final int workday;
  final int worker;
  final String clock_type;
  // ignore: non_constant_identifier_names
  final DateTime clock_datetime;
  final bool is_extemporaneous;
  final String message;
  final String geographical_coordinates;
  final bool verified;

  Clocks({
    required this.workday,
    // ignore: non_constant_identifier_names
    required this.worker,
    required this.clock_type,
    required this.clock_datetime,
    required this.is_extemporaneous,
    required this.message,
    required this.geographical_coordinates,
    required this.verified,
  });

  factory Clocks.fromJson(Map<String, dynamic> json) {
    return Clocks(
      workday: json['workday'],
      worker: json['worker'],
      clock_type: json['clock_type'],
      clock_datetime: json['clock_datetime'],
      is_extemporaneous: json['is_extemporaneous'],
      message: json['message'],
      geographical_coordinates: json['geographical_coordinates'],
      verified: json['verified'],
    );
  }
}
