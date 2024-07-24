import 'dart:io';
import 'package:flutter/foundation.dart';

class Expenses with ChangeNotifier {
  // ignore: non_constant_identifier_names
  final int id;
  final String name;
  // ignore: non_constant_identifier_names
  final int contract;
  // ignore: non_constant_identifier_names
  final String expense_type;
  // ignore: non_constant_identifier_names
  final String pay_method;
  final String amount;
  final DateTime date;
  // ignore: non_constant_identifier_names
  final File invoice_image;

  Expenses({
    // ignore: non_constant_identifier_names
    required this.id,
    required this.name,
    // ignore: non_constant_identifier_names
    required this.contract,
    // ignore: non_constant_identifier_names
    required this.expense_type,
    // ignore: non_constant_identifier_names
    required this.pay_method,
    required this.amount,
    required this.date,
    required this.invoice_image,
  });
}
