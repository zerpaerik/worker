import 'package:flutter/foundation.dart';

class TypeExp with ChangeNotifier {
  final int id;
  // ignore: non_constant_identifier_names
  final String name;

  TypeExp({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.name,
  });

  factory TypeExp.fromJson(Map<String, dynamic> json) {
    return TypeExp(id: json['id'], name: json['name']);
  }
}
