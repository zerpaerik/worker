import 'package:flutter/foundation.dart';

class States with ChangeNotifier {
  final int id;
  final String name;
  final String code;

  States(this.id, this.name, this.code);

  static List<States> getStates() {
    return <States>[
      States(1, 'Florida', '12'),
    ];
  }
}
