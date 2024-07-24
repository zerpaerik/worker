import 'package:flutter/foundation.dart';

class Modules with ChangeNotifier {
  final bool clock_in_module;
  final bool clock_out_module;
  final bool expenses_module;
  final bool warnings_module;
  final bool workday_reports_module;
  final String role;

  Modules(
      {required this.clock_in_module,
      required this.clock_out_module,
      required this.expenses_module,
      required this.warnings_module,
      required this.workday_reports_module,
      required this.role});

  factory Modules.fromJson(Map<String, dynamic> json) {
    return Modules(
        role: json['role'],
        clock_in_module: json['clock_in_module'],
        clock_out_module: json['clock_out_module'],
        expenses_module: json['expenses_module'],
        warnings_module: json['warnings_module'],
        workday_reports_module: json['workday_reports_module']);
  }
}
