import 'package:flutter/foundation.dart';

class LangLevel with ChangeNotifier {
  final int id;
  final String name;

  LangLevel(this.id, this.name);

 static List<LangLevel> getLangLevels() {
    return <LangLevel>[
      LangLevel(0,'Dominio del ingles'),
      LangLevel(1,'Nativo'),
      LangLevel(2,'No nativo'),
    ];
  }
}