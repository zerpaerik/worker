import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../widgets/global.dart';
import 'package:worker/providers/url_constants.dart';

import '../model/warnings.dart';

class WarningsProvider with ChangeNotifier {
  DateFormat format = DateFormat("yyyy-MM-dd");

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> save(Warnings data_warnings, hechos, witness) async {
    String token = await getToken();
    DateFormat format = DateFormat("yyyy-MM-dd");
    print('prov data contract');
    //print(data_warnings.contract['']);

    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-1/emplooy-warnings/create');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll(headers);
    request.fields['warning_type'] = data_warnings.warning_type.toString();
    request.fields['contract'] = data_warnings.contract.toString();
    request.fields['user'] = data_warnings.worker.toString();
    //request.fields['witness'] = witness['id'].toString();
    request.fields['reason'] = data_warnings.reason.toString();
    request.fields['explanatory_text'] = hechos['descripcion'].toString();
    request.fields['description'] = hechos['descripcion'].toString();
    request.fields['occurrence_date'] =
        format.format(data_warnings.occurrence_date);
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    if (response.statusCode == 201) {
      print(json.decode(response.body));
      return response.statusCode.toString();
    } else {
      return response.statusCode.toString();
    }
  }

  Future<dynamic> delete(exp) async {
    String token = await getToken();
    try {
      final response = await http.delete(
        Uri.parse('$urlServices/api/v-1/expense/$exp/delete'),
        headers: {
          'Authorization': 'Token $token',
        },
      );

      print(response.statusCode);

      notifyListeners();
      return response.statusCode.toString();
    } catch (non_field_errors) {
      throw non_field_errors;
    }
  }
}
