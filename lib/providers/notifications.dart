import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/local/service.dart';
import 'package:worker/model/config.dart';
import 'package:worker/model/contract.dart';
import 'package:worker/providers/notification_bloc.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

class NotificationService {
  /// We want singelton object of ``NotificationService`` so create private constructor
  /// Use NotificationService as ``NotificationService.instance``
  // NotificationService._internal();

  //static final NotificationService instance = NotificationService._internal();

  //FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  /* FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      new FlutterLocalNotificationsPlugin();*/

  /// For local_notification id
  int _count = 0;
  late String _countM;
  late int msg;

  ValueNotifier<int> notificationCounterValueNotifer = ValueNotifier(0);

  Stream<Map<String, dynamic>> get countStream => _countStreamController.stream;

  final _countStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get countStream1 =>
      _countStreamController1.stream;

  final _countStreamController1 =
      StreamController<Map<String, dynamic>>.broadcast();

  /// ``NotificationService`` started or not.
  /// to start ``NotificationService`` call start method
  bool _started = false;
  late Config config;
  late Contract contract;

  /// Call this method on startup
  /// This method will initialise notification settings
  void start() {
    if (!_started) {
      _integrateNotification();
      _refreshToken();
      _started = true;
    }
  }

  // Call this method to initialize notification

  void _integrateNotification() {
    _registerNotification();
    //_initializeLocalNotification();
  }

  /// initialize firebase_messaging plugin
  void _registerNotification() {
    //  _firebaseMessaging.requestNotificationPermissions();

    /// App in foreground -> [onMessage] callback will be called
    /// App terminated -> Notification is delivered to system tray. When the user clicks on it to open app [onLaunch] fires
    /// App in background -> Notification is delivered to system tray. When the user clicks on it to open app [onResume] fires
    /*   _firebaseMessaging.configure(
      onMessage: _onMessage,
      onLaunch: _onLaunch,
      onResume: _onResume,
    );
    _firebaseMessaging.onTokenRefresh
        .listen(_tokenRefresh, onError: _tokenRefreshFailure);*/
  }

  /// Token is unique identity of the device.
  /// Token is required when you want to send notification to perticular user.
  void _refreshToken() {
    /* _firebaseMessaging.getToken().then((token) async {
      print('token: $token');
    }, onError: _tokenRefreshFailure);*/
  }

  /// This method will be called device token get refreshed
  void _tokenRefresh(String newToken) async {
    print('New Token : $newToken');
  }

  void _tokenRefreshFailure(error) {
    print("FCM token refresh failed with error $error");
  }

  getChats() async {
    SharedPreferences chats = await SharedPreferences.getInstance();
    int? intValue = chats.getInt('intChatsValue');
    return intValue;
  }

