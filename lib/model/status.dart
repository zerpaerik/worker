import 'package:flutter/foundation.dart';

class StatusM with ChangeNotifier {
  final int id;
  final String name;

  StatusM(this.id, this.name);

  static List<StatusM> getStatus() {
    return <StatusM>[
      StatusM(1, 'Soltero'),
      StatusM(2, 'Casado llenando por separado'),
      StatusM(3, 'Casado'),
      StatusM(4, 'Jefe de familia')
    ];
  }
}
