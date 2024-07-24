import 'package:flutter/foundation.dart';

class Gender with ChangeNotifier {
  final String id;
  final String name;

  Gender(this.id, this.name);

  static List<Gender> getGenders() {
    return <Gender>[
      Gender('1', 'Hombre'),
      Gender('2', 'Mujer'),
      Gender('3', 'Prefer not to Answer'),
    ];
  }
}
