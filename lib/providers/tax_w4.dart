import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
//import 'package:multipart_request/multipart_request.dart';

import '../model/w4.dart';
import '../widgets/global.dart';

class TaxW4 with ChangeNotifier {
  // var _showFavoritesOnly = false;

  Future<dynamic> saveForm(W4 tax, id) async {
    print(tax.declaration_date);
    print(id);
    // DATA CAST

    //
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    var postUri = Uri.parse(ApiWebServer.API_REGISTER_W4);
    var request = new http.MultipartRequest("POST", postUri);
    request.fields['marital_status'] = '1';
    request.fields['user_id'] = id;
    request.fields['declaration_date'] = format.format(tax.declaration_date);
    // request.files.add(await http.MultipartFile.fromPath('signature', image.path));
    request.send().then((response) {
      if (response.statusCode == 200)
        print("Uploaded!");
      else
        // print(user.doc_expire_date);
        print(request.fields);
      print(response.toString());
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
  }
}
