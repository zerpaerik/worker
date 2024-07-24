import 'package:flutter/foundation.dart';

class LangMastery with ChangeNotifier {
  final int id;
  final String name;

  LangMastery(this.id, this.name);

 static List<LangMastery> getLangMaster() {
    return <LangMastery>[
      LangMastery(1,'Basico'),
      LangMastery(2,'Medio'),
      LangMastery(2,'Avanzado'),
    ];
  }
}