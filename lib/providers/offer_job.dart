import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/widgets/global.dart';

import '../model/offer.dart';

class OfferJob with ChangeNotifier {
  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> applyOffer(Offer offer, id, o, driver, sign) async {
    print('datos en provider');
    print(id);
    print(driver);
    print(offer.arrives_on_his_own);
    print(offer.address);
    print(sign.path);
    print('fin de datos');

    String token = await getToken();
    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-2/contract/joboffer/apply/$id');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['is_accepted'] = 'true';
    request.fields['language'] = 'es';
    request.fields['accepted_contracting_conditions'] = 'true';
    request.fields['arrives_on_his_own'] = offer.arrives_on_his_own.toString();
    request.files
        .add(await http.MultipartFile.fromPath('signature', sign.path));
    request.fields['address'] = offer.address.toString();
    // request.fields['wants_to_be_driver'] = offer.wants_to_be_driver.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      print(json.decode(response.body));
      print('finoooo');
      return json.decode(response.body);
    } else {
      print('error');
      print(request.fields);
      print(response.statusCode.toString());
      print(response.body);
    }
  }
}
