import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class W4 with ChangeNotifier {
  final int id;
  // ignore: non_constant_identifier_names
  final int user_id;
  // ignore: non_constant_identifier_names
  final int marital_status;
  // ignore: non_constant_identifier_names
  final DateTime declaration_date;
  final File signature;

  W4({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.user_id,
    // ignore: non_constant_identifier_names
    required this.marital_status,
    // ignore: non_constant_identifier_names
    required this.declaration_date,
    required this.signature,
  });
}
