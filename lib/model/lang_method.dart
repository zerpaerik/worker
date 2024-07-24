import 'package:flutter/foundation.dart';

class LangMethod with ChangeNotifier {
  final int id;
  final String name;

  LangMethod(this.id, this.name);

 static List<LangMethod> getLangMethod() {
    return <LangMethod>[
      LangMethod(1,'Lectura'),
      LangMethod(2,'Escritura'),
      LangMethod(3,'Otro'),
    ];
  }
}