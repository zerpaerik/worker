// ignore_for_file: unused_import

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../model/http_exception.dart';
import '../model/user.dart';
import '../model/contract.dart';
import '../widgets/global.dart';
import '../local/database_creator.dart';
import '../local/service.dart';

enum Status { Uninitialized, Authenticated, Authenticating, Unauthenticated }

class Auth with ChangeNotifier {
  late String _token;
  late String _name;
  late String _lastname;

  late String _btn_id;
  late String _email;
  late String _image;
  late String _id_type;
  late String _doc_type;
  late String _contact;

  late String _docType;
  late String _docTypeN;
  late String _type;
  late String _role;
  late String _addres;
  late int _userId;
  late int _contract;
  late String _typeE;
  late String _hi;
  late String _ei;
  List locations = [];
  // ignore: unused_field
  late String _he;
  // ignore: unused_field
  late String _ee;
  Status _status = Status.Uninitialized;
  late Config config;
  late Contract contract;
  late int id_type;
  late int documents;
  late int health;

  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  Status get status {
    return _status;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_token != null) {
      return _token;
    }
    return "";
  }

  int get user {
    return _userId;
  }

  getTodo(int id) async {
    const sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);
    print('data first');
    print(data);

    final todo = Config.fromJson(data.first);

    return todo;
  }

  getContract(int id) async {
    const sql = '''SELECT * FROM ${DatabaseCreator.todoTable5}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final contract = Contract.fromJson(data.first);

    return contract;
  }

  Future<dynamic> update0(User user, gender) async {
    String? token = await getToken();
    print('llego a pv');

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['first_name'] = user.first_name.toString();
    request.fields['last_name'] = user.last_name.toString();
    request.fields['birth_date'] = format.format(user.birth_date);
    //request.fields['birthplace'] = country;
    request.fields['gender'] = '1';
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

  Future<dynamic> update1(image) async {
    String? token = await getToken();
    config = await getTodo(1);
    print('pv upload image');

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.files
        .add(await http.MultipartFile.fromPath('profile_image', image.path));
    var streamedResponse = await request.send();

    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);
    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isImage", true);
      RepositoryServiceTodo.updateImage(
          config, success['data']['details']['profile_image']);

      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> update2(String type) async {
    print(id_type);
    if (type == 'SSN') {
      id_type = 1;
    } else if (type == 'ITIN') {
      id_type = 2;
    } else if (type == 'SSN en proceso' || type == "SSN in process") {
      id_type = 3;
    } else if (type == 'ITIN en proceso' || type == "ITIN in process") {
      id_type = 4;
    } else {
      id_type = 5;
    }

    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['id_type'] = id_type.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    print(config.id);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isIdType", true);
      prefs.setString('type', id_type.toString());
      RepositoryServiceTodo.updateType(config, id_type.toString());
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

  Future<dynamic> update21(User user) async {
    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['id_number'] = user.id_number.toString();
    /*request.files
        .add(await http.MultipartFile.fromPath('tax_doc_file', photo.path));*/
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("id_number_type", true);
      RepositoryServiceTodo.updateDoc(config, user.id_number.toString());

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

  Future<dynamic> update22(photo) async {
    print(photo);
    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.files
        .add(await http.MultipartFile.fromPath('tax_doc_file', photo.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("id_image_type", true);
      RepositoryServiceTodo.updateDoc(config, photo.path.toString());

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

  Future<dynamic> updatetax(type, number, photo) async {
    print('edita tax document');

    print(photo);
    String? token = await getToken();
    config = await getTodo(1);

    if (type == 'SSN') {
      id_type = 1;
    } else if (type == 'ITIN') {
      id_type = 2;
    } else if (type == 'SSN en proceso' || type == "SSN in process") {
      id_type = 3;
    } else if (type == 'ITIN en proceso' || type == "ITIN in process") {
      id_type = 4;
    } else {
      id_type = 5;
    }

    print('id_type');
    print(id_type);

    if (id_type == 1 || id_type == 2) {
      Map<String, String> headers = {"Authorization": "Token $token"};
      var postUri = Uri.parse(
          '${ApiWebServer.server_name}/api/v-1/user/tax-documents/update');
      var request = http.MultipartRequest("PATCH", postUri);
      request.headers.addAll(headers);
      request.fields['id_number'] = number.toString();
      request.fields['id_type'] = id_type.toString();
      request.files
          .add(await http.MultipartFile.fromPath('tax_doc_file', photo.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("id_image_type", true);
        RepositoryServiceTodo.updateDoc(config, photo.path.toString());

        print('update0');
        return success;
      } else {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return success;
      }
    } else if (id_type == 3 || id_type == 4) {
      Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
      var postUri = Uri.parse(
          ApiWebServer.server_name + '/api/v-1/user/tax-documents/update');
      var request = new http.MultipartRequest("PATCH", postUri);
      request.headers.addAll(headers);
      request.fields['id_type'] = id_type.toString();
      request.files
          .add(await http.MultipartFile.fromPath('tax_doc_file', photo.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("id_image_type", true);
        RepositoryServiceTodo.updateDoc(config, photo.path.toString());

        print('update0');
        return success;
      } else {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return success;
      }
    } else {
      Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
      var postUri = Uri.parse(
          ApiWebServer.server_name + '/api/v-1/user/tax-documents/update');
      var request = new http.MultipartRequest("PATCH", postUri);
      request.headers.addAll(headers);
      request.fields['id_type'] = id_type.toString();
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("id_image_type", true);
        RepositoryServiceTodo.updateDoc(config, photo.path.toString());

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

  Future<dynamic> update23(User user) async {
    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['marital_status'] = user.marital_status.toString();
    request.fields['dependents_number'] = user.dependents_number.toString();
    request.fields['ssn_dependents_number'] =
        user.ssn_dependents_number.toString();
    request.fields['other_income'] = user.other_income.toString();
    request.fields['deduction_type'] = user.deduction_type.toString();
    request.fields['other_deduction_amount'] = user.deduction_amount.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

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

  Future<dynamic> update3(User user) async {
    print('llego addres');
    print(user.state);
    print(user.city);
    print(user.city_name);
    print(user.address_1);
    print(user.zip_code);
    print(user.phone_number);

    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri =
        Uri.parse(ApiWebServer.server_name + '/api/v-1/user/validate-address');
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['state'] = user.state.toString();
    request.fields['city'] = user.city.toString();
    request.fields['city_name'] = user.city_name.toString();
    request.fields['zip_code'] = user.zip_code.toString();
    request.fields['address_1'] = user.address_1.toString();
    request.fields['address_2'] = user.address_2.toString();
    request.fields['phone_number'] = user.phone_number.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    //print(responseData['data'][0]);
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isAddres", true);
      RepositoryServiceTodo.updateAddrees(config, user.address_1.toString());
      print('updateaddress');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> update3u(User user, User user1) async {
    String? token = await getToken();
    config = await getTodo(1);
    print(user.phone_number);
    print(user1.phone_number);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri =
        Uri.parse(ApiWebServer.server_name + '/api/v-1/user/validate-address');
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    // ignore: unnecessary_null_comparison
    request.fields['state'] =
        (user.state != null ? user.state.toString() : null)!;
    // ignore: unnecessary_null_comparison
    request.fields['city'] = (user.city != null ? user.city.toString() : null)!;
    request.fields['zip_code'] = user.zip_code != ''
        ? user.zip_code.toString()
        : user1.zip_code.toString();
    request.fields['address_1'] = user.address_1 != ''
        ? user.address_1.toString()
        : user1.address_1.toString();
    request.fields['address_2'] = user.address_2 != ''
        ? user.address_2.toString()
        : user1.address_2.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    //print(responseData['data'][0]);
    print(response.statusCode);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isAddres", true);
      RepositoryServiceTodo.updateAddrees(config, user.address_1.toString());
      print('updateaddress');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> updateaddressv(address) async {
    print('llego addres update verifiy');

    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);

    request.fields['address_1'] = address;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    //print(responseData['data'][0]);
    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };

      print('updateaddress');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> update4(User user) async {
    print(user.blood_type);
    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);

    request.fields['blood_type'] = user.blood_type.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isHealth", true);
      RepositoryServiceTodo.updateContact(
          config, user.contact_first_name.toString());

      print('updatecontact');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> update41(User user) async {
    print(user.contact_phone);
    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['contact_first_name'] = user.contact_first_name.toString();
    request.fields['contact_last_name'] = user.contact_last_name.toString();
    request.fields['contact_phone'] = user.contact_phone.toString();
    request.fields['contact_email'] =
        user.contact_email.toString().toLowerCase();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.body);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isContact", true);
      RepositoryServiceTodo.updateContact(
          config, user.contact_first_name.toString());

      print('updatecontact');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  /*Future<dynamic> updateus(User user, photo, selfie) async {
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    String? token = await getToken();

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token",
      "Content-Type": "multipart/form-data"
    };

    print(user.doc_expire_date);
    print(photo);
    print(selfie);
    print(headers);

    // FORMAT DATE

    var postUri = Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll(headers);
    request.fields['doc_type'] = 'PP';
    request.fields['expiration_date'] = format.format(user.expiration_date_no);
    request.fields['number'] = user.doc_number.toString();
    request.fields['work_eligibility'] = 'UC';
    request.files
        .add(await http.MultipartFile.fromPath('front_photo', photo.path));
    request.files
        .add(await http.MultipartFile.fromPath('doc_selfie', selfie.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);

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
  }*/

  Future<dynamic> updateusp(User user, photo, photo1) async {
    print('llego a pv save usphhh');

    print(user.doc_type);
    config = await getTodo(1);

    String type;
    if (user.doc_type == 'Pasaporte' || user.doc_type == 'Passport') {
      type = 'PP';
    } else if (user.doc_type == 'Licencia de Conducir' ||
        user.doc_type == 'Drivers License') {
      type = 'DL';
    } else if (user.doc_type == 'State ID') {
      type = 'SI';
    } else if (user.doc_type == 'Permiso de Trabajo' ||
        user.doc_type == 'Work Permit') {
      type = 'WP';
    } else if (user.doc_type == 'Tarjeta de Residencia' ||
        user.doc_type == 'Residence Card') {
      type = 'GC';
    } else {
      type = 'OT';
    }

    print(type);

    String? token = await getToken();
    print(type);

    DateFormat format = DateFormat("yyyy-MM-dd");
    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token",
    };

    if (type == 'PP') {
      print('entro aqui');
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.fields['number'] = user.doc_number.toString();
      request.fields['work_eligibility'] = 'UC';
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      if (response.statusCode == 201) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isDoc", true);
        RepositoryServiceTodo.updateDoc(config, photo.path.toString());
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('update0e');
        return success;
      } else {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return success;
      }
    } else if (type == 'OT') {
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.fields['doc_name'] = user.doc_number.toString();
      request.fields['work_eligibility'] = 'UC';
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      if (response.statusCode == 201) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isDoc", true);
        RepositoryServiceTodo.updateDoc(config, photo.path.toString());
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('update00');
        return success;
      } else {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return success;
      }
    } else {
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.fields['number'] = user.doc_number.toString();
      request.fields['work_eligibility'] = 'UC';
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('rear_photo', photo1.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.body);
      if (response.statusCode == 201) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isDoc", true);
        print('update000');
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

  Future<dynamic> updateuslicense(User user, photo, photo1) async {
    print('llego a pv save usp');

    print(user.doc_type);
    config = await getTodo(1);

    String? token = await getToken();

    DateFormat format = DateFormat("yyyy-MM-dd");
    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token",
    };

    var postUri =
        Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll(headers);
    request.fields['doc_type'] = 'DL';
    request.fields['number'] = user.doc_number.toString();
    request.fields['work_eligibility'] = 'UC';
    request.files
        .add(await http.MultipartFile.fromPath('front_photo', photo.path));
    request.files
        .add(await http.MultipartFile.fromPath('rear_photo', photo1.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    if (response.statusCode == 201) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isDoc", true);
      RepositoryServiceTodo.updateDoc(config, photo.path.toString());
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print('update0e');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> updateus(User user, photo, selfie, elegibility) async {
    print('llego a pv save us');

    late String type;
    late String us;
    if (user.doc_type == 'Pasaporte' || user.doc_type == 'Passport') {
      type = 'PP';
    } else if (user.doc_type == 'Licencia de Conducir' ||
        user.doc_type == 'Drivers License') {
      type = 'DL';
    } else if (user.doc_type == 'State ID') {
      type = 'SI';
    } else if (user.doc_type == 'Permiso de Trabajo') {
      type = 'WP';
    } else if (user.doc_type == 'Tarjeta de Residencia') {
      type = 'GC';
    } else {}

    if (elegibility == 'Estadounidense' || elegibility == 'American') {
      us = 'UC';
    } else if (elegibility == 'Residente' || elegibility == 'Resident') {
      us = 'RE';
    } else {
      us = 'AA';
    }

    String? token = await getToken();
    print(us);
    print(user.doc_expire_date);
    print(user.doc_number);

    DateFormat format = DateFormat("yyyy-MM-dd");
    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token",
    };

    if (type == 'PP') {
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.fields['number'] = user.doc_number.toString();
      request.fields['work_eligibility'] = us;
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('doc_selfie', selfie.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
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
    } else {
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.fields['expiration_date'] = user.doc_expire_date as String;
      request.fields['number'] = user.doc_number.toString();
      request.fields['work_eligibility'] = us;
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('rear_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('doc_selfie', selfie.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
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

  Future<dynamic> updatere(
      User user, photo, photo1, selfie, type, elegibility) async {
    print('llego a pv save re');
    print(photo);

    String us;
    String typer;

    if (elegibility == 'Estadounidense' || elegibility == 'American') {
      us = 'UC';
    } else if (elegibility == 'Residente' || elegibility == 'Resident') {
      us = 'RE';
    } else {
      us = 'AA';
    }

    if (type == 'Tarjeta de Residencia' || type == 'Residence Card') {
      typer = 'GC';
    } else {
      typer = 'PG';
    }

    String? token = await getToken();
    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token",
    };

    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE

    if (typer == 'GC') {
      var postUri =
          Uri.parse('${ApiWebServer.server_name}/api/v-1/user/legal-document');
      var request = http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = typer;
      request.fields['expiration_date'] = user.doc_expire_date as String;
      request.fields['uscis'] = user.doc_number.toString();
      request.fields['work_eligibility'] = us;
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('rear_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('doc_selfie', selfie.path));
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
    } else {
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = typer;
      request.files
          .add(await http.MultipartFile.fromPath('proof_photo', photo.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
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

  Future<dynamic> updateex(
      User user, photo, photo1, selfie, elegibility) async {
    print('llego a pv save ex');
    print(user.doc_type);

    String type;
    String us;
    if (user.doc_type == 'Permiso de Trabajo' ||
        user.doc_type == 'Work Permit') {
      type = 'WP';
    } else {
      type = 'PW';
    }

    if (elegibility == 'Estadounidense' || elegibility == 'American') {
      us = 'UC';
    } else if (elegibility == 'Residente' || elegibility == 'Resident') {
      us = 'RE';
    } else {
      us = 'AA';
    }

    String? token = await getToken();

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token",
    };

    print(type);
    print(us);
    print(photo);

    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    if (type == 'WP') {
      print('aquiwp');
      var postUri =
          Uri.parse('${ApiWebServer.server_name}/api/v-1/user/legal-document');
      var request = http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.fields['expiration_date'] = user.doc_expire_date as String;
      request.fields['number'] = user.doc_number.toString();
      request.fields['work_eligibility'] = us;
      request.files
          .add(await http.MultipartFile.fromPath('front_photo', photo.path));
      request.files
          .add(await http.MultipartFile.fromPath('rear_photo', photo1.path));
      request.files
          .add(await http.MultipartFile.fromPath('doc_selfie', selfie.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(json.decode(response.body));
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
    } else {
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/legal-document');
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['doc_type'] = type;
      request.files
          .add(await http.MultipartFile.fromPath('proof_photo', photo.path));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
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

  Future<dynamic> uploadFile(User user, image, imagef, imager) async {
    if (user.id_type == 'SSN') {
      _type = '1';
    } else {
      _type = '2';
    }
    if (user.doc_type == 'Licencia de Conducir') {
      _docType = '2';
    }
    if (user.doc_type == 'Pasaporte') {
      _docType = '1';
    }
    if (user.doc_type == 'State ID') {
      _docType = '3';
    }

    if (user.doc_type_no == 'Tarjeta de Residencia') {
      _docTypeN = '2';
    }
    if (user.doc_type_no == 'Permiso de Trabajo') {
      _docTypeN = '1';
    }
    if (user.doc_type_no == 'Comprobante de Solicitud de documento') {
      _docTypeN = '3';
    }
    //
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    var postUri =
        Uri.parse(ApiWebServer.API_UPDATE_USER + '/' + '$_userId' + '/');
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['state'] = user.state.toString();
    request.fields['city'] = user.city.toString();
    request.fields['zip_code'] = user.zip_code!;
    request.fields['phone_number'] = user.phone_number!;
    request.fields['address_1'] = user.address_1!;
    request.fields['address_2'] = user.address_2!;
    request.fields['is_us_citizen'] = user.is_us_citizen.toString();
    request.fields['id_type'] = _type;
    request.fields['id_number'] = user.id_number ?? '000000000';
    request.fields['doc_type'] = _docType;
    request.fields['doc_number'] = user.doc_number ?? '000000000';
    request.fields['doc_expire_date'] = user.doc_expire_date as String;
    request.files.add(await http.MultipartFile.fromPath(
        'doc_image', image != null ? image.path : imagef.path));
    request.files.add(await http.MultipartFile.fromPath(
        'signature', image != null ? image.path : imagef.path));
    request.fields['doc_type_no'] = _docTypeN;
    request.fields['expiration_date_no'] = user.expiration_date_no as String;
    request.fields['uscis_number'] = user.uscis_number ?? '000000000';
    request.files.add(await http.MultipartFile.fromPath(
        'front_image_no', imagef != null ? imagef.path : image.path));
    request.files.add(await http.MultipartFile.fromPath(
        'rear_image_no', imager != null ? imager.path : image.path));

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);

    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print('upload');
      return success;
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> updateAddress(data) async {
    String? token = await getToken();
    config = await getTodo(1);
    print(data);
    print('lego');

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['state'] =
        data['candidate_1']['suggested_state_id'].toString();
    request.fields['city'] =
        data['candidate_1']['suggested_city_id'].toString();
    request.fields['address_1'] =
        data['candidate_1']['suggested_address_1'].toString();
    request.fields['address_2'] =
        data['candidate_1']['suggested_address_2'] != null
            ? data['candidate_1']['suggested_address_2'].toString()
            : '-';
    request.fields['zip_code'] =
        data['candidate_1']['suggested_zip_code'].toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    //print(responseData['data'][0]);
    print(response.statusCode);
    print(response.body);
    return response.statusCode.toString();
  }

  Future<dynamic> updateAddressNew(
      state, city, address, addres2, zipcode) async {
    String? token = await getToken();
    config = await getTodo(1);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['state'] = state.toString();
    request.fields['city_name'] = city.toString();
    request.fields['address_1'] = address.toString();
    request.fields['address_2'] = addres2 != null ? addres2.toString() : '-';
    request.fields['zip_code'] = zipcode.toString();
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    print(response.body);
    return response.statusCode.toString();
  }

  Future<dynamic> updatePart2(User user, image) async {
    // DATA CAST
    if (user.marital_status == 1) {
      _docType = '1';
    }
    if (user.marital_status == 2) {
      _docType = '2';
    }
    if (user.marital_status == 3) {
      _docType = '3';
    }
    if (user.marital_status == 4) {
      _docType = '4';
    }
    var postUri =
        Uri.parse(ApiWebServer.API_UPDATE_USER + '/' + '$_userId' + '/');
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['dependents_number'] = user.dependents_number!;
    request.fields['marital_status'] = _docType;
    request.fields['contact_first_name'] = user.contact_first_name!;
    request.fields['contact_last_name'] = user.contact_last_name!;
    request.fields['contact_phone'] = user.contact_phone!;
    request.fields['contact_email'] = user.contact_email!;
    request.fields['blood_type'] = user.blood_type.toString();
    request.fields['rh_factor'] = '1';
    // request.files.add(await http.MultipartFile.fromPath('signature', image.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print('upload2');
      return success;
    } else {
      print(json.decode(response.body));
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      return success;
    }
  }

  Future<dynamic> updatePart3(image) async {
    var postUri =
        Uri.parse(ApiWebServer.API_UPDATE_USER + '/' + '$_userId' + '/');
    var request = new http.MultipartRequest("PATCH", postUri);
    request.files
        .add(await http.MultipartFile.fromPath('profile_image', image.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      print('uploadvimage');
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

  Future<dynamic> updateProfile1(User user, User user1) async {
    String? token = await getToken();
    print(user.zip_code);
    print(user.address_1);
    print(user.address_2);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['city'] =
        user.city != null ? user.city.toString() : user1.city.toString();
    request.fields['zip_code'] =
        (user.zip_code != null ? user.zip_code.toString() : user1.zip_code)!;
    request.fields['address_1'] =
        (user.address_1 != null ? user.address_1.toString() : user1.address_1)!;
    request.fields['address_2'] =
        (user.address_2 != null ? user.address_2.toString() : user1.address_2)!;
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
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

  Future<dynamic> updateProfile2(
      User user,
      User user1,
      Map<String, dynamic> data,
      String name,
      String ape,
      String ph,
      String email) async {
    print(user.dependents_number);
    String? token = await getToken();
    print('llego hoy otra vez');
    print(name);
    print(ape);

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['contact_first_name'] = name;
    request.fields['contact_last_name'] = ape;
    request.fields['contact_phone'] = ph;
    request.fields['contact_email'] = email;
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

  Future<dynamic> updateProfilePhone(String phone, User user1) async {
    String? token = await getToken();
    print('llego hoy otra vez');

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['phone_number'] = (phone ?? user1.phone_number)!;
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

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> _authenticate(String email, String password) async {
    _status = Status.Authenticating;
    config = await getTodo(1);
    print('llego a pb');
    String? fcm = await FirebaseMessaging.instance.getToken();
    print(email.toLowerCase());
    print(password);
    print(fcm);

    final response = await http.post(
      Uri.parse(ApiWebServer.API_AUTH_LOGIN),
      body: json.encode(
        {
          'username': email,
          'password': password,
          'fcm_token': fcm.toString(),
        },
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
    );
    final responseData = json.decode(utf8.decode(response.bodyBytes));
    print('response data');
    print(response.statusCode);
    print(responseData);
    if (response.statusCode == 200) {
      locations = responseData['location_list'] ?? [];
      _token = responseData['token'];
      _role = responseData['role'] ?? '';
      _userId = responseData['user_id'] ?? 0;
      _contract = responseData['contract'] ?? 0;
      _name = responseData['first_name'] ?? ' ';
      _lastname = responseData['last_name'] ?? ' ';
      _btn_id = responseData['btn_id'] ?? ' ';
      _email = responseData['email'] ?? ' ';
      _image = responseData['profile_image'] ?? ' ';
      _id_type = responseData['id_type'] ?? ' ';
      _doc_type = responseData['tax_doc_file'].toString() ?? ' ';
      _contact = responseData['contact_first_name'] ?? ' ';
      _addres = responseData['has_city'].toString() ?? ' ';
      documents = responseData['legal_documents_count'] ?? ' ';
      health = int.parse(responseData['blood_type']);
      print('data de response');
      print(_role);
      print(locations);
      if (locations.isNotEmpty) {
        print('hay ubicaciones');
      } else {
        print('no hay ubicaciones');
      }

      if (_role == 'business' || _role == 'customer' || locations.isNotEmpty) {
        print(_role);
        print('entro aqui customer');
        print('response bdy');
        print('token');
        print(_token);
        print(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isImage", true);

        SharedPreferences prefs1 = await SharedPreferences.getInstance();
        prefs1?.setBool("isIdType", true);

        SharedPreferences prefs2 = await SharedPreferences.getInstance();
        prefs2?.setBool("isAddres", true);

        SharedPreferences prefs3 = await SharedPreferences.getInstance();
        prefs3?.setBool("isContact", true);

        SharedPreferences prefs4 = await SharedPreferences.getInstance();
        prefs4?.setBool("isDoc", true);

        SharedPreferences prefs5 = await SharedPreferences.getInstance();
        prefs5?.setBool("isHealth", true);

        SharedPreferences token = await SharedPreferences.getInstance();
        token.setString('stringValue', _token);
        print('con');

        SharedPreferences contrato = await SharedPreferences.getInstance();
        contrato.setInt('intValue', _contract);
        print('paso contrac');

        SharedPreferences user = await SharedPreferences.getInstance();
        user.setInt('intValue', _userId);

        SharedPreferences prefs6 = await SharedPreferences.getInstance();
        prefs6?.setBool("isLoggedIn", true);

        SharedPreferences prefs7 = await SharedPreferences.getInstance();
        prefs7?.setBool("isBusiness", true);

        SharedPreferences chats = await SharedPreferences.getInstance();
        chats.setInt('intChatsValue', 0);

        SharedPreferences activeCounter = await SharedPreferences.getInstance();
        activeCounter.setInt('intActiveValue', 0);

        SharedPreferences archiveCounter =
            await SharedPreferences.getInstance();
        archiveCounter.setInt('intArchiveVal', 0);

        SharedPreferences notif = await SharedPreferences.getInstance();
        notif.setInt('intValue', 0);

        RepositoryServiceTodo.updateTodo(config, _token, _name, _lastname,
            _btn_id, _email, '1', 'business', 'business', '1', '1', '1');
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('success');
        print(success);
        return success;
      } else {
        if (_image != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isImage", true);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isImage", false);
        }

        if (_id_type != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isIdType", true);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isIdType", false);
        }

        if (_addres == true.toString()) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isAddres", true);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isAddres", false);
        }

        if (_contact != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isContact", true);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isContact", false);
        }

        if (documents > 0) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isDoc", true);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isDoc", false);
        }

        if (health != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isHealth", true);
        } else {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs?.setBool("isHealth", false);
        }

        SharedPreferences token = await SharedPreferences.getInstance();
        token.setString('stringValue', _token);

        SharedPreferences contrato = await SharedPreferences.getInstance();
        contrato.setInt('intValue', _contract);

        SharedPreferences user = await SharedPreferences.getInstance();
        user.setInt('intValue', _userId);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isLoggedIn", true);

        SharedPreferences chats = await SharedPreferences.getInstance();
        chats.setInt('intChatsValue', 0);

        SharedPreferences activeCounter = await SharedPreferences.getInstance();
        activeCounter.setInt('intActiveValue', 0);

        SharedPreferences archiveCounter =
            await SharedPreferences.getInstance();
        archiveCounter.setInt('intArchiveVal', 0);

        SharedPreferences notif = await SharedPreferences.getInstance();
        notif.setInt('intValue', 0);

        SharedPreferences prefs7 = await SharedPreferences.getInstance();
        prefs7?.setBool("isBusiness", false);
        print('locations list');
        print(responseData['location_list'].toString());

        print('id_type00');
        print(_id_type);
        RepositoryServiceTodo.updateTodo(
            config,
            _token,
            _name,
            _lastname,
            _btn_id,
            _email,
            _image,
            _role,
            _id_type,
            _doc_type,
            _contact,
            _addres);
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return success;
      }
    } else {
      Map<String, dynamic> success = {
        "data": json.decode(response.body),
        "status": response.statusCode.toString()
      };
      print('sucess prov');
      print(success);
      return success;
    }
  }

  Future<dynamic> updateDevice() async {
    print('llego update device');
    String? token = await getToken();
    config = await getTodo(1);
    String fcm = /*await _firebaseMessaging.getToken()*/ "2";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var isDevice = prefs.getBool('isDevice') ?? false;
    print('isdevice');
    print(isDevice);

    if (!isDevice) {
      Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
      var postUri =
          Uri.parse(ApiWebServer.server_name + '/api/v-1/user/update-device');
      var request = new http.MultipartRequest("PATCH", postUri);
      request.headers.addAll(headers);
      request.fields['registration_id'] = fcm.toString();
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      //print(responseData['data'][0]);
      print(response.statusCode);
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs?.setBool("isDevice", true);
        return 1;
      }
    } else {
      print('ya hay device');
    }
  }

  Future<dynamic> login(String email, String password) async {
    return _authenticate(email, password);
  }

  void logout() async {
    config = await getTodo(1);
    const url = ApiWebServer.API_AUTH_LOGOUT;
    // ignore: unused_local_variable
    /*final response = http.post(Uri.parse(url),
        body: json.encode(
          {
            'id': _userId,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });*/
    _token = '';
    _userId = 0;
    _status = Status.Unauthenticated;
    RepositoryServiceTodo.updateTodoSesion(config);
    RepositoryServiceTodo.updateTodoRole(config);
    RepositoryServiceTodo.updateTodoContract(config);
    RepositoryServiceTodo.updateContractDetail(contract, "", "", "");

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs?.setBool("isLoggedIn", false);

    notifyListeners();
  }

  // ignore: missing_return
  Future<Auth> verifyEmail(email) async {
    print(email);
    try {
      var getUri =
          Uri.parse(ApiWebServer.API_GET_VERIFY_EMAIL + '/' + '$email' + '/');
      final response = await http.get(getUri);
      if (response.statusCode == 200) {
        _userId = json.decode(response.body);
        throw HttpException('200');
      } else {
        return Auth();
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      throw error;
    }
  }

  // ignore: missing_return
  Future<dynamic> verifyCode(code) async {
    try {
      var getUri = Uri.parse(
          ApiWebServer.API_GET_VERIFY_CODE + '/$_userId/' + '$code' + '/');

      final response = await http.get(getUri);

      return response.statusCode;
    } catch (error) {
      notifyListeners();
      throw error;
    }
  }

  Future<void> changePassword(passwd1, passwd2) async {
    notifyListeners();
    print(passwd1);
    print(passwd2);
    final url = ApiWebServer.server_name +
        '/api/v-1/auth/change_password/' +
        '$_userId' +
        '/';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: json.encode(
          {
            'password1': passwd1,
            'password2': passwd1,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        throw HttpException('200');
      }
      notifyListeners();
    } catch (error) {
      print(error);
      notifyListeners();
      throw error;
    }
  }

  Future<dynamic> verifyUser(user, passw) async {
    notifyListeners();
    final url = ApiWebServer.server_name + '/api/v-1/auth/verificate_user';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'username': user,
            'password': passw,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (error) {
      print(error);
      notifyListeners();
      throw error;
    }
  }

  Future<dynamic> deleteUser() async {
    String? token = await getToken();
    final url =
        ApiWebServer.server_name + '/api/v-1/user/create-delete-request';
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(
          {
            'token': token,
          },
        ),
        headers: {
          'Authorization': 'Token' + ' ' + '$token',
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
      );
      print(response.statusCode);
      print(response.body);
      if (response.statusCode == 201) {
        return response.statusCode;
      } else {
        return response.statusCode;
      }
    } catch (error) {
      print(error);
      notifyListeners();
      throw error;
    }
  }

  Future<dynamic> changePasswordP(old, passwd1, passwd2) async {
    String? token = await getToken();
    print(old);
    print(passwd1);
    print(passwd2);

    notifyListeners();
    final url = ApiWebServer.server_name + '/api/v-1/auth/update_password/';
    try {
      final response = await http.patch(
        Uri.parse(url),
        body: json.encode(
          {
            'oldpassword': old,
            'password1': passwd1,
            'password2': passwd1,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          "Authorization": "Token" + " " + "$token"
        },
      );
      print(response.statusCode);
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
    } catch (error) {
      print(error);
      notifyListeners();
      throw error;
    }
  }

  Future<dynamic> verifiedN(id) async {
    String? token = await getToken();
    DateTime now = DateTime.now();

    try {
      var getUri = Uri.parse(ApiWebServer.API_PATCH_VERIFIED_NOTIF +
          '/' +
          '$id' +
          '/change_status/');
      final response = await http.patch(getUri,
          body: json.encode(
            {'verification_date': now.toIso8601String()},
          ),
          headers: {
            "content-type": "application/json",
            "accept": "application/json",
            "Authorization": "Token" + " " + "$token"
          });

      print(response.body);
      print(response.statusCode);

      notifyListeners();
    } catch (error) {
      notifyListeners();
      throw error;
    }
  }

  Future<dynamic> fetchUser() async {
    String? token = await getToken();
    config = await getTodo(1);

    var getUri = Uri.parse(ApiWebServer.API_GET_USER);

    final response = await http.get(getUri, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Token $token"
    });
    Map<String, dynamic> userData =
        json.decode(utf8.decode(response.bodyBytes));
    //RepositoryServiceTodo.updateImage(config, userData['profile_image']);

    if (response.statusCode == 200 && userData.isNotEmpty) {
      Map<String, dynamic> success = {
        "data": User.fromJson(userData),
        "status": response.statusCode.toString()
      };

      return success;
    } else {
      Map<String, dynamic> success = {
        "data": null,
        "status": response.statusCode.toString()
      };

      return success;
    }
  }

  Future<User> fetchUser1() async {
    String? token = await getToken();
    config = await getTodo(1);

    var getUri = Uri.parse(ApiWebServer.API_GET_USER);

    final response = await http.get(getUri, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Token $token"
    });
    Map<String, dynamic> userData =
        json.decode(utf8.decode(response.bodyBytes));

    return User.fromJson(userData);
  }

  Future<dynamic> fetchdataUser() async {
    String? token = await getToken();
    config = await getTodo(1);

    var getUri = Uri.parse(ApiWebServer.API_GET_USER);

    final response = await http.get(getUri, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Token $token"
    });
    Map<String, dynamic> userData =
        json.decode(utf8.decode(response.bodyBytes));

    return userData;
  }

  Future<dynamic> fetchHours() async {
    String? token = await getToken();
    DateFormat format = DateFormat("hh:mm");
    DateTime now = DateTime.now();

    var getUri =
        Uri.parse('${ApiWebServer.server_name}/api/v-1/user/worked-hours');

    final response = await http.get(getUri, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Token" + " " + "$token"
    });
    Map<String, dynamic> userData = json.decode(response.body);
    print(userData);

    if (response.statusCode == 200 && userData.isNotEmpty) {
      return json.decode(response.body);
    } else {
      return null;
    }
  }

  Future<dynamic> fetchMetricsBusiness(estatus) async {
    String? token = await getToken();
    DateFormat format = DateFormat("yyyy-MM-dd");
    DateTime now = DateTime.now();
    //String hy = now.toString().substring(0, 10);
    String h = format.format(now.toUtc());

    var getUri = Uri.parse(
        '${ApiWebServer.server_name}/api/v-2/user/business-metrics/$estatus');

    final response = await http.get(getUri, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Token $token"
    });
    Map<String, dynamic> userData =
        json.decode(utf8.decode(response.bodyBytes));

    print(userData);

    if (response.statusCode == 200 && userData.isNotEmpty) {
      return json.decode(utf8.decode(response.bodyBytes));
    } else {
      return null;
    }
  }

  Future<dynamic> fetchContract() async {
    String? token = await getToken();
    config = await getTodo(1);
    contract = await getContract(1);

    var getUri =
        Uri.parse(ApiWebServer.server_name + '/api/v-2/contract/current');

    final response = await http.get(getUri, headers: {
      "content-type": "application/json",
      "accept": "application/json",
      "Authorization": "Token" + " " + "$token"
    });
    Map<String, dynamic> resBody = json.decode(response.body);

    Map<String, dynamic> success = {
      "data": json.decode(response.body),
      "status": response.statusCode.toString()
    };

    RepositoryServiceTodo.updateContract(config, resBody['contract_name']);
    RepositoryServiceTodo.updateContractDetail(contract, resBody['id'],
        resBody['contract_name'], resBody['required_temperature'].toString());

    return success;
  }

  Future<dynamic> updatePartAdic(User user, User user1) async {
    String? token = await getToken();

    Map<String, String> headers = {"Authorization": "Token" + " " + "$token"};
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    request.fields['degree_levels'] =
        (user.degree_levels ?? user1.degree_levels)!;
    request.fields['speciality_or_degree'] = user.speciality_or_degree!;

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    if (response.statusCode == 200) {
      print('upload part acad');
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
}
