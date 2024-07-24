import 'package:flutter/foundation.dart';

class Warnings with ChangeNotifier {
  final String explanatory_text;
  final String description;
  final DateTime occurrence_date;
  final String warning_type;
  final int contract;
  final String reason;
  final int worker;

  Warnings(
      {required this.explanatory_text,
      // ignore: non_constant_identifier_names
      required this.description,
      // ignore: non_constant_identifier_names
      required this.occurrence_date,
      // ignore: non_constant_identifier_names
      required this.warning_type,
      required this.contract,
      required this.reason,
      required this.worker});

  factory Warnings.fromJson(Map<String, dynamic> json) {
    return Warnings(
      explanatory_text: json['explanatory_text'],
      description: json['description'],
      occurrence_date:
          json['occurrence_date'] != null ? json['occurrence_date'] : null,
      warning_type: json['warning_type'],
      contract: int.parse(json['contract']),
      reason: json['reason'],
      worker: json['worker'],
    );
  }
}
