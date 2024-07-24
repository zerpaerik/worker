import 'package:flutter/foundation.dart';

class Profile with ChangeNotifier {
  final String id;
  // ignore: non_constant_identifier_names
  final String first_name;
  final String email;
  // ignore: non_constant_identifier_names
  final DateTime birth_date;
  // ignore: non_constant_identifier_names
  final String last_name;
  final String password1;
  final String password2;
  final String gender;
  final String city;

  Profile({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.first_name,
    required this.email,
    // ignore: non_constant_identifier_names
    required this.birth_date,
    // ignore: non_constant_identifier_names
    required this.last_name,
    required this.password1,
    required this.password2,
    required this.gender,
    required this.city,
  });
}
