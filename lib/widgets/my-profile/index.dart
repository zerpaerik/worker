import 'package:worker/model/config.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:worker/widgets/my-profile/body.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../local/database_creator.dart';

import '../../model/user.dart';
import '../../providers/auth.dart';
import '../dashboard/appbar.dart';
import '../dashboard/badge_icon.dart';

class MyProfile extends StatefulWidget {
  static const routeName = '/my-profile';
  final User user;
  final Config? config;

  // ignore: prefer_const_constructors_in_immutables
  MyProfile({required this.user, required this.config});

  @override
  _MyProfileState createState() => _MyProfileState(user, config!);
}

class _MyProfileState extends State<MyProfile> {
  late User user;
  late Config config;
  _MyProfileState(this.user, this.config);
  late User _user;
  // ignore: unused_field
  late int _selectedIndex = 4;
  late Config configr;

  getTodo(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = Config.fromJson(data.first);
    setState(() {
      configr = todo;
    });
    return todo;
  }

  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      setState(() {
        _user = value;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _viewUser();
    getTodo(1);
  }

  /*void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      setState(() {
        user = value;
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: HexColor('EA6012'),
          ),
          title: Image.asset(
            "assets/nuevo-naranja.png",
            width: 120,
            alignment: Alignment.topLeft,
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DashboardHome(noti: false, data: {})),
            ),
          ),
          actions: [
            IconButton(
                icon: BadgeIcon(
                    icon: ImageIcon(
                      AssetImage('assets/notif.png'),
                      size: 25,
                      color: Colors.grey,
                    ),
                    badgeCount: 0 //snapshot.data != 0 ? snapshot.data : _chats,
                    ),
                onPressed: () {
                  /*  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ListNotifications(
                              user: user,
                            )),
                  );*/
                })
          ]),

      /*endDrawer:
          MenuLateralProfile(user: _user != null ? _user : this.widget.user),*/
      body: BodyProfile(
        user: _user != null ? _user : this.widget.user,
        config: configr,
      ),
      bottomNavigationBar: AppBarButton(
        user: this.widget.user,
        selectIndex: 4,
        noti: false,
        rol: '',
      ),
    );
  }
}