  getNotif() async {
    SharedPreferences notif = await SharedPreferences.getInstance();
    int? intValue = notif.getInt('intValue');
    return intValue;
  }

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);

    return todo;
  }

  getContract(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable5}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final contract = Contract.fromJson(data.first);

    return contract;
  }

  /// This method will be called on tap of the notification which came when app was in foreground
  ///
  /// Firebase messaging does not push notification in notification panel when app is in foreground.
  /// To send the notification when app is in foreground we will use flutter_local_notification
  /// to send notification which will behave similar to firebase notification
  Future<void> _onMessage(Map<String, dynamic> message) async {
    int priority;
    print('onMessage: $message');
    config = await getTodo(1);
    contract = await getContract(1);
    print('onmessage');
    print(message);

    if (message['data']['identifier'] == 'MESSAGE_CHAT') {
      print('entro en notif chat');
      print(message);
      int total = await getChats();
      msg = total + 1;
      Map<String, dynamic> countm = {'count': msg};
      _countStreamController.sink.add(countm);

      Map<String, dynamic> count = {
        'count': msg,
        'message': message,
        'priority': 1
      };
      _countStreamController1.sink.add(count);

      SharedPreferences chats = await SharedPreferences.getInstance();
      chats.setInt('intChatsValue', msg);
    }

    if (message['data']['identifier'] != 'MESSAGE_CHAT') {
      int totaln = await getNotif();
      if (message['data']['identifier'] == 'CERTIFICATION_TYPE_PUBLISHED' ||
          message['data']['identifier'] == 'JOB_OFFER' ||
          message['data']['identifier'] == 'WORKER_ACCEPTED' ||
          message['data']['identifier'] == 'ROLE' ||
          message['data']['identifier'] == 'TRAVEL' ||
          message['data']['identifier'] == 'WARNING' ||
          message['data']['identifier'] == 'END_CONTRACT' ||
          message['data']['identifier'] == 'CUSTOM_PUSH_NOTIFICATION') {
        priority = 1;
      } else {
        priority = 0;
      }
      Map<String, dynamic> count = {
        'count': totaln + 1,
        'message': message,
        'priority': priority
      };
      _countStreamController1.sink.add(count);
      SharedPreferences notif = await SharedPreferences.getInstance();
      notif.setInt('intValue', totaln + 1);
    }

    if (message['data']['identifier'] == 'ROLE') {
      priority = 1;
      if (message['data']['value'].toString() == 'false') {
        RepositoryServiceTodo.updateModulesN(config, '');
      } else {
        RepositoryServiceTodo.updateModulesN(config, message['data']['role']);
      }
      /* int totaln = await getNotif();
      Map<String, dynamic> count = {
        'count': totaln + 1,
        'message': message,
        'priority': priority
      };
      _countStreamController1.sink.add(count);
      SharedPreferences notif = await SharedPreferences.getInstance();
      notif.setInt('intValue', totaln + 1);*/
    }

    if (message['data']['identifier'] == 'END CONTRACT') {
      priority = 1;
      RepositoryServiceTodo.updateContract(config, '');
      RepositoryServiceTodo.updateContractDetail(contract, '', '', '');
      //int totaln = await getNotif();
      /* Map<String, dynamic> count = {
        'count': totaln + 1,
        'message': message,
        'priority': priority
      };
      _countStreamController1.sink.add(count);
      SharedPreferences notif = await SharedPreferences.getInstance();
      notif.setInt('intValue', totaln + 1);*/
    }

    if (Platform.isIOS) {
      //message = _modifyNotificationJson(message);
    }

    _showNotification(
      {
        "title": message['notification']['title'],
        "body": message['notification']['body'],
        "data": message['data'],
      },
    );

    //_performActionOnNotification(message);
    return null;
  }

  /// This method will be called on tap of the notification which came when app was closed
  Future<void> _onLaunch(Map<String, dynamic> message) async {
    if (message['data']['identifier'] != 'MESSAGE_CHAT') {
      // ignore: unused_local_variable
      int priority;
      if (message['data']['identifier'] == 'CERTIFICATION_TYPE_PUBLISHED' ||
          message['data']['identifier'] == 'JOB_OFFER' ||
          message['data']['identifier'] == 'WORKER_ACCEPTED' ||
          message['data']['identifier'] == 'ROLE' ||
          message['data']['identifier'] == 'TRAVEL' ||
          message['data']['identifier'] == 'WARNING' ||
          message['data']['identifier'] == 'END_CONTRACT' ||
          message['data']['identifier'] == 'CUSTOM_PUSH_NOTIFICATION') {
        priority = 1;
      } else {
        priority = 0;
      }
      int totaln = await getNotif();
      Map<String, dynamic> countm = {
        'count': totaln + 1,
        'message': message,
        'priority': priority
      };
      _countStreamController1.sink.add(countm);
      SharedPreferences notif = await SharedPreferences.getInstance();
      notif.setInt('intValue', totaln + 1);
    }
    //FlutterAppBadger.removeBadge();

    /* print('onLaunch: $message');
    if (message['data']['identifier'] == 'MESSAGE_CHAT') {
      int total = await getChats();
      msg = total + 1;
      Map<String, dynamic> countm = {'count': msg};
      _countStreamController.sink.add(countm);

      SharedPreferences chats = await SharedPreferences.getInstance();
      chats.setInt('intValue', msg);

      // print(notificationCounterValueNotifer.value.toString());
    }
    if (message['data']['identifier'] == 'ROLE') {
      print(message['data']['value']);
      if (message['data']['value'].toString() == 'false') {
        RepositoryServiceTodo.updateModulesN(config, '');
      } else {
        RepositoryServiceTodo.updateModulesN(config, message['data']['role']);
      }
    }
    if (Platform.isIOS) {
      message = _modifyNotificationJson(message);
    }
    _performActionOnNotification(message);
    return null;*/
  }

  /// This method will be called on tap of the notification which came when app was in background
  Future<void> _onResume(Map<String, dynamic> message) async {
    // FlutterAppBadger.updateBadgeCount(1);
    print('onResume: $message');
    print('onResume');
    print(message);
    if (message['data']['identifier'] == 'MESSAGE_CHAT') {
      int total = await getChats();
      msg = total + 1;
      Map<String, dynamic> countm = {'count': msg};
      _countStreamController.sink.add(countm);

      SharedPreferences chats = await SharedPreferences.getInstance();
      chats.setInt('intChatsValue', msg);

      // print(notificationCounterValueNotifer.value.toString());
    }

    if (message['data']['identifier'] != 'MESSAGE_CHAT') {
      // ignore: unused_local_variable
      int priority;
      if (message['data']['identifier'] == 'CERTIFICATION_TYPE_PUBLISHED' ||
          message['data']['identifier'] == 'JOB_OFFER' ||
          message['data']['identifier'] == 'WORKER_ACCEPTED' ||
          message['data']['identifier'] == 'ROLE' ||
          message['data']['identifier'] == 'TRAVEL' ||
          message['data']['identifier'] == 'WARNING' ||
          message['data']['identifier'] == 'END_CONTRACT' ||
          message['data']['identifier'] == 'CUSTOM_PUSH_NOTIFICATION') {
        priority = 1;
      } else {
        priority = 0;
      }
      int totaln = await getNotif();
      Map<String, dynamic> countm = {
        'count': totaln + 1,
        'message': message,
        'priority': priority
      };
      _countStreamController1.sink.add(countm);
      SharedPreferences notif = await SharedPreferences.getInstance();
      notif.setInt('intValue', totaln + 1);
    }

    if (message['data']['identifier'] == 'ROLE') {
      int totaln = await getNotif();
      Map<String, dynamic> countm = {'count': totaln + 1};
      _countStreamController1.sink.add(countm);
      SharedPreferences notif = await SharedPreferences.getInstance();
      notif.setInt('intValue', totaln + 1);
      if (message['data']['value'].toString() == 'false') {
        RepositoryServiceTodo.updateModulesN(config, '');
      } else {
        RepositoryServiceTodo.updateModulesN(config, message['data']['role']);
      }
    }
    if (Platform.isIOS) {
      //message = _modifyNotificationJson(message);
    }
    //_performActionOnNotification(message);
    _showNotification(
      {
        "title": message['notification']['title'],
        "body": message['notification']['body'],
        "data": message['data'],
      },
    );

    return null;
  }

  /// This method will modify the message format of iOS Notification Data
  Map _modifyNotificationJson(Map<String, dynamic> message) {
    message['data'] = Map.from(message ?? {});
    message['notification'] = message['aps']['alert'];
    return message;
  }

  /// We want to perform same action of the click of the notification. So this common method will be called on
  /// tap of any notification (onLaunch / onMessage / onResume)
  void _performActionOnNotification(Map<dynamic, dynamic> message) {
    Map<String, dynamic> count = {
      'count': notificationCounterValueNotifer.value
    };
    // NotificationsBloc.instance.newNotification(message);
  }

  /// used for sending push notification when app is in foreground
  void _showNotification(message) async {
    /*var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'Notification Test',
      'Notification Test',
      '',
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      message['title'],
      message['body'],
      platformChannelSpecifics,
      payload: json.encode(
        message['data'],
      ),
    );*/
  }

  /// initialize flutter_local_notification plugin
  /* void _initializeLocalNotification() {
    // Settings for Android
    var androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    // Settings for iOS
    var iosInitializationSettings = new IOSInitializationSettings();
    _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      ),
      onSelectNotification: _onSelectLocalNotification,
    );
  }*/

  /* void _initializeLocalNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/favicon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    /*await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);*/
  }*/

  /*void _initializeLocalNotification() async {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('favicon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String title, String body, String payload) async {});
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      ),
      onSelectNotification: _onSelectLocalNotification,
    );
  }*/

  /// This method will be called on tap of notification pushed by flutter_local_notification plugin when app is in foreground
  /* Future _onSelectLocalNotification(String payLoad) {
    FlutterAppBadger.updateBadgeCount(1);

    Map data = json.decode(payLoad);
    Map<String, dynamic> message = {
      "data": data,
    };
    _performActionOnNotification(message);
    return ;
  }*/

  void dispose() {
    _countStreamController.close();
    _countStreamController1.close();
  }
}
