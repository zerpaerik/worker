import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:firebase_messaging/firebase_messaging.dart';
import '../local/database_creator.dart';
import '../local/service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


import '../model/user.dart';
import '../providers/auth.dart';
import '../model/config.dart';
import '../model/http_exception.dart';
import '../widgets/global.dart';

class Users with ChangeNotifier {
  late String _type;
  late String _typeE;
  late String _hi;
  late String _ei;
  late String _docType;
  late List<User> _items = [];
  late Config config;
  // var _showFavoritesOnly = false;

  //FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  String capitalize(String string) {
    if (string == null) {
      throw ArgumentError("string: $string");
    }

    if (string.isEmpty) {
      return string;
    }

    return string[0].toUpperCase() + string.substring(1);
  }

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);

    return todo;
  }

  Future<dynamic> addUser(String name, String last, String email, String passwd,
      String lang) async {
    config = await getTodo(1);

    String language;
    if (lang == 'English') {
      language = 'en';
    } else {
      language = 'es';
    }
    String gender;
  

    DateFormat format = DateFormat("yyyy-MM-dd");
    final url = ApiWebServer.API_REGISTER_USER;
        String? fcm = await FirebaseMessaging.instance.getToken();

    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'first_name': capitalize(name),
            'email': email.toLowerCase(),
            'last_name': capitalize(last),
            'password1': passwd,
            'password2': passwd,
            //'birth_date': null,
            'gender': '1',
            'birthplace': "58",
            'language': 1,
            'fcm_token': fcm
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          });
      /* final newUser = User(
        first_name: capitalize(name),
        email: email.toLowerCase(),
        last_name: capitalize(last),
        password1: passwd,
        password2: passwd,
        birth_date: null,
        gender: '1',
        birthplace: null,
        id: json.decode(response.body)['name'],
      );

      _items.add(newUser);*/
      print('response emplooy register');
      print(json.decode(response.body.toString()));

      if (response.statusCode == 201) {
        //CREANDO SESIÒN
        await Auth().login(email.toLowerCase(), passwd);
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        RepositoryServiceTodo.updateFirstLast(config, name, last);
        return success;
      } else {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return success;
      }
    } catch (error) {
      print('error');
      print(error.toString());
      throw error;
    }
  }

  Future<dynamic> updateUser(User user) async {
    DateFormat format = DateFormat("yyyy-MM-dd");
    final url = ApiWebServer.API_UPDATE_USER;
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
    if (user.doc_type == 'StateId') {
      _docType = '3';
    }
    final http.Response response = await http.put(Uri.parse(url),
        body: json.encode({
          'country': user.country,
          'state': user.state,
          'city': user.city,
          'zip_code': user.zip_code,
          'phone_number': user.phone_number,
          'address_1': user.address_1,
          'address_2': user.address_2,
          'is_us_citizen': user.is_us_citizen,
          'id_type': _type,
          'doc_type': _docType,
          'doc_numer': user.doc_number,
          //'doc_expire_date': format.format(user.doc_expire_date)
        }),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        });
    print(json.encode({
      'country': user.country,
      'state': user.state,
      'city': user.city,
      'zip_code': user.zip_code,
      'phone_number': user.phone_number,
      'address_1': user.address_1,
      'address_2': user.address_2,
      'is_us_citizen': user.is_us_citizen,
      'id_type': _type,
      'doc_type': _docType,
      'doc_number': user.doc_number,
      'doc_expire_date': format.format(user.doc_expire_date)
    }));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print('actualizo');
      //return User.fromJson(json.decode(response.body));
    } else {
      print(response.body);
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to update');
    }
  }

  Future<dynamic> uploadFile(User user, image) async {
    print(image);
    // DATA CAST
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
    if (user.doc_type == 'StateId') {
      _docType = '3';
    }
    //
    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['country'] = user.country.toString();
    request.fields['state'] = user.state.toString();
    request.fields['city'] = user.city.toString();
    request.fields['zip_code'] = user.zip_code!;
    request.fields['phone_number'] = user.phone_number!;
    request.fields['address_1'] = user.address_1!;
    request.fields['address_2'] = user.address_2!;
    request.fields['is_us_citizen'] = user.is_us_citizen.toString();
    request.fields['id_type'] = _type;
    request.fields['id_number'] = user.id_number!;
    request.fields['doc_type'] = _docType;
    request.fields['doc_number'] = user.doc_number!;
    request.fields['doc_expire_date'] = format.format(user.doc_expire_date);
    request.files
        .add(await http.MultipartFile.fromPath('doc_image', image.path));
    request.files
        .add(await http.MultipartFile.fromPath('signature', image.path));
    request.send().then((response) {
      print(response.statusCode);
      if (response.statusCode == 200)
        print("Uploaded!");
      else
        print(request.fields);
      print(response.toString());
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
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
    //
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['dependents_number'] = user.dependents_number!;
    request.fields['marital_status'] = _docType;
    request.fields['contact_first_name'] = user.contact_first_name!;
    request.fields['contact_last_name'] = user.contact_last_name!;
    request.fields['contact_phone'] = user.contact_phone!;
    request.fields['contact_email'] = user.contact_email!;
    request.fields['blood_type'] = user.blood_type.toString();
    request.fields['rh_factor'] = user.rh_factor.toString();
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

  Future<dynamic> updatePart3(image) async {
    print(image.path);
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    //url = url.replace('__case_id__',case_id);

    request.files
        .add(await http.MultipartFile.fromPath('profile_image', image.path));
    request.send().then((response) {
      if (response.statusCode == 200)
        print("Uploaded profile image!");
      else
        // print(user.doc_expire_date);
        print(request.fields);
      print(response.toString());
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
  }

  updatePartAdic(User user, cv) async {
    // DATA CAST
    print(cv);
    if (user.english_mastery == 'Nativo') {
      _type = '1';
    } else {
      _type = '2';
    }
    print(user.english_learning_level);
    if (user.spanish_mastery == 'Nativo') {
      _typeE = '1';
    } else {
      _typeE = '2';
    }
    if (user.english_learning_level == 'Basico') {
      _hi = '1';
    }
    if (user.english_learning_level == 'Medio') {
      _hi = '2';
    }
    if (user.english_learning_level == 'Avanzado') {
      _hi = '3';
    }
    if (user.english_learning_method == 'Basico') {
      _ei = '1';
    }
    if (user.english_learning_method == 'Medio') {
      _ei = '2';
    }
    if (user.english_learning_method == 'Avanzado') {
      _ei = '3';
    }

    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER_OPTIONAL);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['degree_levels'] = '1';
    request.fields['speciality_or_degree'] = '2';
    request.fields['english_mastery'] = _type;
    request.fields['english_learning_level'] = _hi;
    request.fields['english_learning_method'] = _ei;
    request.fields['spanish_mastery'] = _typeE;
    request.fields['spanish_learning_level'] = '2';
    request.fields['spanish_learning_method'] = '1';
    request.files.add(await http.MultipartFile.fromPath('cv_file', cv.path));

    request.send().then((response) {
      if (response.statusCode == 200)
        print('upload cv');
      else
        // print(user.doc_expire_date);
        print(request.fields);
      print(response.toString());
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
  }

  Future<dynamic> updateProfile1(user) async {
    print(user.city);
    // DATA CAST

    DateFormat format = DateFormat("yyyy-MM-dd"); // FORMAT DATE
    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['country'] = user.country.toString();
    request.fields['state'] = user.state.toString();
    request.fields['city'] = user.city.toString();
    request.fields['zip_code'] = user.zip_code;
    request.fields['gender'] = user.gender;
    request.fields['address_1'] = user.address_1;
    request.fields['address_2'] = user.address_2;
    request.fields['birth_date'] = format.format(user.birth_date);
    request.send().then((response) {
      print(response.statusCode);
      if (response.statusCode == 200)
        print("Uploaded!");
      else
        print(request.fields);
      print(response.toString());
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
  }

  Future<dynamic> updateProfile2(user) async {
    print(user.marital_status);

    if (user.marital_status == 'Soltero(a)') {
      _docType = '1';
    }
    if (user.marital_status == 'Casado(a)') {
      _docType = '2';
    }
    if (user.marital_status == 'Divorciado(a)') {
      _docType = '3';
    }
    if (user.marital_status == 'Viudo(a)') {
      _docType = '4';
    }
    // DATA CAST

    var postUri = Uri.parse(ApiWebServer.API_UPDATE_USER);
    var request = new http.MultipartRequest("PATCH", postUri);
    request.fields['dependents_number'] = user.dependents_number;
    // request.fields['marital_status'] = _docType;
    request.fields['contact_first_name'] = user.contact_first_name;
    request.fields['contact_last_name'] = user.contact_last_name;
    request.fields['contact_phone'] = user.contact_phone;
    request.fields['contact_email'] = user.contact_email;
    request.send().then((response) {
      print(response.statusCode);
      if (response.statusCode == 200)
        print("Uploaded!");
      else
        print(request.fields);
      print(response.toString());
      response.stream.transform(utf8.decoder).listen((value) {
        print(value);
      });
    });
  }
}
