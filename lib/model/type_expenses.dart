import 'package:flutter/foundation.dart';

class ExpensesType with ChangeNotifier {
  final int id;
  final String name;

  ExpensesType(this.id, this.name);

  static List<ExpensesType> getExpensesType() {
    return <ExpensesType>[
      ExpensesType(1, 'Personal Expense'),
      ExpensesType(2, 'Other'),
      ExpensesType(3, 'Food'),
      ExpensesType(4, 'Entertainment'),
      ExpensesType(5, 'Air Transportation'),
      ExpensesType(6, 'Housing'),
      ExpensesType(7, 'Medical'),
      ExpensesType(8, 'Travel Expenses'),
      ExpensesType(9, 'Transportation'),
      ExpensesType(10, 'Fuel'),
    ];
  }
}
