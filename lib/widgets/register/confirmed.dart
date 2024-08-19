import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_mail_app/open_mail_app.dart';

import '../global.dart';
//import '../profile/confirm.dart';
//import '../profile/confirm.dart';

class ConfirmedRegister extends StatefulWidget {
  static const routeName = '/confirmed-account';

  final String email;
  final int user;
  final int code;

  ConfirmedRegister(this.email, this.user, this.code);

  @override
  _ConfirmedRegisterState createState() =>
      _ConfirmedRegisterState(email, user, code);
}

class _ConfirmedRegisterState extends State<ConfirmedRegister> {
  late String email;
  late int user;
  late int code;
  _ConfirmedRegisterState(this.email, this.user, this.code);

  late bool _isLoading = false;
  late Future<void> _launched;
  late String titlet;

  Future<dynamic> resend(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });
    final l10n = AppLocalizations.of(context)!;

    int u = this.widget.user;
    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/user/resend_email/$u'));
    var resBody = json.decode(res.body);
    print(res.statusCode);

    if (res.statusCode == 200) {
      _showErrorDialog(l10n.resend_email_success);
    }

    setState(() {
      _isLoading = false;
    });
    print(resBody);

    return "Sucess";
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        // title: Text(AppTranslations.of(context).text("error")),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  void showNoMailAppsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Open Mail App"),
          content: Text("No mail apps installed"),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String _titleH = l10n.confirm_register;
    titlet = l10n.confirm_register;
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          HexColor('EF6826'),
          HexColor('FBB03B'),
        ],
      )),
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.12,
          ),
          Container(
              child: Align(
            alignment: Alignment.center,
            child: Image.asset(
              'assets/sobre_naranja.png',
              width: 120,
              color: Colors.white,
            ),
          )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          ),
          if (widget.code == 1) ...[
            Container(
                child: Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/aceptar-1.png',
                width: 120,
                color: Colors.white,
              ),
            )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
          ],
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  l10n.confirm_1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  l10n.confirm_2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      //fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  this.widget.email,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  l10n.confirm_3,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18,
                      // fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          if (this.widget.code == 1) ...[
            Container(
              margin: EdgeInsets.only(left: 30.0, right: 30.0),
              padding: EdgeInsets.symmetric(vertical: 1.0),
              width: double.infinity,
              child: ElevatedButton(
                //borderSide: BorderSide(color: HexColor('EA6012')),
                //onPressed: () => select("English"),
                onPressed: () async {
                  /* Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ConfirmProfile()),
                  );*/
                },

                child: Text(
                  'Completar perfil',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: HexColor('EA6012')),
                ),
              ),
            ),
          ],
          Container(
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
            padding: EdgeInsets.symmetric(vertical: 1.0),
            width: double.infinity,
            child: ElevatedButton(
              //borderSide: BorderSide(color: HexColor('EA6012')),
              //onPressed: () => select("English"),
              onPressed: () async {
                var apps = await OpenMailApp.getMailApps();
                if (apps.isEmpty) {
                  print('nulll');
                  showNoMailAppsDialog(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return MailAppPickerDialog(
                        mailApps: apps,
                        title: titlet,
                      );
                    },
                  );
                }
              },

              child: Text(
                l10n.confirm_4,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: HexColor('EA6012')),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Container(
            margin: EdgeInsets.only(left: 30.0, right: 30.0),
            padding: EdgeInsets.symmetric(vertical: 1.0),
            width: double.infinity,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(HexColor('EA6012')),
                    ), //borderSide: BorderSide(color: HexColor('EA6012')),
                    //onPressed: () => select("English"),
                    onPressed: () {
                      resend(context);
                    },

                    child: Text(
                      l10n.confirm_5,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    ));
  }
}
