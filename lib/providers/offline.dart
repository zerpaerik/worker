import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/providers/url_constants.dart';

import '../model/expenses.dart';

class OfflineProvider with ChangeNotifier {
  DateFormat format = DateFormat("yyyy-MM-dd");

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> addClockIn(data) async {
    String token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    data.asMap().forEach((i, value) {
      dataS.add({
        "worker": value['worker'],
        'clock_type': value['clock_type'],
        'clock_datetime': value['clock_in_start'],
        'geographical_coordinates': '0'
      });
    });

    print(dataS);

    try {
      final response = await http
          .post(Uri.parse('$urlServices/api/v-1/workday/offline/sync'),
              body: json.encode({
                'contract': 1,
                'clock_in_start': '2020-11-18T12:43:41.479967',
                'workday_registers': dataS,
              }),
              headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Token $token'
          });

      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print(responseData);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockOut(data) async {
    String token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    data.asMap().forEach((i, value) {
      dataS.add({
        "worker": value['worker'],
        'clock_type': value['clock_type'],
        'clock_datetime': value['clock_in_start'],
        'geographical_coordinates': '0'
      });
    });

    try {
      final response = await http
          .post(Uri.parse('$urlServices/api/v-1/workday/offline/sync'),
              body: json.encode({
                'contract': 1,
                'clock_in_start': '2020-11-18T12:43:41.479967',
                'workday_registers': dataS,
              }),
              headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Token $token'
          });

      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print(responseData);

      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> syncWorker(data) async {
    String token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    data.asMap().forEach((i, value) {
      dataS.add({
        "btn_id": value['btn_id'],
        'accepted_id': value['accepted_id'],
      });
    });

    try {
      final response = await http.post(
          Uri.parse('$urlServices/api/v-1/contract/1/sync-workers-accepted'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Token $token'
          });

      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      Map<String, dynamic> success = {
        "data": responseData,
        "status": response.statusCode.toString()
      };
      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
