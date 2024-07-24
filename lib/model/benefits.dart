import 'package:flutter/foundation.dart';

class Benefits with ChangeNotifier {
  final String concept;
  // ignore: non_constant_identifier_names
  final String pay_mode;
  final String amount;

  Benefits({
    required this.concept,
    // ignore: non_constant_identifier_names
    required this.pay_mode,
    required this.amount,
  });

  factory Benefits.fromJson(Map<String, dynamic> json) {
    return Benefits(
      concept: json['concept'],
      pay_mode: json['pay_mode'],
      amount: json['amount'],
    );
  }
}
