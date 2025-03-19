import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/model/config.dart';
import 'package:worker/model/workday_register.dart';
import '../local/database_creator.dart';
import '../local/service.dart';

import '../widgets/global.dart';
import '../model/workday.dart';
import '../model/clock.dart';

class CrewProvider with ChangeNotifier {
  late Workday workday;
  late Config config;

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  getWorkDay() async {
    SharedPreferences workday = await SharedPreferences.getInstance();
    //Return String
    int? intValue = workday.getInt('intValue');
    return intValue;
  }

  getUser() async {
    SharedPreferences user = await SharedPreferences.getInstance();
    //Return String
    int? intValue = user.getInt('intValue');
    return intValue;
  }

  getWorkday(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final workday = Workday.fromJson(data.first);

    return workday;
  }

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);

    return todo;
  }

  Future<dynamic> addCrew(
      location, geo, type, DateTime hour, DateTime hour1) async {
    String? token = await getToken();
    DateTime now = DateTime.now();
    workday = await getWorkday(1);
    print(geo);
    print('hour');
    print(hour);
    final url = ApiWebServer.server_name + '/api/v-1/crew/create';

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'location': location,
            'clock_in_start': hour.toIso8601String().toString(),
            'default_entry_time': hour.toIso8601String().toString(),
            //'default_exit_time': hour1.toIso8601String(),
            'project_category': 1,
            'shift': type,
            'geographical_coordinates': geo,
            //'temperature': '00.00'
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(response.statusCode);
      // await editCrew(responseData['id'], hour1);

      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      Map<String, dynamic> success = {
        "workday": responseData,
        "status": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editCrew(crew, DateTime hour) async {
    print('agregando edicion de crew');
    print(hour);
    String? token = await getToken();

    final url = ApiWebServer.server_name + '/api/v-1/crew/$crew/update';

    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'default_exit_time': hour.toIso8601String(),
            'clock_out_start': hour.toIso8601String(),
            //'temperature': '00.00'
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(response.statusCode);

      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      Map<String, dynamic> success = {
        "workday": responseData,
        "status": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editCrewIn(crew, time, hour, type) async {
    print('agregando edicion de crew');
    print(time);
    print(hour);
    print(type);
    String? token = await getToken();
    String s_d = hour.toString().substring(0, 11) +
        hour.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);

    final url = ApiWebServer.server_name + '/api/v-1/crew/$crew/update';

    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'default_entry_time': fec.toIso8601String().toString(),
            //'clock_out_start': hour.toIso8601String(),
            //'temperature': '00.00'
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(response.statusCode);

      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      Map<String, dynamic> success = {
        "workday": responseData,
        "status": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editCrewOut(crew, time, hour, type) async {
    print('agregando edicion de crew');
    print(time);
    print(hour);
    print(type);
    String? token = await getToken();
    String s_d = hour.toString().substring(0, 11) +
        hour.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);

    final url = ApiWebServer.server_name + '/api/v-1/crew/$crew/update';

    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'default_exit_time': fec.toIso8601String().toString(),
            //'clock_out_start': hour.toIso8601String(),
            //'temperature': '00.00'
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(response.statusCode);

      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      Map<String, dynamic> success = {
        "workday": responseData,
        "status": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> endIn(crew) async {
    print('agregando edicion de crew');
    String? token = await getToken();
    DateTime now = DateTime.now();

    final url = ApiWebServer.server_name + '/api/v-1/crew/$crew/update';

    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'clock_in_end': now.toIso8601String(),
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(response.statusCode);

      Map<String, dynamic> success = {
        "workday": responseData,
        "status": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> endOut(crew) async {
    print('agregando edicion de crew');
    String? token = await getToken();
    DateTime now = DateTime.now();

    final url = ApiWebServer.server_name + '/api/v-1/crew/$crew/update';

    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'clock_out_end': now.toIso8601String(),
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(response.statusCode);

      Map<String, dynamic> success = {
        "workday": responseData,
        "status": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> changeCrewReport(report) async {
    print('llego pv wkd');
    String? token = await getToken();
    final url =
        ApiWebServer.server_name + '/api/v-1/crew/report/$report/status-update';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'status': 2,
            //'temperature': '00.00'
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);

      print(response.statusCode);
      print(responseData);

      Map<String, dynamic> success = {
        "data": responseData,
        "estatus": response.statusCode.toString()
      };
      print(success);

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> listClockIn(wd) async {
    String? token = await getToken();

    try {
      final response = await http.get(
          Uri.parse(ApiWebServer.server_name + '/api/v-1/crew/$wd/register'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      notifyListeners();

      if (response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(utf8.decode(response.bodyBytes)),
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
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> scanQRWorker(
      String identification, String lat, String long) async {
    String? token = await getToken();

    final response = await http.get(
        Uri.parse(ApiWebServer.server_name +
            '/api/v-1/user/get-registered-user/$identification/1/in'),
        headers: {"Authorization": "Token $token"});

    // ignore: await_only_futures
    print(response.body);
    var resBody = json.decode(utf8.decode(response.bodyBytes));

    if (response.statusCode == 200 && resBody['first_name'] != null) {
      print('dio 200 scan list');
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": resBody
      };
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": resBody
      };
      return success;
    }
  }

  Future<dynamic> addClockIn(worker, geo, wd, category, type, crew) async {
    print('llego pv clockin crew');
    DateTime now = DateTime.now();
    DateTime clockin;
    String? token = await getToken();
    clockin = now.toUtc();

    print('crew');
    print(crew);

    final url = ApiWebServer.server_name + '/api/v-1/crew/register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'crew': wd,
            'worker_accepted': worker,
            'clock_type': type,
            'clock_datetime': type == 'IN'
                ? DateTime.parse(crew['default_entry_time'].toString())
                    .toIso8601String()
                : DateTime.parse(crew['default_exit_time'].toString())
                    .toIso8601String(),
            'geographical_coordinates': '111 1111',
            'project_category': null
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();
      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockInIn(worker, geo, wd, category, type, crew) async {
    print('llego pv clockin crew');
    DateTime now = DateTime.now();
    DateTime clockin;
    String? token = await getToken();
    clockin = now.toUtc();

    print('crew');
    print(crew);

    final url = ApiWebServer.server_name + '/api/v-1/crew/register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'crew': wd,
            'worker_accepted': worker,
            'clock_type': 'IN',
            'clock_datetime': type ==
                DateTime.parse(crew['default_entry_time'].toString())
                    .toIso8601String(),
            'geographical_coordinates': '111 1111',
            'project_category': null
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print('response checkin list');
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();
      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockInOut(worker, geo, wd, category, type, crew) async {
    print('llego pv clockin crew');
    DateTime now = DateTime.now();
    DateTime clockin;
    String? token = await getToken();
    clockin = now.toUtc();

    print('crew');
    print(crew);

    final url = ApiWebServer.server_name + '/api/v-1/crew/register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'crew': wd,
            'worker_accepted': worker,
            'clock_type': 'OUT',
            'clock_datetime':
                DateTime.parse(crew['default_exit_time'].toString())
                    .toIso8601String(),
            'geographical_coordinates': '111 1111',
            'project_category': null
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();
      await RepositoryServiceTodo.updateUltClock(
          1, DateTime.now().toIso8601String().toString());

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addWorkdayReport(workday, data, comments) async {
    String? token = await getToken();

    String lunch;
    String stand;
    String lunchs;
    String stands;
    String travels;

    print('data en prov');
    print(data);
    print(workday);
    Map<String, dynamic> dataCrew;

    if (data['lunch_duration'] != null) {
      print('hay duracion de lunch');
      print(data['lunch_duration']);
      lunch = '00:' + data['lunch_duration'] + ':00';
      print(lunch);
    } else {
      lunch = '00:00:00';
    }

    if (data['standby_duration'] != null) {
      print('hay duracion de standby');
      print(data['standby_duration']);
      stand = '00:' + data['standby_duration'] + ':00';
      print(lunch);
    } else {
      stand = '00:00:00';
    }

    if (data['travel_duration'] != null) {
      print('hay duracion de travel');
      print(data['travel_duration']);
      stand = '00:' + data['travel_duration'] + ':00';
      print(lunch);
    } else {
      stand = '00:00:00';
    }

    if (data['lunch_s'] != null) {
      print('hay duracion de lunch');
      print(data['lunch_s']);
      lunchs = '00:' + data['lunch_s'] + ':00';
    } else {
      lunchs = '00:00:00';
    }
    if (data['travel_s'] != null) {
      print('hay duracion de lunch');
      print(data['travel_s']);
      travels = '00:' + data['travel_s'] + ':00';
    } else {
      travels = '00:00:00';
    }

    if (data['standby_s'] != null) {
      print('hay duracion de lunch');
      print(data['standby_s']);
      stands = '00:' + data['standby_s'] + ':00';
    } else {
      stands = '00:00:00';
    }

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name + '/api/v-1/crew/report/create'),
          body: json.encode({
            "crew": workday,
            "supervisor_entry_time": data['inicio_s'] != null
                ? data['inicio_s'].toIso8601String().toString()
                : '0000-00-00T00:00:00.000',
            "supervisor_exit_time": data['fin_s'] != null
                ? data['fin_s'].toIso8601String().toString()
                : '0000-00-00T00:00:00.000',
            "workday_entry_time": data['inicio'] != null
                ? data['inicio'].toIso8601String().toString()
                : '0000-00-00T00:00:00.000',
            "workday_departure_time": data['fin'] != null
                ? data['fin'].toIso8601String().toString()
                : '0000-00-00T00:00:00.000',
            "lunch_duration": lunch,
            "standby_duration": stand,
            "travel_duration": stand,
            "supervisor_lunch_duration": lunchs,
            "supervisor_standby_duration": stands,
            "supervisor_travel_duration": travels,
            "comments": comments != null ? comments : 'S/C',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      notifyListeners();

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReportEntry(entry, departure, report, type) async {
    print(entry);
    print(departure);

    print(report);
    String? token = await getToken();
    Map<String, dynamic> data;
    if (type == 1) {
      data = {
        "workday_entry_time": entry.toUtc().toIso8601String(),
        "workday_departure_time": departure.toUtc().toIso8601String()
      };
    } else if (type == 2) {
      data = {
        "lunch_start_time": entry.toUtc().toIso8601String(),
        "lunch_end_time": departure.toUtc().toIso8601String()
      };
    } else if (type == 3) {
      data = {
        "standby_start_time": entry.toUtc().toIso8601String(),
        "standby_end_time": departure.toUtc().toIso8601String()
      };
    } else if (type == 0) {
      data = {
        "supervisor_entry_time": entry.toUtc().toIso8601String(),
        "supervisor_exit_time": departure.toUtc().toIso8601String()
      };
    } else if (type == 4) {
      data = {
        "travel_start_time": entry.toUtc().toIso8601String(),
        "travel_end_time": departure.toUtc().toIso8601String()
      };
    } else {}

    try {
      final response = await http.patch(
          Uri.parse(
              ApiWebServer.server_name + '/api/v-1/crew/report/$report/update'),
          body: json.encode(""),
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
      };
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> uploadPhoto(XFile image, report) async {
    String? token = await getToken();
    print('llego a pv');

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    var postUri = Uri.parse(
        ApiWebServer.server_name + '/api/v-1/crew/report/$report/photo');
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.files
        .add(await http.MultipartFile.fromPath('sheet_photo', image.path));
    //request.fields['birthplace'] = country;
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print('update0');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }
}
