import 'package:flutter/foundation.dart';

class TypePy with ChangeNotifier {
  final String id;
  // ignore: non_constant_identifier_names
  final String name;

  TypePy({
    required this.id,
    // ignore: non_constant_identifier_names
    required this.name,
  });

  factory TypePy.fromJson(Map<String, dynamic> json) {
    return TypePy(id: json['id'], name: json['name']);
  }
}
