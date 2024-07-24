import 'dart:io';
import 'package:flutter/foundation.dart';

class Country with ChangeNotifier {
  // ignore: non_constant_identifier_names
  final int id;
  final String name;
  // ignore: non_constant_identifier_names
  final String code;
  // ignore: non_constant_identifier_names

  Country({
    // ignore: non_constant_identifier_names
    required this.id,
    required this.name,
    // ignore: non_constant_identifier_names
    required this.code,
    // ignore: non_constant_identifier_names
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }
}
