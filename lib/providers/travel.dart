import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/widgets/global.dart';
import 'package:worker/providers/url_constants.dart';

import '../model/expenses.dart';

class TravelProvider with ChangeNotifier {
  DateFormat format = DateFormat("yyyy-MM-dd");

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> update(int travel, String lat, String long) async {
    String token = await getToken();
    print(lat);
    print(long);
    print(travel);

    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-1/travel/$travel/change_status/');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['status'] = 'TR';
    request.fields['latitude'] = lat.toString();
    request.fields['longitude'] = long.toString();

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    if (response.statusCode == 200) {
      print('fino');
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print(success);
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> updatef(int travel, String lat, String long) async {
    String token = await getToken();
    print(lat);
    print(long);
    print(travel);

    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-1/travel/$travel/change_status/');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['status'] = 'FI';
    request.fields['latitude'] = lat.toString();
    request.fields['longitude'] = long.toString();

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('fino');
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> accept(travel, bool respuest) async {
    String token = await getToken();
    print(travel);
    print('llego a pv');

    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-1/travel/invitation/$travel/update');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['accepted'] = respuest.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  //travel_report
  Future<dynamic> addReport(travel, start, end, duration) async {
    String token = await getToken();

    print(travel);

    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-1/travel/travel-report/create');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll(headers);
    request.fields['travel'] = travel.toString();
    request.fields['start_time'] = start.toIso8601String();
    request.fields['end_time'] = end.toIso8601String();
    request.fields['duration'] = '00:' + duration + ':00';
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    if (response.statusCode == 200) {
      print('fino');
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print(success);
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> addAsistDriver(driving) async {
    String token = await getToken();
    print(driving);

    try {
      final response = await http.post(
          Uri.parse(
              '$urlServices/api/v-1/travel/travel-report/driving-assistant/create'),
          body: json.encode(driving),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "data": responseData
      };
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
