import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:firebase_database/firebase_database.dart';
import 'package:worker/providers/url_constants.dart';

class ChatProvider with ChangeNotifier {
  DateFormat format = DateFormat("yyyy-MM-dd");

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    //Return String
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> addChat(List p, List d, id, id2, contract) async {
    print('llego a pv chat');
    print(p);

    //Se crea instancia de chat
    DatabaseReference chat =
        FirebaseDatabase.instance.reference().child('chats').push();

    print('creo chat');
    print(chat.key);

    DatabaseReference chat_created =
        FirebaseDatabase.instance.reference().child('chats/${chat.key}');

    Map pMaplist = {};

    p.forEach((element) {
      DatabaseReference newUserID = FirebaseDatabase.instance
          .reference()
          .child('chats/${chat.key}')
          .push();

      pMaplist[newUserID.key] = element;
    });

    //Se agregan valores de chat
    var contractId =
        contract['contract_id'] == null && contract['contract_id'] == ""
            ? 0
            : contract['contract_id'];
    await chat_created.set({
      "createdDate": DateTime.now().toString(),
      "type": "Simple chat",
      "contractName":
          contract['contract_name'] == null ? "" : contract['contract_name'],
      "isBroadcast": false,
      "lastMessage": "",
      "contractId": contractId,
      "travel_id": "0",
      "status": "active",
      "logoURL": d[0]['pictureURL'],
      "name": d[0]['firstName'] + ' ' + d[0]['lastName'],
      "participants": pMaplist
    });

    //Creando chat a usuario que creo

    DatabaseReference rooms_created = FirebaseDatabase.instance
        .reference()
        .child('users/' + id + '/rooms/')
        .push();

    print('response rooms created');
    print(rooms_created.key);
    String room = rooms_created.key.toString();

    rooms_created.set({"$room": chat.key.toString()});

    DatabaseReference rooms_created1 =
        FirebaseDatabase.instance.reference().child('users/' + id + '/rooms/');
    rooms_created1.update({"$room": chat.key.toString()});

    //creando chat a usuario invitado

    DatabaseReference rooms_createdI = FirebaseDatabase.instance
        .reference()
        .child('users/' + id2 + '/rooms/')
        .push();

    print('response rooms created');
    print(rooms_createdI.key);
    String roomI = rooms_createdI.key.toString();

    rooms_createdI.set({"$roomI": chat.key.toString()});

    DatabaseReference rooms_createdI1 =
        FirebaseDatabase.instance.reference().child('users/' + id2 + '/rooms/');
    rooms_createdI1.update({"$roomI": chat.key.toString()});

    print('ya se creo el chat');
    return chat.key.toString();
  }

  Future<dynamic> addChatGroup(
      List p, List d, String group, keys, id, url, contract) async {
    print('llego a pv chat group');
    print(p);
    //Se crea instancia de chat
    DatabaseReference chat =
        FirebaseDatabase.instance.reference().child('chats').push();

    print('creo chat');
    print(chat.key);

    DatabaseReference chat_created =
        FirebaseDatabase.instance.reference().child('chats/${chat.key}');

    //Se agregan valores de chat
    await chat_created.set({
      "createdDate": DateTime.now().toString(),
      "type": "Group chat",
      "contractName": contract['contract_name'],
      "lastMessage": "",
      "isBroadcast": false,
      "contractId": contract['contract_id'],
      "travel_id": "0",
      "status": "active",
      "logoURL": url != null ? url : "",
      "name": group,
      "participants": p
    });

    print('ya se creo el chat');

    // SE CREA CHAT PARA INTEGRANTES DEL GRUPO
    keys.forEach((element) {
      DatabaseReference rooms_createdP = FirebaseDatabase.instance
          .reference()
          .child('users/' + element + '/rooms/')
          .push();

      print('response rooms created');
      print(rooms_createdP.key);
      String roomP = rooms_createdP.key.toString();

      rooms_createdP.set({"$roomP": chat.key.toString()});

      DatabaseReference rooms_createdp1 = FirebaseDatabase.instance
          .reference()
          .child('users/' + element + '/rooms/');
      rooms_createdp1.update({"$roomP": chat.key.toString()});
    });

    return chat.key.toString();
  }

  Future<dynamic> addMembersGroup(List p, List d, String group, keys, id, url,
      contract, chatID, List partAct) async {
    print('llego a add members group');
    print(chatID);

    DatabaseReference chat =
        FirebaseDatabase.instance.reference().child('chats/' + chatID);

    var listFinal = List.from(partAct)..addAll(p);
    print('list final');
    print(listFinal);

    chat.update({"participants": listFinal});

    print('ya actualizo los participants');

    // SE CREA CHAT PARA INTEGRANTES DEL GRUPO
    keys.forEach((element) {
      DatabaseReference rooms_createdP = FirebaseDatabase.instance
          .reference()
          .child('users/' + element + '/rooms/')
          .push();

      print('response rooms created');
      print(rooms_createdP);
      String roomP = rooms_createdP.key.toString();

      rooms_createdP.set({"$roomP": chatID.toString()});

      DatabaseReference rooms_createdp1 = FirebaseDatabase.instance
          .reference()
          .child('users/' + element + '/rooms/');
      rooms_createdp1.update({"$roomP": chatID.toString()});
    });

    return chatID.toString();
  }

