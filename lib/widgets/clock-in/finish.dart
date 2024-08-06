import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';

import 'dart:io';
import '../../model/user.dart';
import '../../model/workday.dart';

import '../widgets.dart';
import 'list.dart';

class FinishClockIn extends StatefulWidget {
  static const routeName = '/new-expenses';
  final User? user;

  final int? workday;
  Map<String, dynamic>? contract;
  Workday? work;

  FinishClockIn({this.user, this.workday, this.contract, this.work});

  @override
  _FinishClockInState createState() =>
      _FinishClockInState(user!, workday!, contract!, work!);
}

class _FinishClockInState extends State<FinishClockIn> {
  User? user;
  int? workday;
  Map<String, dynamic>? contract;
  Workday? work;
  _FinishClockInState(this.user, this.workday, this.contract, this.work);
  int? vehicle;

  String? success;
  bool signa = false;
  File? image;

  double? maxtop;
  double? maxwidth;

  // ignore: unused_field
  File? _storedImageC;

  // ignore: unused_field
  String? _myActivityResult;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
            height: MediaQuery.of(context).size.height * 0.09,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/in.png',
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
                  l10n.clockin_22,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                      color: Colors.white),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.clockin_21,
                  style: TextStyle(fontSize: 14, color: Colors.white),
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ListClockIn(
                            user: widget.user,
                            workday: widget.workday,
                            work: widget.work,
                            contract: widget.contract,
                            wk: {},
                          )),
                );
              },
              child: Text(
                l10n.finish,
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
