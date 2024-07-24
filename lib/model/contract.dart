import 'package:flutter/foundation.dart';

class Contract with ChangeNotifier {
  // ignore: non_constant_identifier_names
  final int id;
  final String contract_id;
  // ignore: non_constant_identifier_names
  final String contract_name;
  // ignore: non_constant_identifier_names

  Contract({
    // ignore: non_constant_identifier_names
    required this.id,
    required this.contract_id,
    // ignore: non_constant_identifier_names
    required this.contract_name,
    // ignore: non_constant_identifier_names
  });

  factory Contract.fromJson(Map<String, dynamic> json) {
    return Contract(
      id: json['id'],
      contract_id: json['contract_id'].toString(),
      contract_name: json['contract_name'],
    );
  }
}
