import 'package:flutter/foundation.dart';

class Blodd with ChangeNotifier {
  final int id;
  final String name;

  Blodd(this.id, this.name);

  static List<Blodd> getBlodds() {
    return <Blodd>[
      Blodd(1, 'A +'),
      Blodd(2, 'A -'),
      Blodd(3, 'B +'),
      Blodd(4, 'B -'),
      Blodd(5, 'O +'),
      Blodd(6, 'O -'),
      Blodd(7, 'AB +'),
      Blodd(8, 'AB -'),
      Blodd(9, 'No lo se'),
    ];
  }
}
