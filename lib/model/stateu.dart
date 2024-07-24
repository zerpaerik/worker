import 'package:flutter/foundation.dart';

class StateU with ChangeNotifier {
  final int id;
  final String name;
  final String code;

  StateU({required this.id, required this.name, required this.code});

  factory StateU.fromJson(Map<String, dynamic> json) {
    return StateU(id: json['id'], name: json['name'], code: json['code']);
  }
}
