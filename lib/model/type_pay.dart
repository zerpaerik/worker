import 'package:flutter/foundation.dart';

class PayType with ChangeNotifier {
  final int id;
  final String name;

  PayType(this.id, this.name);

  static List<PayType> getPayType() {
    return <PayType>[
      PayType(1, 'Zelle'),
      PayType(2, 'Chase CREDIT'),
      PayType(3, 'Chase DEBIT'),
      PayType(4, 'AMEX 41010'),
      PayType(5, 'AMEX 41002'),
      PayType(6, 'WellsFargo CREDIT'),
      PayType(7, 'WellsFargo DEBIT'),
      PayType(8, 'Cash'),
      PayType(9, 'Personal Card'),
      PayType(10, 'Other'),
    ];
  }
}
