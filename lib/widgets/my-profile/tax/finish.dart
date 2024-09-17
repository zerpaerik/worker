import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/model/config.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'dart:io';
import '../../../model/user.dart';
import '../../../model/workday.dart';

import '../../widgets.dart';
import '../index.dart';

class FinishW9 extends StatefulWidget {
  static const routeName = '/new-expenses';
  final User user;

  FinishW9({required this.user});

  @override
  _FinishW9State createState() => _FinishW9State(user);
}

class _FinishW9State extends State<FinishW9> {
  late User user;
  late int vehicle;
  _FinishW9State(this.user);

  late String success = '';
  late bool signa = false;
  late File image;

  late double maxtop;
  late double maxwidth;

  // ignore: unused_field
  late File _storedImageC;

  // ignore: unused_field
  late String _myActivityResult;
  late Config config;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //SizeConfig().init(context);
    return Scaffold(
        body: Center(
            child: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            HexColor('FE7E1F'),
            HexColor('F57E07'),
            HexColor('F8AF04'),
            HexColor('F5AE07'),
            HexColor('FD821E'),
          ])),
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.13,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/tax.png',
                  color: Colors.white,
                  width: 70,
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'El impuesto ha sido registrado exitosamente',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 35,
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
                child: Image.asset(
                  'assets/check_vehicle.png',
                  width: 180,
                )),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(right: 30),
            //width: MediaQuery.of(context).size.width * 0.70,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(HexColor('EA6012')),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyProfile(
                            user: widget.user,
                          )),
                );
              },
              child: Text(
                'Finalizar',
                style: TextStyle(
                  color: HexColor('EA6012'),
                  letterSpacing: 1,
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
              ),
            ),
          ),
        ],
      ),
    )));
  }
}
