import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:app_settings/app_settings.dart';
import '../../local/database_creator.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:worker/widgets/clock-out/detail_ext_sc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:convert';

import '../../model/user.dart';
import '../../model/workday.dart';
import '../../providers/workday.dart';
import '../clock-in/list.dart';
import '../global.dart';
import '../widgets.dart';
import 'list.dart';

class SelfClockOut extends StatefulWidget {
  User? user;
  int? workday;
  Workday? work;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? wk;

  SelfClockOut(
      {required this.user, this.workday, this.work, this.contract, this.wk});

  @override
  _SelfClockOutState createState() =>
      _SelfClockOutState(user!, workday!, work!, contract!, wk!);
}

class _SelfClockOutState extends State<SelfClockOut> {
  User user;
  int workday;
  Workday work;
  Map<String, dynamic> contract;
  Map<String, dynamic> wk;

  _SelfClockOutState(
      this.user, this.workday, this.work, this.contract, this.wk);
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;
  Geolocator? geolocator = Geolocator();
  String? qrCodeResult = "Not Yet Scanned";
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Position? userLocation;
  String? geo;
  Map<String, dynamic>? workday_on;
  String? temp = '';
  int? tm;
  Workday? _wd;

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  getWorkdayOn(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      workday_on = todo;
    });
    print(workday_on);
    return workday_on;
  }

  void _viewWorkDay() {
    Provider.of<WorkDay>(context, listen: false).fetchWorkDay().then((value) {
      setState(() {
        _wd = value;
      });
    });
  }

  Future<void> _submitClockIn() async {
    String contract = widget.contract!['contract_id'].toString();
    setState(() {
      isLoading = true;
    });
    _getLocation().then((position) {
      userLocation = position;
    });
    if (userLocation != null) {
      geo = '${userLocation!.latitude} ${userLocation!.longitude}';
    } else {
      geo = '--- ---';
    }
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addClockInExt(widget.user!.id, geo, geo, widget.wk, temp)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        getWorkdayOn(1);
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListClockIn(
                      user: user,
                      workday: response['workday']['id'],
                      contract: widget.contract,
                      work: Workday.fromJson(response['workday']),
                      wk: workday_on,
                    )),
          );
        } else {
          _showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
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

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    int wk = workday_on!['workday_id'];
    print(wk);
    if (userLocation != null) {
      geo = '${userLocation!.latitude} ${userLocation!.longitude}';
    } else {
      geo = '--- ---';
    }
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkday(wk, geo, "", "")
          .then((response) {
        setState(() {
          isLoading = false;
        });
        print(response);
        if (response['status'] == '200') {
          print(response['workday']);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListClockOut(
                    user: user,
                    workday: workday_on!['workday_id'],
                    work: Workday.fromJson(response['workday']),
                    contract: widget.contract,
                    wk: workday_on)),
          );
        } else {
          _showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<void> _submits() async {
    setState(() {
      isLoading = true;
    });

    if (userLocation != null) {
      geo = '${userLocation!.latitude} ${userLocation!.longitude}';
    } else {
      geo = '--- ---';
    }

    try {
      Provider.of<WorkDay>(context, listen: false)
          .selfClockOut(
              widget.user!.id, workday_on, workday_on!['clock_out_init'], geo)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        getWorkdayOn(1);
        if (response == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListClockOut(
                    user: user,
                    workday: workday_on!['workday_id'],
                    // work: Workday.fromJson(response['workday']),
                    contract: widget.contract,
                    wk: workday_on)),
          );
        } else {
          _showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  @override
  void initState() {
    super.initState();
    _viewWorkDay();
    _getLocation().then((position) {
      userLocation = position;
    });
    getWorkdayOn(1);
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
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 20),
                  alignment: Alignment.topLeft,
                  //height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 20),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
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
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Clock out',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          if (workday_on != null && workday_on!['clock_out_init'] == '') ...[
            Container(
                margin: const EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.clockout_1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                )),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30, top: 100),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        _submit();
                      },
                      child: Text(
                        'Iniciar clock out',
                        style:
                            TextStyle(fontSize: 20, color: HexColor('EA6012')),
                      ),
                    ),
            )
          ],
          if (workday_on != null && workday_on!['clock_out_init'] != '') ...[
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: const Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Hay un proceso de clock-out en curso, debes hacer tu registro de ingreso.',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                )),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30, top: 100),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        _submit();
                      },
                      child: Text(
                        'Hacer clock out',
                        style:
                            TextStyle(fontSize: 20, color: HexColor('EA6012')),
                      ),
                    ),
            )
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
          ),
        ],
      ),
    )));
  }
}
