//import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:async';

class PushNotification {
  // FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  final _mensajesStreamController = StreamController<Map>.broadcast();
  Stream<Map> get message => _mensajesStreamController.stream;

  /* initNotificactions() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then((token) {
      print(token);
      //fWFhVgm9U9k:APA91bFFP5VNyiung_5Z9jFBO88aBvEqqLqNpANmxF0t18Ony3enkLDUkgJ7y_o31caE1v6VTz_dDa2scUOG4FW4ptnlxx2oLnZ9qnb9jkthThv7keX0SanNnqaJ9a48yHmv_yZr3-UQ
    });

    _firebaseMessaging.configure(
      // ignore: missing_return
      onMessage: (info) {
        print('======= OnMessageEEEEEE ======');
        print(info);
        Map argumento = {"data": info['data'], "type": 'on'};
        /* String argumento = 'no-data';
        argumento = info['data']['identifier'];*/

        //  argument = info['data']['message'] ?? {};
        ///print(argumento);
        _mensajesStreamController.sink.add(argumento);
      },
      // ignore: missing_return
      onResume: (info) {
        print('======= OnResume ======');
        // print(info);
        Map argumento = {"data": info['data'], "type": 'ba'};
        /* String argumento = 'no-data';
        argumento = info['data']['identifier'];*/

        //  argument = info['data']['message'] ?? {};
        _mensajesStreamController.sink.add(argumento);
      },
      // ignore: missing_return
      onLaunch: (info) {
        print('======= OnLaunch ======');
        /*
        if(Platform.isAndroid){
          argument = info['data']['comida'] ?? 'no-data';
        }
        _mensajesStreamController.sink.add(argument);*/
      },
    );
  }*/

  dispose() {
    _mensajesStreamController?.close();
  }
}
