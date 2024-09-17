import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/config.dart';
//import 'package:worker/widgets/chatnew/chats.dart';
import '../../local/database_creator.dart';
import 'dart:ui';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:worker/widgets/chatnew/chats.dart';
import '../../model/user.dart';
import '../../providers/client_notif.dart';
import '../../providers/notifications.dart';

import 'dart:async';

import '../my-profile/index.dart';
import 'badge_icon.dart';
import 'showqr.dart';

// ignore: must_be_immutable
class AppBarButton extends StatefulWidget {
  var user;
  final int selectIndex;
  final bool noti;
  final String rol;

  AppBarButton(
      {this.user,
      required this.selectIndex,
      required this.noti,
      required this.rol});

  @override
  _AppBarButtonState createState() =>
      _AppBarButtonState(user, selectIndex, noti, rol);
}

class _AppBarButtonState extends State<AppBarButton> {
  var user;
  late int selectIndex;
  late bool noti;
  late String rol;
  _AppBarButtonState(this.user, this.selectIndex, this.noti, this.rol);
  late StreamSubscription<ClientEvents> _subEvents;
  late StreamSubscription<Map> _countSubscription;

  var jsonData;
  late User userModel;
  //bool noti = false;
  // ignore: unused_field
  late int _selectedIndex = 0;
  late Config config = Config(
      0, '', '', '', '', '', '', '', '', 'btn_id', '', '', '', '', '', '', '');
  late Color myColor = Color(0xff00bfa5);
  late StreamController<int> _countController = StreamController<int>();

  //int _currentIndex = 0;
  late int _tabBarCount = 0;
  late int _chats = 0;
  late ValueNotifier<int> notificationCounterValueNotifer = ValueNotifier(0);
  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      config = todo;
    });
    return todo;
  }

  getChats() async {
    SharedPreferences nada = await SharedPreferences.getInstance();
    int? intValue = nada.getInt('intChatsValue');
    return intValue;
  }

  void _showOut() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        //title: Text('Comming Soon'),
        content: Text('Comming Soon'),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012'))),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showBank() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(32.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          width: 300.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 5.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Soon',
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012')),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              InkWell(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.50,
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    //color: myColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: HexColor('EA6012')),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  getCountChats() async {
    _chats = await getChats();
    print(_chats);
  }

  _onTap(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DashboardHome(
                    noti: false,
                    data: {},
                  )),
        );
        break;
      case 1:
        /* Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListChat(
                    user: this.widget.user,
                  )),
        );*/
        /* Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatsNew()),
        );*/

        break;
      case 2:
        setState(() {
          selectIndex = 2;
        });
        //_showQr();
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ShowQRWorker(
                    config: config,
                  )),
        );
        break;
      case 3:
        _showBank();
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => MyProfile(
                    user: widget.user,
                  )),
        );
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    getTodo(1);
    super.initState();
    this.getCountChats();
    /* _countSubscription =
        NotificationService.instance.countStream.listen((event) async {
      _chats = await getChats();
      _countController.sink.add(event['count']);
      _tabBarCount = event['count'];
    });*/
  }

  @override
  void dispose() {
    _countSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chats != null) {
      print(_chats);
    }
    if (config != null) {
      print(config.image);
      print(config.role);
      print(selectIndex);
    }
    int _selectedIndex = selectIndex;
    if (config != null && config.role != null) {
      return BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/home.png'), size: 25),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder(
              initialData: _tabBarCount,
              stream: _countController.stream,
              builder: (_, snapshot) => BadgeIcon(
                  icon: ImageIcon(AssetImage('assets/chat.png'), size: 25),
                  badgeCount: _chats != null
                      ? _chats
                      : 0 //snapshot.data != 0 ? snapshot.data : _chats,
                  ),
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/codigo-qr.png'), size: 40),
            label: 'Codigo QR',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage('assets/money.png'),
              size: 27,
            ),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/usuario.png'), size: 25),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: HexColor('EA6012'),
        onTap: _onTap,
      );
    } else {
      return Text('');
    }
  }
}
