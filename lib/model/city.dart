import 'package:flutter/foundation.dart';

class City with ChangeNotifier {
  final int id;
  final String name;

  City(this.id, this.name);

 static List<City> getCitys() {
    return <City>[
      City(1, 'Doral'),
    ];
  }
}