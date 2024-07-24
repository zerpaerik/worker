import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:worker/providers/url_constants.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:worker/model/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../providers/auth.dart';
import '../global.dart';
import '../login/preview.dart';
import 'change_password_user.dart';
import 'delete_account/info.dart';

class ConfigPage extends StatefulWidget {
  final User user;

  ConfigPage({required this.user});
  @override
  _ConfigPageState createState() => _ConfigPageState(user);
}

class _ConfigPageState extends State<ConfigPage> {
  late User user;
  _ConfigPageState(this.user);
  _launchURLTerms() async {
    const url = '${ApiWebServer.server_name}/terms-and-conditions';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _launchURLPolicy() async {
    const url = ApiWebServer.server_name + '/privacy-policy';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> logout() async {
    String token = await getToken();
    var res = await http.post(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/auth/logout'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token'
        });

    if (res.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isLoggedIn", false);
      SharedPreferences prefrences = await SharedPreferences.getInstance();
      await prefrences.clear();

      Navigator.push(context,
          MaterialPageRoute(builder: (context) => const PreviewAccount()));
    } else {}

    print(res.statusCode);
    print(res.body);
  }

  Future<dynamic> inactive() async {
    String token = await getToken();
    var res = await http.post(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/auth/deactivate_user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Token $token'
        });

    if (res.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs?.setBool("isLoggedIn", false);
      SharedPreferences prefrences = await SharedPreferences.getInstance();
      await prefrences.clear();

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => PreviewAccount()));
    } else {}

    print(res.statusCode);
    print(res.body);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    void _showErrorDialog() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.logout_),
          content: Text(l10n.logout_confirm),
          titleTextStyle: TextStyle(
              color: HexColor('373737'),
              fontFamily: 'OpenSansRegular',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.no,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('EA6012'))),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: Text(l10n.si,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('EA6012'))),
              onPressed: () {
                Navigator.of(ctx).pop();
                logout();
              },
            )
          ],
        ),
      );
    }

    void _showInactiveAccount() {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.inactive_),
          content: Text(l10n.inactive_confirm),
          titleTextStyle: TextStyle(
              color: HexColor('373737'),
              fontFamily: 'OpenSansRegular',
              fontWeight: FontWeight.bold,
              fontSize: 20),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.no,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('EA6012'))),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              child: Text(
                l10n.si,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: HexColor('EA6012')),
              ),
              onPressed: () {
                Navigator.of(ctx).pop();
                inactive();
              },
            )
          ],
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 2.0,
          backgroundColor: Colors.white,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: HexColor('EA6012'),
          ),
          title: Align(
              alignment: Alignment.topLeft,
              child: Text(
                l10n.setting,
                style: TextStyle(
                  color: HexColor('EA6012'),
                  fontSize: 18,
                ),
              ))),
      body: Column(children: <Widget>[
        Container(
            margin: EdgeInsets.only(left: 15, top: 15),
            child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                    onPressed: () {
                      launch("$urlServices/terms-and-conditions");
                    },
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.black,
                    ),
                    label: Text(
                      l10n.terms,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )))),
        Container(
            margin: EdgeInsets.only(left: 15, top: 5),
            child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                    onPressed: () {
                      launch("$urlServices/privacy-policy");
                    },
                    icon: Icon(
                      Icons.lock_outline,
                      color: Colors.black,
                    ),
                    label: Text(
                      l10n.policies,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )))),
        Container(
            margin: EdgeInsets.only(left: 15, top: 5),
            child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChangePasswordUser(
                                  user: this.widget.user,
                                )),
                      );
                    },
                    icon: Icon(
                      Icons.edit,
                      color: Colors.black,
                    ),
                    label: Text(
                      l10n.change_password,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )))),
        Container(
            margin: EdgeInsets.only(left: 15, top: 5),
            child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                    onPressed: () {
                      _showInactiveAccount();
                    },
                    icon: Icon(
                      Icons.info_rounded,
                      color: Colors.black,
                    ),
                    label: Text(
                      l10n.inactive,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )))),
        Container(
            margin: EdgeInsets.only(left: 15, top: 5),
            child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InfoDelete()));
                      //_showInactiveAccount();
                    },
                    icon: Icon(
                      Icons.delete,
                      color: Colors.black,
                    ),
                    label: Text(
                      l10n.delete_a,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    )))),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        Container(
            margin: EdgeInsets.only(left: 15, top: 5),
            child: Align(
                alignment: Alignment.topLeft,
                child: TextButton.icon(
                    onPressed: _showErrorDialog,
                    icon: Icon(
                      Icons.exit_to_app,
                      color: Colors.black,
                    ),
                    label: Text(
                      l10n.logout,
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ))))
      ]),
    );
  }
}