  Future<dynamic> addRoom(contract, room, created, participants) async {
    String token = await getToken();
    print('llego a pv chat');
    print(contract);
    print(room);
    print(created);

    try {
      print("http");

      final response = await http.post(Uri.parse('$urlChat/chat/app'),
          body: json.encode({
            'contract_id': contract,
            'room_id': room,
            'created_date': created,
            'chat_type': 3
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            //'Authorization': 'Token $token'
          });

      print("response.body ${response}");
      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print("response.statusCode ${response.statusCode}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('sigue a crear participantes 1 $participants $room');

        addRoomParticipants(participants, room);
        return success;
        //throw HttpException(responseData['email']['message']);
      } else {
        Map<String, dynamic> error = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return error;
      }
    } catch (error) {
      print(error);
      throw error;
    } // FORMAT DATE
  }

  Future<dynamic> addRoomGroup(contract, room, created, participants) async {
    print('llego a pv chat');
    print(contract);
    print(room);
    print(created);

    try {
      print("http");
      final response = await http.post(Uri.parse('$urlChat/chat/app'),
          body: json.encode({
            'contract_id': contract,
            'room_id': room,
            'created_date': created,
            'chat_type': 4
          }),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            //'Authorization': 'Token $token'
          });
      print('request ${json.encode({
            'contract_id': contract,
            'room_id': room,
            'created_date': created,
            'chat_type': 4
          })}');
      print("response.body ${response.body}");
      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print("response.statusCode ${response.statusCode}");
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('sigue a crear participantes $participants $room');

        addRoomParticipants(participants, room);
        return success;
        //throw HttpException(responseData['email']['message']);
      } else {
        Map<String, dynamic> error = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return error;
      }
    } catch (error) {
      print("error? $error");
      throw error;
    } // FORMAT DATE
  }

  Future<dynamic> addRoomParticipants(participants, room) async {
    print('se fue a agregar participants $urlChat/chat/$room/add-users/app');
    try {
      print("DEBUG 0 $participants");
      final response = await http.post(
          Uri.parse(urlChat + "/chat/" + room + "/add-users/app"),
          body: json.encode({"users": participants}),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            //'Authorization': 'Token $token'
          });
      print("DEBUG 1 $response ${response.statusCode}");
      final responseData = json.decode(response.body);
      print("DEBUG 2");
      print(json.decode(response.statusCode.toString()));
      print(responseData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('ya se agregaron participantes en django');
        print(success);
        return success;
        //throw HttpException(responseData['email']['message']);
      } else {
        Map<String, dynamic> error = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return error;
      }
    } catch (error) {
      print("DEBUG $error");
      throw error;
    } // FORMAT DATE
  }

  Future<dynamic> deleteRoomParticipant(participant, room) async {
    print('Elimina un participante');
    try {
      final response = await http.post(
          Uri.parse('$urlChat/chat/$room/remove-user/app'),
          body: json.encode({"user": participant}),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            //'Authorization': 'Token $token'
          });
      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print(responseData);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('ya se elimino el participante en django $success');

        return success;
        //throw HttpException(responseData['email']['message']);
      } else {
        Map<String, dynamic> error = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return error;
      }
    } catch (error) {
      print(error);
      throw error;
    } // FORMAT DATE
  }

  Future<dynamic> addRoomStaff() async {
    String token = await getToken();
    print('llego a pv chats staff');
    try {
      final response = await http.get(
          Uri.parse('$urlServices/api/v-1/chat/create-staff-chat'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Token $token'
          });
      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print(responseData);
      if (response.statusCode == 201) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print(success);
        return success;
        //throw HttpException(responseData['email']['message']);
      } else {
        Map<String, dynamic> error = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return error;
      }
    } catch (error) {
      print(error);
      throw error;
    } // FORMAT DATE
  }

  Future<dynamic> sendNotification(String message, int chat) async {
    String token = await getToken();
    print('llego a pv chat send notifi');
    try {
      final response = await http
          .post(Uri.parse('$urlServices/api/v-1/chat/$chat/send-notification'),
              body: json.encode({
                'message': 1,
              }),
              headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Token $token'
          });
      final responseData = json.decode(response.body);
      print(json.decode(response.statusCode.toString()));
      print(responseData);
      if (response.statusCode == 201) {
        Map<String, dynamic> success = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        print('upload');
        return success;
        //throw HttpException(responseData['email']['message']);
      } else {
        Map<String, dynamic> error = {
          "data": json.decode(response.body),
          "status": response.statusCode.toString()
        };
        return error;
      }
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    } // FORMAT DATE
  }
}
