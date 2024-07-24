// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/my-profile/info-personal/part_acad.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../local/database_creator.dart';

import '../../model/user.dart';
import '../../model/workday.dart';
import '../../model/config.dart';
import 'config.dart';
import 'data-request.dart';
import 'info-personal/part_oblig.dart';
import 'job-offer/list.dart';

class MenuLateralProfile extends StatefulWidget {
  final User user;

  MenuLateralProfile({required this.user});

  @override
  _MenuLateralProfileState createState() => _MenuLateralProfileState(user);
}

class _MenuLateralProfileState extends State<MenuLateralProfile> {
  late User user;
  _MenuLateralProfileState(this.user);
  late Workday _wd;
  late Config config;

  getWorkDay() async {
    SharedPreferences workday = await SharedPreferences.getInstance();
    //Return String
    int? intValue = workday.getInt('intValue');
    return intValue;
  }

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

  @override
  void initState() {
    super.initState();
    getTodo(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: 260,
      child: Drawer(
          child: ListView(children: <Widget>[
        SizedBox(
          //height : 20.0,
          child: Row(children: <Widget>[
            SizedBox(
              //height : 20.0,
              child: Row(children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 30, top: 12),
                    child: Text(
                      l10n.option_menu,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )),
              ]),
            ),
          ]),
        ),
        Container(
          margin: EdgeInsets.only(top: 2),
          child: Divider(),
        ),
        if (config != null) ...[
          if (config.id_type == 'business') ...[
            Divider(),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/hotel.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          'Hotel',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {},
                        icon: ImageIcon(
                          AssetImage('assets/viajes.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          'Viajes',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
          ],
          if (config.id_type != 'business') ...[
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewProfileOblig(user: this.widget.user)),
                          );
                        },
                        icon: ImageIcon(
                          AssetImage('assets/001-identity.png'),
                          color: Colors.black,
                        ),
                        label: Row(
                          children: <Widget>[
                            Text(
                              l10n.info_per,
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          ],
                        )))),
            Divider(),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewProfileAcad(user: this.widget.user)),
                          );
                        },
                        icon: ImageIcon(
                          AssetImage('assets/002-data.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          l10n.info_acad,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
            /* Container(
            margin: EdgeInsets.only(left: 10),
            child: Align(
                alignment: Alignment.topLeft,
                child: FlatButton.icon(
                    onPressed: () {
                      if (user.id_type == '1' || user.id_type == '3') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LegalSituation()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DataItin()),
                        );
                      }
                    },
                    icon: ImageIcon(
                      AssetImage('assets/elegibilidad.png'),
                      color: Colors.grey,
                    ),
                    label: Text(
                      AppTranslations.of(context).text("emplooy_elegibility"),
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    )))),
        Divider(),*/
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    JobOfferPage(user: this.widget.user)),
                          );
                        },
                        icon: ImageIcon(
                          AssetImage('assets/contrato.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          l10n.job_offer,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DataRequestProfile(
                                      user: this.widget.user,
                                    )),
                          );
                        },
                        icon: ImageIcon(
                          AssetImage('assets/elegibilidad.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          l10n.mod_perfil,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ListEmplooyment(
                                      user: this.widget.user,
                                    )),
                          );*/
                          /* if (user.id_type == '1' || user.id_type == '3') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LegalSituation()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => DataItin()),
                        );
                      }*/
                        },
                        icon: ImageIcon(
                          AssetImage('assets/elegibilidad.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          l10n.legal_document_detail,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
            Container(
                margin: EdgeInsets.only(left: 10),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ConfigPage(
                                      user: user,
                                    )),
                          );
                        },
                        icon: ImageIcon(
                          AssetImage('assets/005-gear.png'),
                          color: Colors.black,
                        ),
                        label: Text(
                          l10n.setting,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        )))),
            Divider(),
          ],
        ]
      ])),
    );
  }
}
