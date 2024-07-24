import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';

import '../model/certification.dart';
import '../widgets/global.dart';

class Certifications with ChangeNotifier {
  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> createCertification(
      Certification cert, image, image2, type) async {
    DateFormat format = DateFormat("yyyy-MM-dd");
    String token = await getToken();
    var postUri =
        Uri.parse(ApiWebServer.API_CERTIFICATION + '$type' + '/create/');

    if (image == null && image2 == null) {
      Map<String, String> headers = {
        "Authorization": "Token" + " " + "$token"
      }; // FORMAT DATE
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['issuance_date'] = cert.issuance_date != null
          ? format.format(cert.issuance_date)
          : '2222-01-01';
      request.fields['expiration_date'] = cert.expiration_date != null
          ? format.format(cert.expiration_date)
          : '2222-01-01';
      request.fields['verification_url'] =
          cert.verification_url != null ? cert.verification_url : '';
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return json.decode(response.statusCode.toString());
      } else {
        print('error');
        return json.decode(response.body);
      }
    }

    if (image != null && image2 == null) {
      Map<String, String> headers = {
        "Authorization": "Token" + " " + "$token"
      }; // FORMAT DATE
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['issuance_date'] = cert.issuance_date != null
          ? format.format(cert.issuance_date)
          : '2222-01-01';
      request.fields['expiration_date'] = cert.expiration_date != null
          ? format.format(cert.expiration_date)
          : '2222-01-01';
      request.fields['verification_url'] =
          cert.verification_url != null ? cert.verification_url : '';
      request.files
          .add(await http.MultipartFile.fromPath('frontal_img', image.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return json.decode(response.statusCode.toString());
      } else {
        print('error');
        return json.decode(response.body);
      }
    }

    if (image == null && image2 != null) {
      Map<String, String> headers = {
        "Authorization": "Token" + " " + "$token"
      }; // FORMAT DATE
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['issuance_date'] = cert.issuance_date != null
          ? format.format(cert.issuance_date)
          : '2222-01-01';
      request.fields['expiration_date'] = cert.expiration_date != null
          ? format.format(cert.expiration_date)
          : '2222-01-01';
      request.fields['verification_url'] =
          cert.verification_url != null ? cert.verification_url : '';
      request.files
          .add(await http.MultipartFile.fromPath('rear_img', image2.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return json.decode(response.statusCode.toString());
      } else {
        print('error');
        return json.decode(response.body);
      }
    }

    if (image != null && image2 != null) {
      Map<String, String> headers = {
        "Authorization": "Token" + " " + "$token"
      }; // FORMAT DATE
      var request = new http.MultipartRequest("POST", postUri);
      request.headers.addAll(headers);
      request.fields['issuance_date'] = cert.issuance_date != null
          ? format.format(cert.issuance_date)
          : '2222-01-01';
      request.fields['expiration_date'] = cert.expiration_date != null
          ? format.format(cert.expiration_date)
          : '2222-01-01';
      request.fields['verification_url'] =
          cert.verification_url != null ? cert.verification_url : '';
      request.files
          .add(await http.MultipartFile.fromPath('frontal_img', image.path));
      request.files
          .add(await http.MultipartFile.fromPath('rear_img', image2.path));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 201) {
        return json.decode(response.statusCode.toString());
      } else {
        print('error');
        return json.decode(response.body);
      }
    }
  }

  Future<dynamic> deleteCert(id) async {
    print(id);
    String token = await getToken();
    try {
      var getUri =
          Uri.parse(ApiWebServer.API_CERTIFICATION + '$id' + '/delete/');
      final response =
          await http.delete(getUri, headers: {"Authorization": "Token $token"});
      print(response.statusCode);
      if (response.statusCode == 204) {
        print('borradoSERV');
      } else {
        print(response.body);
      }
      notifyListeners();
    } catch (error) {
      notifyListeners();
      throw error;
    }
  }
}
