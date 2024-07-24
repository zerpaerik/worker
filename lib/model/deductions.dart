import 'package:flutter/foundation.dart';

class Deductions with ChangeNotifier {
  final String code;
  final String name;

  Deductions(this.code, this.name);

  static List<Deductions> getStatus() {
    return <Deductions>[
      Deductions('ST', 'Standard'),
      Deductions('OT', 'Other'),
    ];
  }
}
