import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/model/config.dart';
import 'package:worker/model/workday_register.dart';
import '../local/database_creator.dart';
import '../local/service.dart';

import '../widgets/global.dart';
import '../model/workday.dart';
import '../model/clock.dart';

class WorkDay with ChangeNotifier {
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

  Future<dynamic> addWorkday(
      contract, geo, temp, valid_temp, start, time) async {
    print('llego pv wkd');
    String? token = await getToken();
    DateTime now = DateTime.now();

    print(start);
    print(time);
    String s_d = start.toString().substring(0, 11) +
        time.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);
    print('fec');
    print(fec);
    print(fec.toUtc().toIso8601String().toString());
    print('contract');
    print(contract);

    workday = await getWorkday(1);
    const url = ApiWebServer.API_CREATE_WORKDAY;

    try {
      if (valid_temp.toString() == 'true') {
        final response = await http.post(Uri.parse(url),
            body: json.encode({
              'contract': contract,
              'clock_in_start': fec.toIso8601String().toString(),
              'geographical_coordinates': geo,
              'supervisor_temperature': temp,
              'default_entry_time': fec.toIso8601String().toString()
              //'temperature': '00.00'
            }),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': "Token $token"
            });
        final responseData = json.decode(response.body);
        print(response.statusCode);

        RepositoryServiceTodo.updateWorkdayIn(
            workday,
            responseData['id'],
            responseData['clock_in_start'],
            responseData['clock_in_location'],
            fec.toIso8601String().toString());

        await RepositoryServiceTodo.updateUltClock(
            workday, DateTime.now().toIso8601String().toString());

        Map<String, dynamic> success = {
          "workday": responseData,
          "status": response.statusCode.toString()
        };
        print(success);

        return success;
      } else {
        final response = await http.post(Uri.parse(url),
            body: json.encode({
              'contract': contract,
              'clock_in_start': fec.toIso8601String().toString(),
              'geographical_coordinates': geo,
              'supervisor_temperature': 0,
              'default_entry_time': fec.toIso8601String().toString()
            }),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': "Token $token"
            });
        final responseData = json.decode(response.body);
        print(response.statusCode);

        RepositoryServiceTodo.updateWorkdayIn(
            workday,
            responseData['id'],
            responseData['clock_in_start'],
            responseData['clock_in_location'],
            fec.toIso8601String().toString());

        await RepositoryServiceTodo.updateUltClock(
            workday, DateTime.now().toIso8601String().toString());

        Map<String, dynamic> success = {
          "workday": responseData,
          "status": response.statusCode.toString()
        };
        print(success);

