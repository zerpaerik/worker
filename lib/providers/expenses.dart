import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/providers/url_constants.dart';

import '../model/expenses.dart';

class ExpensesP with ChangeNotifier {
  DateFormat format = DateFormat("yyyy-MM-dd");

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> save(Expenses expens, image, contract) async {
    String token = await getToken();

    var postUri = Uri.parse('$urlServices/api/v-1/expense/create');

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll(headers);
    request.fields['name'] = expens.name != null ? expens.name.toString() : '';
    request.fields['contract'] = contract['contract_id'].toString();
    request.fields['expense_type'] = expens.expense_type.toString();
    // request.fields['departure_location'] = '1';
    request.fields['pay_method'] = expens.pay_method.toString();
    request.fields['date'] = /*format.format(expens.date)*/
        expens.date.toIso8601String();
    request.fields['amount'] = expens.amount.toString();
    request.files.add(await http.MultipartFile.fromPath(
        'invoice_image', image != null ? image.path : image.path));
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

  Future<dynamic> savetravel(Expenses expens, image, travel, contract) async {
    String token = await getToken();

    var postUri = Uri.parse('$urlServices/api/v-1/expense/create');
    print(expens.expense_type);
    print(expens.contract);
    print(expens.name);
    print(expens.pay_method);
    print(expens.amount);

    print(image);
    print(travel);

    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("POST", postUri);
    request.headers.addAll(headers);
    request.fields['name'] = expens.name != null ? expens.name.toString() : '';
    request.fields['contract'] = contract['contract_id'].toString();
    request.fields['expense_type'] = expens.expense_type.toString();
    // request.fields['departure_location'] = '1';
    request.fields['pay_method'] = expens.pay_method.toString();
    request.fields['travel'] = travel['id'].toString();
    request.fields['date'] = expens.date.toIso8601String();
    request.fields['amount'] = expens.amount.toString();
    request.files.add(await http.MultipartFile.fromPath(
        'invoice_image', image != null ? image.path : image.path));
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    print(response.statusCode);
    if (response.statusCode == 201) {
      print(json.decode(response.body));
      return response.statusCode.toString();
    } else {
      return response.statusCode.toString();
    }
  }

  Future<dynamic> update(
      Expenses expens, image, Map<String, dynamic> expensG) async {
    String token = await getToken();
    int expense = expensG['id'];
    var postUri = Uri.parse('$urlServices/api/v-1/expense/$expense/update');
    Map<String, String> headers = {
      "Authorization": "Token" + " " + "$token"
    }; // FORMAT DATE
    var request = new http.MultipartRequest("PATCH", postUri);
    request.headers.addAll(headers);
    if (image != null) {
      request.fields['name'] =
          expens.name != null ? expens.name.toString() : expensG['name'];
      request.fields['contract'] = expens.contract.toString();
      request.fields['expense_type'] = expens.expense_type.toString();
      request.fields['pay_method'] = expens.pay_method.toString();
      request.fields['date'] =
          expens.date != null ? format.format(expens.date) : expensG['date'];
      request.fields['amount'] =
          expens.amount != null ? expens.amount.toString() : expensG['amount'];
      request.files.add(await http.MultipartFile.fromPath('invoice_image',
          image != null ? image.path : expensG['invoice_image']));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        return response.statusCode.toString();
      } else {
        return response.statusCode.toString();
      }
    } else {
      request.fields['name'] =
          expens.name != null ? expens.name.toString() : expensG['name'];
      request.fields['contract'] = expens.contract.toString();
      request.fields['expense_type'] = expens.expense_type.toString();
      request.fields['pay_method'] = expens.pay_method.toString();
      request.fields['date'] =
          expens.date != null ? format.format(expens.date) : expensG['date'];
      request.fields['amount'] =
          expens.amount != null ? expens.amount.toString() : expensG['amount'];
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      print(response.statusCode);
      if (response.statusCode == 200) {
        print(json.decode(response.body));
        print('finoooo');
        return response.statusCode.toString();
      } else {
        print('error');
        print(request.fields);
        print(response.statusCode);
        print(response.body);
      }
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