        return success;
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addWorkerProject(contract, category, worker) async {
    print('llego pv wkd');
    String? token = await getToken();
    DateTime now = DateTime.now().toUtc();
    workday = await getWorkday(1);
    print(contract);
    final url =
        ApiWebServer.server_name + '/api/v-1/contract/add-user-to-contract';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'contract': contract,
            'worker_category': category,
            'user': worker
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
        "status": response.statusCode.toString()
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
          Uri.parse(
              ApiWebServer.server_name + '/api/v-1/workday/$wd/clock-in/list'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
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

  Future<dynamic> listClockInE(wd) async {
    String? token = await getToken();

    try {
      final response = await http.get(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$wd/clock-in/extemporaneus/list'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
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

  Future<dynamic> listClockInA(wd) async {
    String? token = await getToken();

    try {
      final response = await http.get(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$wd/not-clocked-ins/list'),
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

    /* final response = await http.get(
        ApiWebServer.server_name + '/api/v-1/workday/$wd/not-clocked-ins/list',
        headers: {"Authorization": "Token $token"});

    // ignore: await_only_futures
    print(response.body);

    if (response.statusCode == 200) {
      print('dio 200 scan list');
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
    }*/
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

  Future<dynamic> editWorkday(workdayy, geo, start, time) async {
    String? token = await getToken();
    DateTime now = DateTime.now();
    int wk = workdayy;
    workday = await getWorkday(1);
    String s_d = start.toString().substring(0, 11) +
        time.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);

    print(wk);
    print(now.toIso8601String());
    print(geo);
    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name + '/api/v-1/workday/$wk/update'),
          body: json.encode({
            'clock_out_start': fec.toIso8601String().toString(),
            'geographical_coordinates': geo,
            'default_exit_time': fec.toIso8601String().toString()
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      notifyListeners();
      final responseData = json.decode(response.body);

      RepositoryServiceTodo.updateWorkdayOut(
          workday,
          responseData['clock_out_start'],
          responseData['clock_out_location'],
          fec.toIso8601String().toString());
      RepositoryServiceTodo.updateUltClock(
          workday, DateTime.now().toIso8601String().toString());
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

  Future<dynamic> editWorkdayIn(workdayy, start, time) async {
    String? token = await getToken();
    DateTime now = DateTime.now();
    int wk = workdayy;
    workday = await getWorkday(1);
    String s_d = start.toString().substring(0, 11) +
        time.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);

    print(workdayy);
    print(s_d);
    print('fecha cruda fec');
    print(fec);
    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name + '/api/v-1/workday/$wk/update'),
          body: json.encode({
            'default_entry_time': fec.toIso8601String().toString(),
            'geographical_coordinates': 'N/A',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      notifyListeners();
      final responseData = json.decode(response.body);
      print('response edit in');
      print(response.statusCode);
      print(response.body);

      RepositoryServiceTodo.updateWorkdayInL(
          workday, fec.toIso8601String().toString());

      await RepositoryServiceTodo.updateUltClock(
          workday, DateTime.now().toIso8601String().toString());

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

  Future<dynamic> editWorkdayOut(workdayy, start, time) async {
    String? token = await getToken();
    DateTime now = DateTime.now();
    int wk = workdayy;
    workday = await getWorkday(1);
    String s_d = start.toString().substring(0, 11) +
        time.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);

    print(workdayy);
    print(s_d);
    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name + '/api/v-1/workday/$wk/update'),
          body: json.encode({
            'default_exit_time': fec.toIso8601String().toString(),
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      notifyListeners();
      final responseData = json.decode(response.body);
      print('response edit in');
      print(response.statusCode);
      print(response.body);

      RepositoryServiceTodo.updateWorkdayOutL(
          workday, fec.toIso8601String().toString());
      await RepositoryServiceTodo.updateUltClock(
          workday, DateTime.now().toIso8601String().toString());

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

  Future<dynamic> addClockIn(worker, time, geo, wd, temp, valid_temp) async {
    print('llego pv clockin');
    DateTime now = DateTime.now();
    print(wd);
    int workday = wd['workday_id'];
    DateTime clockin;
    String? token = await getToken();

    print(workday);
    print(geo);
    print(temp);

    clockin = DateTime.parse(wd['default_init']);

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$workday/workday-register/create';
    try {
      if (valid_temp == 'true') {
        print('aa');
        final response = await http.post(Uri.parse(url),
            body: json.encode({
              'workday': workday,
              'worker': worker,
              'clock_type': 'IN',
              'clock_datetime': clockin.toIso8601String().toString(),
              'message': 'message',
              'geographical_coordinates': geo,
              'verified': true,
              'temperature': temp
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

        await RepositoryServiceTodo.updateUltClock(
            workday, DateTime.now().toIso8601String().toString());
        // print(responseData);
        notifyListeners();

        return response.statusCode.toString();
      } else {
        print('bb');

        final response = await http.post(Uri.parse(url),
            body: json.encode({
              'workday': workday,
              'worker': worker,
              'clock_type': 'IN',
              'clock_datetime': time != null
                  ? time.toIso8601String().toString()
                  : clockin.toIso8601String().toString(),
              'message': 'message',
              'geographical_coordinates': geo,
              'verified': true,
              'temperature': 0
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

        return response.statusCode.toString();
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockInExt(worker, time, geo, wd, temp) async {
    print('llego pv clockin');
    DateTime now = DateTime.now();
    print(wd);
    int workday = wd['workday_id'];
    String? token = await getToken();

    print(workday);
    print(geo);

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$workday/workday-register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': workday,
            'worker': worker,
            'clock_type': 'IN',
            'clock_datetime': now.toIso8601String().toString(),
            'message': 'message',
            'geographical_coordinates': geo,
            'verified': true,
            'temperature': temp
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockInM(workday, worker, time, comment, geo, temp) async {
    print('llego pv clockin m');
    String? token = await getToken();

    DateTime now = DateTime.now();

    print(workday);
    print('data');

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$workday/workday-register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': workday,
            'worker': worker,
            'clock_type': 'IN',
            'clock_datetime': now.toIso8601String().toString(),
            'message': comment,
            'geographical_coordinates': geo,
            'verified': true,
            'temperature': temp
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockOut(worker, time, geo, wd) async {
    print('llego pv clockout');
    String? token = await getToken();
    int _workday = wd['workday_id'];
    DateTime now = DateTime.now();
    DateTime clockin;

    print(workday);
    print(worker);
    print(wd);

    clockin = DateTime.parse(wd['default_exit'].toString());

    final url =
        '${ApiWebServer.server_name}/api/v-1/workday/$_workday/workday-register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': _workday.toString(),
            'worker': worker,
            'clock_type': 'OUT',
            'clock_datetime': clockin.toIso8601String().toString(),
            'message': 'message',
            'geographical_coordinates': geo,
            'verified': true,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);

      await RepositoryServiceTodo.updateUltClock(
          workday, DateTime.now().toIso8601String().toString());
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();

      return 1 /*Clocks.fromJson(responseData)*/;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockOutM(worker, time, geo, wd, motiv, loc) async {
    print('llego pv clockout manual');
    String? token = await getToken();
    int _workday = wd['workday_id'];
    DateTime now = DateTime.now();
    int motivo;

    print(workday);
    print(worker);

    if (motiv == 'Ausente con permiso de trabajo') {
      motivo = 6;
    } else if (motiv == 'Ausente por enfermedad') {
      motivo = 2;
    } else if (motiv == 'Ausente por accidente') {
      motivo = 3;
    } else if (motiv == 'Abandono del trabajo') {
      motivo = 4;
    } else if (motiv == 'Ausente sin justificación') {
      motivo = 5;
    } else if (motiv == 'Se retiro sin clock-in') {
      motivo = 7;
    } else {
      motivo = 1;
    }

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$_workday/workday-register/manual-create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': _workday.toString(),
            'worker': worker,
            'clock_type': 'OUT',
            'clock_datetime': time.toIso8601String().toString(),
            'absence_excuse': geo != null ? geo : '',
            'geographical_coordinates': loc,
            'worker_status': motivo,
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
      Map<String, dynamic> success = {
        "data": responseData,
        "status": response.statusCode.toString()
      };
      // print(responseData);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> selfClockIn(worker, workday, temp, time, geo) async {
    print('llego pv clockout selfclockin');
    String? token = await getToken();

    DateTime clockin;
    DateTime now = DateTime.now().toUtc();

    if (workday['clock_in_fin'] != '') {
      clockin = now;
    } else {
      clockin = DateTime.parse(workday['clock_in_init']);
    }

    int wd = workday['workday_id'];
    print('data selfclock');
    print(workday['workday_id']);
    print(worker);
    print(clockin);
    print(temp);

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$wd/workday-register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': workday['workday_id'].toString(),
            'worker': worker,
            'clock_type': 'IN',
            'temperature': temp.toString(),
            'geographical_coordinates': geo,
            'clock_datetime': clockin.toIso8601String().toString(),
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> selfClockOut(worker, workday, time, geo) async {
    print('llego pv clockout selfclockout');
    String? token = await getToken();

    DateTime clockout;
    DateTime now = DateTime.now().toUtc();

    print(workday);
    print(worker);
    int wd = workday['workday_id'];

    if (workday['clock_out_fin'] != '') {
      clockout = now;
    } else {
      clockout = DateTime.parse(workday['clock_out_init']);
    }

    print(workday);
    print(worker);

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$wd/workday-register/create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': workday['workday_id'].toString(),
            'worker': worker,
            'clock_type': 'OUT',
            'geographical_coordinates': geo,
            'clock_datetime': clockout.toIso8601String().toString(),
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockOutE(worker, time, geo, wd, motiv) async {
    print('llego pv clockout extemporaneo');
    String? token = await getToken();
    int _workday = wd['workday_id'];
    DateTime now = DateTime.now().toUtc();
    int motivo;

    print(workday);
    print(worker);
    DateFormat format = DateFormat("hh:mm");

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$_workday/workday-register/manual-create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': _workday.toString(),
            'worker': worker,
            'clock_type': 'OUT',
            'clock_datetime':
                format.format(time), //time.toIso8601String().toString(),
            'absence_excuse': geo != null ? geo : '',
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addClockOutESC(worker, time, geo, wd, motiv) async {
    print('llego pv clockout extemporaneo');
    String? token = await getToken();
    int _workday = wd['workday_id'];
    DateTime now = DateTime.now().toUtc();

    print(workday);
    print(worker);
    DateFormat format = DateFormat("hh:mm");

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/$_workday/workday-register/manual-create';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'workday': _workday.toString(),
            'worker': worker,
            'clock_type': 'OUT',
            'clock_datetime': time.toUtc().toIso8601String().toString(),
            'absence_excuse': geo != null ? geo : '',
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editAdsentWorkday(
    register,
    geo,
    motiv,
  ) async {
    String? token = await getToken();
    int _workday = register;
    int motivo;

    print(register);

    if (motiv == 'Ausente con permiso de trabajo') {
      motivo = 6;
    } else if (motiv == 'Ausente por enfermedad') {
      motivo = 2;
    } else if (motiv == 'Ausente por accidente') {
      motivo = 3;
    } else if (motiv == 'Abandono del trabajo') {
      motivo = 4;
    } else if (motiv == 'Ausente sin justificación') {
      motivo = 5;
    } else {
      motivo = 1;
    }

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/workday-register/$_workday/update-worker-status';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'absence_excuse': geo != null ? geo : '',
            'worker_status': motivo,
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

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> endClockIn(workday, geo, userId) async {
    DateTime now = DateTime.now();
    int _user = await getUser();
    int _workday = workday;
    String? token = await getToken();
    config = await getTodo(1);
    workday = await getWorkday(1);
    print('end lock');
    print(workday);
    print(geo);
    print(userId);
    print(_user);
    final url = ApiWebServer.server_name + '/api/v-1/workday/$_workday/update';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'clock_in_finisher': userId,
            'clock_in_end': now.toIso8601String(),
            'geographical_coordinates': geo,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      RepositoryServiceTodo.updateWorkdayInFin(
        workday,
        responseData['clock_in_end'],
      );

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

  Future<dynamic> endClockOut(workdayy, geo, userId) async {
    print(workdayy);
    print(userId);
    DateTime now = DateTime.now();
    workday = await getWorkday(1);
    String? token = await getToken();

    final url = ApiWebServer.server_name + '/api/v-1/workday/$workdayy/update';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'clock_out_finisher': userId,
            'clock_out_end': now.toIso8601String(),
            'geographical_coordinates': geo,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);

      RepositoryServiceTodo.updateWorkdayOutFin(
        workday,
        now.toIso8601String(),
      );

      RepositoryServiceTodo.updateUltClock(workday, "");
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<Workday> fetchWorkDay() async {
    String? token = await getToken();
    workday = await getWorkday(1);

    print('token de auth');
    print(token);
    print('${ApiWebServer.server_name}/api/v-1/workday/get-current');

    final response = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/workday/get-current'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Token $token"
        });

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      //Map<String, dynamic> wdData = json.decode(response.body);

      // Map<String, dynamic> wdData = json.decode(response.body);

      Map<String, dynamic> wdData =
          json.decode(utf8.decode(response.bodyBytes));
      print('wddta');
      print(wdData);
      //  print(wdData);
      /*if (wdData['id'] != null) {
        print('a');
        print(wdData['clock_out_end']);*/
      RepositoryServiceTodo.updateWorkdaySync(
        workday,
        wdData['id'] != null ? wdData['id'] : '',
        wdData['clock_in_start'] != null ? wdData['clock_in_start'] : '',
        wdData['clock_in_end'] != null ? wdData['clock_in_end'] : '',
        wdData['clock_out_start'] != null ? wdData['clock_out_start'] : '',
        wdData['clock_out_end'] != null ? wdData['clock_out_end'] : '',
        wdData['clock_in_location'] != null
            ? wdData['clock_in_location'].toString()
            : '',
        wdData['clock_out_location'] != null
            ? wdData['clock_out_location'].toString()
            : '',
        wdData['has_report'] != null ? wdData['has_report'] : '',
        wdData['has_clocked_in'] != null ? wdData['has_clocked_in'] : false,
        wdData['default_entry_time'] != null
            ? wdData['default_entry_time']
            : '',
        wdData['default_exit_time'] != null ? wdData['default_exit_time'] : '',
        wdData['has_clocked_out'] != null ? wdData['has_clocked_out'] : false,
      );
      //}
      return new Workday.fromJson(wdData);
    } else {
      return Workday.fromJson({});
    }
  }

  Future<dynamic> addWorkdayReport(
      workday,
      workday_entry_time,
      workday_departure_time,
      lunch_start_time,
      lunch_end_time,
      lunch_duration,
      // ignore: non_constant_identifier_names
      drivers_list,
      standby_start_time,
      standby_end_time,
      standby_duration,
      travel_start_time,
      travel_end_time,
      travel_duration,
      return_start_time,
      return_end_time,
      return_duration,
      comments,
      files) async {
    late String lunch;
    late String stand;
    late String travel;
    late String returnt;
    String? token = await getToken();

    print('llego a pv create workday report');

    if (lunch_duration != null) {
      lunch = '00:' + lunch_duration;
      print(lunch);
    }
    if (standby_duration != null) {
      stand = '00:' + standby_duration;
      print(stand);
    }
    if (travel_duration != null) {
      travel = '00:' + travel_duration;
      print(travel);
    }
    if (return_duration != null) {
      returnt = '00:' + return_duration;
      print(returnt);
    }
    print(workday_entry_time.toIso8601String());

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/create'),
          body: json.encode({
            "workday": workday.toString(),
            "workday_entry_time": workday_entry_time != null
                ? workday_entry_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "workday_departure_time": workday_departure_time != null
                ? workday_departure_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "lunch_start_time": lunch_start_time != null
                ? lunch_start_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "lunch_end_time": lunch_end_time != null
                ? lunch_end_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "lunch_duration": lunch_duration != null ? lunch : '00:00',
            "standby_start_time": standby_start_time != null
                ? standby_start_time.toIso8601String()
                : '00:00',
            "standby_end_time": standby_end_time != null
                ? standby_end_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "standby_duration": standby_duration != null ? stand : '00:00',
            "travel_start_time": travel_start_time != null
                ? travel_start_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "travel_end_time": travel_end_time != null
                ? travel_end_time.toIso8601String()
                : '00:00',
            "travel_duration": travel_duration != null ? travel : '00:00',
            "return_start_time": return_start_time != null
                ? return_start_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "return_end_time": return_end_time != null
                ? return_end_time.toIso8601String()
                : '0000-00-00T00:00:00.000',
            "return_duration": return_duration != null ? returnt : '00:00',
            "comments": comments != null ? comments : '0',
            "drivers_list": drivers_list != null ? drivers_list : []
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      int w_report = responseData['workday'];
      print(responseData);
      print(response.statusCode);
      notifyListeners();

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addWorkdayReportBase(workdayy, workday_entry_time,
      workday_departure_time, start_date, end_date) async {
    DateTime now = DateTime.now();
    String? token = await getToken();
    int _user = await getUser();
    workday = await getWorkday(1);
    late String s_d;
    late String e_d;

    print('llego');
    print(workday_entry_time);
    print(workday_departure_time);
    print(start_date);
    print(end_date);

    if (workday_entry_time != null && workday_departure_time != null) {
      s_d = start_date.toString().substring(0, 11) +
          workday_entry_time.toString().substring(10, 23).replaceAll(" ", "");
      e_d = end_date.toString().substring(0, 11) +
          workday_departure_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
    }
    DateTime fec = DateTime.parse(s_d);
    DateTime fecs = DateTime.parse(e_d);

    Map<String, dynamic> data = {
      "workday": workdayy.toString(),
      "had_workday": true
    };

    print(data);

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/create'),
          body: json.encode(data),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });

      final responseData = json.decode(response.body);
      print(responseData);
      RepositoryServiceTodo.updateWorkdayFin(workday);
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "report": responseData['id']
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addWorkdayReportSJ() async {
    String? token = await getToken();

    Map<String, dynamic> data = {"had_workday": false};

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/create'),
          body: json.encode(data),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });

      final responseData = json.decode(response.body);
      print(responseData);
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "report": responseData
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addWorkdayReportNO(
    workday,
    comments,
  ) async {
    String? token = await getToken();
    int _user = await getUser();

    Workday workdayy = await getWorkday(1);
    DateTime now = DateTime.now().toUtc();

    print(workday.id);
    print(comments);

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/create'),
          body: json.encode({
            "workday": workday.id,
            "comments": comments,
            'workday_entry_time': now.toIso8601String(),
            'workday_departure_time': now.toIso8601String(),
            "had_workday": false,
            "is_finalized": true
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });

      RepositoryServiceTodo.updateWorkdayGuardado(workdayy);
      RepositoryServiceTodo.updateWorkdayFin(workdayy);

      /* final response1 = await http
          .patch(ApiWebServer.server_name + '/api/v-1/workday/$workday/update',
              body: json.encode({
                'clock_out_finisher': _user,
                'clock_out_end': now.toIso8601String(),
                'geographical_coordinates': '--- ---'
              }),
              headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token $token"
          });*/
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "report": responseData['id']
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> addWorkdayReportNOJ(workday) async {
    DateTime now = DateTime.now();
    String? token = await getToken();
    int _user = await getUser();

    Workday workdayy = await getWorkday(1);

    print(workday);

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/create'),
          body: json.encode({
            "workday": workday.toString(),
            "had_workday": false,
            "is_cancelled": true
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });

      RepositoryServiceTodo.updateWorkdayGuardado(workdayy);
      RepositoryServiceTodo.updateWorkdayFin(workdayy);

      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "report": responseData
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReport1(
      lunch_start_time, lunch_end_time, lunch_duration, report) async {
    String lunch;

    print(workday);
    print(lunch_start_time);
    print(lunch_end_time);
    print(lunch_duration);
    print(report);
    String? token = await getToken();

    DateFormat format = DateFormat("hh:mm");
    if (lunch_duration != null) {
      lunch = '00:' + lunch_duration;
      print(lunch);
    }

    Map<String, dynamic> data;
    data = {};

    if (lunch_start_time != null && lunch_end_time != null) {
      data = {
        "id": report.toString(),
        "lunch_start_time": lunch_start_time.toUtc().toIso8601String(),
        "lunch_end_time": lunch_end_time.toUtc().toIso8601String()
      };
    } else {
      data = {
        "id": report.toString(),
        "lunch_duration": '00:' + lunch_duration + ':00',
      };
    }
    print(data);

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/$report/update'),
          body: json.encode(data),
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
        "report": responseData['id']
      };
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReportVerified(
      workday, WorkdayRegister? report) async {
    String? token = await getToken();
    int rep = report!.id;
    try {
      final response = await http.patch(
          Uri.parse(
              '${ApiWebServer.server_name}/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode([
            {"id": rep.toString(), "editor": 1}
          ]),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportEntry(
      entry, departure, report, start, end) async {
    print(entry);
    print(departure);

    print(report);
    String? token = await getToken();

    late String s_d;
    late String e_d;

    if (entry != null && departure != null) {
      s_d = start.toString().substring(0, 11) +
          entry.toString().substring(10, 23).replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          departure.toString().substring(10, 23).replaceAll(" ", "");
    } else if (entry != null && departure == null) {
      print('2 if');
      s_d = start.toString().substring(0, 11) +
          entry.toString().substring(10, 23).replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          report['workday_departure_time']
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      print(e_d);
    } else if (entry == null && departure != null) {
      print('3 if');
      s_d = start.toString().substring(0, 11) +
          report['workday_entry_time']
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          departure.toString().substring(10, 23).replaceAll(" ", "");
      print(e_d);
    } else if (entry == null && departure == null) {
      print('4 if');
      s_d = start.toString().substring(0, 11) +
          report['workday_entry_time']
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          report['workday_departure_time']
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
    }
    DateTime fec = DateTime.parse(s_d);
    DateTime fecs = DateTime.parse(e_d);

    int wk = report['workday'];
    int rep = report['id'];
    print('horas finales');
    print(fec.toIso8601String().toString());
    print(fecs.toIso8601String().toString());

    try {
      final response = await http.patch(
          Uri.parse(
              '${ApiWebServer.server_name}/api/v-1/workday/workday-report/$rep/update'),
          body: json.encode({
            "id": report.toString(),
            "workday_entry_time": entry != null
                ? fec.toIso8601String().toString()
                : report['workday_entry_time'],
            "workday_departure_time": departure != null
                ? fecs.toIso8601String().toString()
                : report['workday_departure_time'],
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
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "report": responseData['id']
      };
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReportStandBy(init, fin, duration, report) async {
    String? token = await getToken();

    int wk = report['workday'];
    int rep = report['id'];
    late String lunch;

    if (duration != null) {
      lunch = duration;
      print(lunch);
      print('dura');
    }

    Map<String, dynamic> datasta;
    datasta = {};

    if (init != null) {
      datasta = {
        "id": report.toString(),
        "standby_start_time": init.toUtc().toIso8601String(),
        "standby_end_time": fin.toUtc().toIso8601String()
      };
    } else {
      datasta = {
        "id": report.toString(),
        "standby_duration": '00:$lunch:00',
      };
    }

    print('esdata');

    print(wk);
    print(rep);
    print(init);
    print(fin);

    if (duration != null) {
      print('aqui');
      try {
        final response = await http.patch(
            Uri.parse(ApiWebServer.server_name +
                '/api/v-1/workday/$wk/workday-report/$rep/update'),
            body: json.encode({
              "id": report.toString(),
              "standby_duration": '00:' + lunch + ':00',
            }),
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
          "report": responseData['id']
        };
        notifyListeners();

        return success;
      } catch (error) {
        print(error);
        throw error;
      }
    } else {
      print('aqui2222');

      try {
        final response = await http.patch(
            Uri.parse(ApiWebServer.server_name +
                '/api/v-1/workday/$wk/workday-report/$rep/update'),
            body: json.encode({
              "id": report,
              "standby_start_time": init.toUtc().toIso8601String(),
              "standby_end_time": fin.toUtc().toIso8601String()
            }),
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
          "report": responseData['id']
        };
        notifyListeners();

        return success;
      } catch (error) {
        print(error);
        throw error;
      }
    }
  }

  Future<dynamic> addWorkdayVehicle(workday, drivers, report) async {
    print('llego a pv edit workday report drivers');

    List<Map<String, dynamic>> dataS;
    dataS = [];

    drivers.asMap().forEach((i, value) {
      dataS.add({
        "workday_report": report,
        "user": value,
        "has_driver_role": true,
      });
    });

    print(drivers);
    print(report);
    print(dataS);

    DateFormat format = DateFormat("hh:mm");
    String? token = await getToken();

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/workday-vehicle/create'),
          body: json.encode(dataS),
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

  Future<dynamic> addWorkdayVehicleWorkers(workday, drivers, report) async {
    print('llego a pv edit workday report drivers');

    List<Map<String, dynamic>> dataS;
    dataS = [];

    drivers.asMap().forEach((i, value) {
      dataS.add({
        "workday_report": report,
        "user": value['worker_id'],
        "vehicle": value['vehicle'],
        "has_driver_role": false
      });
    });

    print(drivers);
    print(report);
    print(dataS);

    DateFormat format = DateFormat("hh:mm");
    String? token = await getToken();

    try {
      final response = await http.post(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/workday-vehicle/create'),
          body: json.encode(dataS),
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

  Future<dynamic> deleteWorkdayVehicle(workday_vehicles) async {
    print('llego a pv edit workday report drivers');

    List<Map<String, dynamic>> dataS;
    dataS = [];

    workday_vehicles.asMap().forEach((i, value) {
      dataS.add({
        "id": value['id'],
      });
    });

    print(dataS);

    DateFormat format = DateFormat("hh:mm");
    String? token = await getToken();

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/workday-vehicle/delete'),
          body: json.encode(dataS),
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

  Future<dynamic> editWorkdayReport3(workday, standby_start_time,
      standby_end_time, standby_duration, report) async {
    String lunch;

    print('llego a pv edit workday report 3');

    print(workday);
    print(standby_start_time);
    print(standby_end_time);
    print(report);
    String? token = await getToken();

    DateFormat format = DateFormat("hh:mm");
    if (standby_duration != null) {
      lunch = '00:' + standby_duration;
      print(lunch);
    }

    Map<String, dynamic> data;
    data = {};

    if (standby_start_time != null) {
      data = {
        "id": report.toString(),
        "lunch_start_time": standby_start_time.toUtc().toIso8601String(),
        "lunch_end_time": standby_end_time.toUtc().toIso8601String()
      };
    } else {
      data = {
        "id": report.toString(),
        "standby_duration": '00:' + standby_duration + ':00',
      };
    }

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/$report/update'),
          body: json.encode(data),
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
        "report": responseData['id']
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReportMSJ(
      duration, init, fin, workerT, workday) async {
    String? token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    if (init != null) {
      workerT.asMap().forEach((i, value) {
        dataS.add({
          "id": value,
          "standby_start_time": init.toUtc().toIso8601String(),
          "standby_end_time": fin.toUtc().toIso8601String(),
        });
      });
    } else {
      workerT.asMap().forEach((i, value) {
        dataS.add({
          "id": value,
          "standby_duration": '00:' + duration + ':00',
        });
      });
    }

    print(dataS);

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/worker-report/update'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      notifyListeners();

      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "data": responseData
      };
      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReport4(workday, travel_start_time,
      travel_end_time, travel_duration, report) async {
    String lunch;

    print('llego a pv edit workday report 3');

    print(workday);
    print(travel_start_time);
    print(travel_end_time);
    print(report);
    String? token = await getToken();

    DateFormat format = DateFormat("hh:mm");
    if (travel_duration != null) {
      lunch = '00:' + travel_duration;
      print(lunch);
    }

    Map<String, dynamic> data;
    data = {};

    if (travel_start_time != null) {
      data = {
        "id": report.toString(),
        "travel_start_time": travel_start_time.toUtc().toIso8601String(),
        "travel_end_time": travel_end_time.toUtc().toIso8601String()
      };
    } else {
      data = {
        "id": report.toString(),
        "travel_duration": '00:' + travel_duration + ':00',
      };
    }

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/$report/update'),
          body: json.encode(data),
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
        "report": responseData['id']
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReport5(workdayy, comments, report) async {
    print(comments);
    print(report);
    workday = await getWorkday(1);
    String? token = await getToken();

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/$report/update'),
          body: json.encode({
            "id": report.toString(),
            "comments": comments,
            //"is_finalized": true
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);

      RepositoryServiceTodo.updateWorkdayGuardado(workday);
      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "report": responseData['id']
      };
      print(success);
      notifyListeners();

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> editWorkdayReportG(
      workday,
      workday_entry_time,
      workday_departure_time,
      lunch_start_time,
      lunch_end_time,
      lunch_duration,
      // ignore: non_constant_identifier_names
      drivers_list,
      standby_start_time,
      standby_end_time,
      standby_duration,
      travel_start_time,
      travel_end_time,
      travel_duration,
      return_start_time,
      return_end_time,
      WorkdayRegister worday_register) async {
    String? token = await getToken();

    print('llego a pv edit workday report gral');

    print(worday_register.workday_entry_time.toIso8601String());
    print(worday_register.workday_departure_time);

    print(worday_register.id);
    int report = worday_register.id;

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/workday-report/$report/update'),
          body: json.encode({
            //"id": report.toString(),
            "workday_entry_time": workday_entry_time != null
                ? workday_entry_time.toUtc().toIso8601String()
                : worday_register.workday_entry_time,
            "workday_departure_time": workday_departure_time != null
                ? workday_departure_time.toUtc().toIso8601String()
                : worday_register.workday_departure_time,
            "lunch_start_time": lunch_start_time != null
                ? lunch_start_time.toUtc().toIso8601String()
                : null,
            "lunch_end_time": lunch_end_time != null
                ? lunch_end_time.toUtc().toIso8601String()
                : null,
            "lunch_duration": lunch_duration != null
                ? '00:' + lunch_duration + ':00'
                : worday_register.lunch_duration,
            "standby_start_time": standby_start_time != null
                ? standby_start_time.toUtc().toIso8601String()
                : null,
            "standby_end_time": standby_end_time != null
                ? standby_end_time.toUtc().toIso8601String()
                : null,
            "standby_duration": standby_duration != null
                ? '00:' + standby_duration + ':00'
                : worday_register.standby_duration,
            "travel_start_time": travel_start_time != null
                ? travel_start_time.toUtc().toIso8601String()
                : null,
            "travel_end_time": travel_end_time != null
                ? travel_end_time.toUtc().toIso8601String()
                : null,
            "travel_duration": travel_duration != null
                ? '00:' + travel_duration + ':00'
                : worday_register.travel_duration,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReport(
      workday,
      workday_entry_time,
      workday_departure_time,
      WorkdayRegister? worday_register,
      start,
      end) async {
    int report = worday_register!.id;
    String? token = await getToken();

    print('llego a pv edit workday report');
    late String s_d;
    late String e_d;

    print('llego edit ind');
    print(worday_register.workday_entry_time);
    print(worday_register.workday_departure_time);

    if (workday_entry_time != null && workday_departure_time != null) {
      s_d = start.toString().substring(0, 11) +
          workday_entry_time.toString().substring(10, 23).replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          workday_departure_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
    } else if (workday_entry_time != null && workday_departure_time == null) {
      print('2 if');
      s_d = start.toString().substring(0, 11) +
          workday_entry_time.toString().substring(10, 23).replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          worday_register.workday_departure_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      print(e_d);
    } else if (workday_entry_time == null && workday_departure_time != null) {
      print('3 if');
      s_d = start.toString().substring(0, 11) +
          worday_register.workday_entry_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          workday_departure_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      print(e_d);
    } else if (workday_entry_time == null && workday_departure_time == null) {
      print('4 if');
      s_d = start.toString().substring(0, 11) +
          worday_register.workday_entry_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
      e_d = end.toString().substring(0, 11) +
          worday_register.workday_departure_time
              .toString()
              .substring(10, 23)
              .replaceAll(" ", "");
    }
    DateTime fec = DateTime.parse(s_d);
    DateTime fecs = DateTime.parse(e_d);
    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode([
            {
              "id": report.toString(),
              "workday_entry_time": workday_entry_time != null
                  ? fec.toIso8601String().toString()
                  : worday_register.workday_entry_time.toIso8601String(),
              "workday_departure_time": workday_departure_time != null
                  ? fecs.toIso8601String().toString()
                  : worday_register.workday_departure_time.toIso8601String(),
            }
          ]),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportLunch(workday, workday_entry_time,
      workday_departure_time, WorkdayRegister? worday_register) async {
    int report = worday_register!.id;

    print('llego a pv edit workday report');
    print(workday_entry_time);
    print(workday_departure_time);

    String? token = await getToken();

    //2020-09-30T20:22:04Z

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode([
            {
              "id": report.toString(),
              "lunch_start_time":
                  workday_entry_time.toIso8601String().toString(),
              "lunch_end_time":
                  workday_departure_time.toIso8601String().toString(),
            }
          ]),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportStand(workday, workday_entry_time,
      workday_departure_time, WorkdayRegister? worday_register) async {
    int report = worday_register!.id;

    print('llego a pv edit workday report');
    print(workday_entry_time);
    print(workday_departure_time);

    String? token = await getToken();

    //2020-09-30T20:22:04Z

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode([
            {
              "id": report.toString(),
              "standby_start_time":
                  workday_entry_time.toIso8601String().toString(),
              "standby_end_time":
                  workday_departure_time.toIso8601String().toString(),
            }
          ]),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportTravel(workday, workday_entry_time,
      workday_departure_time, WorkdayRegister? worday_register) async {
    int report = worday_register!.id;

    print('llego a pv edit workday report');
    print(workday_entry_time);
    print(workday_departure_time);

    String? token = await getToken();

    //2020-09-30T20:22:04Z

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode([
            {
              "id": report.toString(),
              "travel_start_time":
                  workday_entry_time.toIso8601String().toString(),
              "travel_end_time":
                  workday_departure_time.toIso8601String().toString(),
            }
          ]),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportM1(workday, workday_entry_time,
      workday_departure_time, workerT, start, end) async {
    String? token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];
    String s_d;
    String e_d;

    s_d = start.toString().substring(0, 11) +
        workday_entry_time.toString().substring(10, 23).replaceAll(" ", "");
    e_d = end.toString().substring(0, 11) +
        workday_departure_time.toString().substring(10, 23).replaceAll(" ", "");

    DateTime fec = DateTime.parse(s_d);
    DateTime fecs = DateTime.parse(e_d);

    workerT.asMap().forEach((i, value) {
      dataS.add({
        "id": value,
        "workday_entry_time": fec.toIso8601String().toString(),
        "workday_departure_time": fecs.toIso8601String().toString()
      });
    });

    print(dataS);

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportM2(
      workday, workday_entry_time, workday_departure_time, workerT) async {
    String? token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    workerT.asMap().forEach((i, value) {
      dataS.add({
        "id": value,
        "lunch_entry_time": workday_entry_time.toIso8601String().toString(),
        "lunch_departure_time":
            workday_departure_time.toIso8601String().toString()
      });
    });

    print(dataS);

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportM3(
      workday, workday_entry_time, workday_departure_time, workerT) async {
    String? token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    workerT.asMap().forEach((i, value) {
      dataS.add({
        "id": value,
        "workday_entry_time": workday_entry_time.toIso8601String().toString(),
        "workday_departure_time":
            workday_departure_time.toIso8601String().toString()
      });
    });

    print(dataS);

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
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

  Future<dynamic> editWorkdayReportM4(
      workday, workday_entry_time, workday_departure_time, workerT) async {
    String? token = await getToken();

    List<Map<String, dynamic>> dataS;
    dataS = [];

    workerT.asMap().forEach((i, value) {
      dataS.add({
        "id": value,
        "workday_entry_time": workday_entry_time.toIso8601String().toString(),
        "workday_departure_time":
            workday_departure_time.toIso8601String().toString()
      });
    });

    print(dataS);

    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/workday/$workday/workday-report/worker-report/update'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      notifyListeners();

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> aceptReport(wr, wkr) async {
    print('llego pv en clock in');
    DateTime now = DateTime.now();
    int _user = await getUser();
    String? token = await getToken();

    final url = ApiWebServer.server_name +
        '/api/v-1/workday/workday-report/$wkr/worker-report/accept';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode({
            'is_accepted': true,
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<dynamic> sendReport(report) async {
    String? token = await getToken();
    workday = await getWorkday(1);

    var res = await http.get(
        Uri.parse(ApiWebServer.server_name +
            '/api/v-1/workday/workday-report/$report/worker-report/send-notifications'),
        headers: {"Authorization": "Token $token"});

    print(res.body);

    // RepositoryServiceTodo.updateWorkdayFinalizado(workday);
    RepositoryServiceTodo.updateWorkdayFin(workday);

    return res.statusCode;
  }

  Future<dynamic> sendReportC(report) async {
    String? token = await getToken();
    workday = await getWorkday(1);

    var res = await http.get(
        Uri.parse(ApiWebServer.server_name +
            '/api/v-1/workday/workday-report/$report/send_to_customer'),
        headers: {"Authorization": "Token $token"});

    print(res.body);

    // RepositoryServiceTodo.updateWorkdayFinalizado(workday);
    RepositoryServiceTodo.updateWorkdayFin(workday);

    return res.statusCode;
  }

  Future<dynamic> finWorkday(workdayy) async {
    String? token = await getToken();
    workday = await getWorkday(1);
    print('llego a pv');
    print(workdayy);

    var response = await http.patch(
        Uri.parse(
            ApiWebServer.server_name + '/api/v-1/workday/$workdayy/finalize'),
        body: json.encode({
          'is_finalized': true,
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Token" + " " + "$token"
        });
    final responseData = json.decode(response.body);
    print(responseData);
    print(response.statusCode);

    return response.statusCode.toString();
  }

  Future<dynamic> rejectedReport(wr, wkr, reason) async {
    print(wr);
    print(wkr);
    print(reason);
    String? token = await getToken();
    final url = ApiWebServer.server_name +
        '/api/v-1/workday/workday-report/$wr/worker-report/$wkr/send-rejected-report';
    try {
      final response = await http.patch(Uri.parse(url),
          body: json.encode(
              {'id': wkr, 'is_accepted': false, 'reject_reason': reason}),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);
      // print(responseData);
      notifyListeners();

      return response.statusCode.toString();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
