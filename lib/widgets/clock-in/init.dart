import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/config.dart';

import '../../model/user.dart';
import '../../model/workday.dart';

import '../../providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../global.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'list.dart';

class InitClockIn extends StatefulWidget {
  final User user;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? workday;

  InitClockIn({required this.user, this.contract, this.workday});

  @override
  _InitClockInState createState() =>
      _InitClockInState(user, contract!, workday!);
}

class _InitClockInState extends State<InitClockIn> {
  User user;
  Map<String, dynamic> contract;
  Map<String, dynamic> workday;

  _InitClockInState(this.user, this.contract, this.workday);
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;
  Map<String, dynamic>? data;
  Map<String, dynamic>? workday_on;
  bool isData = false;

  Geolocator? geolocator = Geolocator();

  Position? userLocation;
  String? geo;
  String? temp = '';
  int? tm;
  Config? config;
  Workday? _wd;
  Map<String, dynamic>? wd;
  Map<String, dynamic>? contractDetail;
  int? selectedRadio;
  int? selectedRadio1;
  int? selectedRadio2;
  int? selectedRadio3;
  int? selectedRadio4;
  int? selectedRadio5;
  int? selectedRadio6;
  int? selectedRadio7;
  int? selectedRadio8;
  int? selectedRadio9;
  int? selectedRadio10;
  DateTime? start_time;

  String? _time = "S/H";

  DateTime? hourClock; // init workday
  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9; // fin return

  Future _checkGps() async {
    if (!(await Geolocator.isLocationServiceEnabled())) {
      // ignore: use_build_context_synchronously
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Activa tu GPS",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black)),
            content: Text(
                'Para poder gestionar procesos de clock-in y clock-out, debes compartir tu ubicación con Emplooy.',
                style: TextStyle(fontSize: 16, color: Colors.black),
                textAlign: TextAlign.justify),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: HexColor('EA6012'))),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              TextButton(
                child: Text('Ok',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: HexColor('EA6012'))),
                onPressed: () {
                  //AppSettings.openLocationSettings();
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  getWorkdayOn(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      workday_on = todo;
      isData = true;
    });
    print('is data');
    print(isData);
    print(workday_on);
    return workday_on;
  }

  getContract(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable5}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      contractDetail = todo;
    });
    return contractDetail;
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

  Future<Position?> _getLocation() async {
    Position? currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => InitClockIn(
                          user: user,
                          contract: widget.contract,
                        )),
              );
            },
          )
        ],
      ),
    );
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _viewWorkDay() {
    Provider.of<WorkDay>(context, listen: false).fetchWorkDay().then((value) {
      setState(() {
        _wd = value;
      });
      getWorkdayOn(1);
    });
  }

  Future<String> getSWData() async {
    String token = await getToken();
    setState(() {});
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/contract/current'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      data = resBody;
    });

    return "Sucess";
  }

  Future<void> _submit() async {
    print('print contract');
    setState(() {
      isLoading = true;
    });
    await getSWData();
    print(data);
    String contract = data!['id'].toString();

    _getLocation().then((position) {
      userLocation = position;
    });
    if (userLocation != null) {
      geo = '${userLocation?.latitude} ${userLocation?.longitude}';
    } else {
      geo = '--- ---';
    }
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkday(
              contract,
              geo,
              temp,
              contractDetail!['contract_temp'].toString(),
              start_time,
              hourClock)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        //getWorkdayOn(1);
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
        } else if (response['status'] == '400') {
          _showErrorDialog('Not found');
        } else {
          _showErrorDialog('Error');
        }
      });
    } catch (error) {}
  }

  Future<void> _editWorkdayDef() async {
    String contract = widget.contract!['contract_id'].toString();
    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayIn(workday, start_time, hourClock)
          .then((response) {
        setState(() {
          isLoading = false;
        });
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
        } else if (response['status'] == '400') {
          _showErrorDialog('Error');
        } else {
          _showErrorDialog('Error');
        }
      });
    } catch (error) {}
  }

  Future<void> _submits() async {
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
          .selfClockIn(widget.user.id, workday_on, temp,
              workday_on!['clock_in_init'], geo)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        getWorkdayOn(1);
        if (response == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListClockIn(
                      user: user,
                      workday: workday_on!['workday_id'],
                      contract: widget.contract,
                      work: Workday.fromJson(workday_on!),
                      wk: workday_on,
                    )),
          );
        } else {
          _showErrorDialog('Error');
        }
      });
    } catch (error) {}
  }

  void _showInputDialog(String title) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return Scaffold(
              body: SingleChildScrollView(
                  child: Form(
                      key: _scaffoldKey,
                      child: Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 50,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text(title,
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 30),
                                child: Image.asset(
                                  'assets/termometro.png',
                                  width: 30,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                child: const Text(
                                  'Temperature',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(left: 10),
                                width: 50,
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          decimal: true),
                                  onChanged: (value) {
                                    setState(() {
                                      temp = value;
                                      tm = int.parse(temp!);
                                    });
                                  },
                                ),
                              ),
                              const Text('F°')
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.08),
                          Container(
                            margin: const EdgeInsets.only(left: 10, right: 10),
                            child: const Text('Temperature',
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.08),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                    //margin: EdgeInsets.only(left: 20),
                                    alignment: Alignment.center,
                                    //height: MediaQuery.of(context).size.width * 0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 1.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              width: 5.0,
                                              color: HexColor('EA6012')),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        ),
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: HexColor('EA6012')),
                                        ),
                                      ),
                                    )),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                    //margin: EdgeInsets.only(left: 20),
                                    alignment: Alignment.center,
                                    //height: MediaQuery.of(context).size.width * 0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 1.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          if (temp == '') {
                                            _showErrorDialog('Temp oblig');
                                          } else if (tm! >= 100) {
                                            _showErrorDialog('Temp elev');
                                          } else {
                                            Navigator.of(context).pop();
                                            _submit();
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              width: 5.0,
                                              color: HexColor('EA6012')),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        ),
                                        child: Text(
                                          'Si',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: HexColor('EA6012')),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ))));
        });
  }

  void _showInputDialog1(String title) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return Scaffold(
              body: SingleChildScrollView(
                  child: Form(
                      key: _scaffoldKey,
                      child: Column(
                        //mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(
                            height: 50,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text(title,
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.05),
                          Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(left: 30),
                                child: Image.asset(
                                  'assets/termometro.png',
                                  width: 30,
                                  color: Colors.black,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                child: Text(
                                  'Temperature',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 10),
                                width: 50,
                                child: TextFormField(
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true),
                                  onChanged: (value) {
                                    setState(() {
                                      temp = value;
                                      tm = int.parse(temp!);
                                    });
                                  },
                                ),
                              ),
                              Text('F°')
                            ],
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.08),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text('Si',
                                style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.center),
                          ),
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.08),
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 1,
                                child: Container(
                                    //margin: EdgeInsets.only(left: 20),
                                    alignment: Alignment.center,
                                    //height: MediaQuery.of(context).size.width * 0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: OutlinedButton(
                                        //onPressed: () => select("English"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              width: 5.0,
                                              color: HexColor('EA6012')),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        ),
                                        child: Text(
                                          'No',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: HexColor('EA6012')),
                                        ),
                                      ),
                                    )),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                    //margin: EdgeInsets.only(left: 20),
                                    alignment: Alignment.center,
                                    //height: MediaQuery.of(context).size.width * 0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          if (temp == '') {
                                            _showErrorDialog('Temp ob');
                                          } else if (tm! >= 100) {
                                            _showErrorDialog('Temp elev');
                                          } else {
                                            Navigator.of(context).pop();
                                            _submit();
                                          }
                                        },
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              width: 5.0,
                                              color: HexColor('EA6012')),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        ),
                                        child: Text(
                                          'Yes',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: HexColor('EA6012')),
                                        ),
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ))));
        });
  }

  @override
  void initState() {
    _viewWorkDay();
    getContract(1);
    getSWData();
    _checkGps();
    /*_getLocation().then((position) {
      userLocation = position;
    });*/
    super.initState();
    setState(() {
      start_time = DateTime.parse(DateTime.now().toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse((DateTime.now().toString())));
      hourClock = DateTime.parse((DateTime.now().toString()));
    });
    getTodo(1);
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
                  'Clock in',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 38,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          if (!isData) ...[
            Container(
              margin: EdgeInsets.only(top: 100),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          ],
          if (isData) ...[
            if (workday_on != null && workday_on!['clock_in_init'] == '') ...[
              Container(
                  margin: EdgeInsets.only(left: 30, right: 30, bottom: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      l10n.clockin_1,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  )),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 30),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.10,
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 5, top: 5),
                              child: Text(
                                'Entry',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            )
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              DateFormat("MMMM d yyyy").format(
                                  DateTime.parse(start_time.toString())),
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                            Text(
                              _time!,
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(left: 30),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(Icons.calendar_today),
                                color: Colors.white,
                                onPressed: () async {
                                  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2100));
                                  print(pickedDate);
                                  setState(() {
                                    start_time = pickedDate;
                                  });
                                  /*  DatePicker.showDatePicker(context,
                                      showTitleActions: true,
                                      onConfirm: (start) {
                                    print('confirm start $start');
                                    start_time = start;

                                    setState(() {});
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);

                                  setState(() {});*/
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(Icons.timer),
                                color: Colors.white,
                                onPressed: () async {
                                  TimeOfDay? picketTime = await showTimePicker(
                                    initialTime: TimeOfDay.now(),
                                    context: context,
                                  );

                                  if (picketTime != null) {
                                    DateTime selectedDateTime = DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      picketTime.hour,
                                      picketTime.minute,
                                    );
                                    String formattedTime =
                                        DateFormat('hh:mm aa')
                                            .format(selectedDateTime);
                                    _time = formattedTime;
                                    setState(() {
                                      hourClock = selectedDateTime;
                                    }); // You can use the selectedDateTime as needed.
                                  }

                                  /* DatePicker.showTimePicker(context,
                                      showTitleActions: true,
                                      onConfirm: (time) {
                                    print('confirm $time');
                                    hourClock = time;
                                    String formattedTime =
                                        DateFormat('hh:mm aa').format(time);
                                    _time = formattedTime;
                                    setState(() {});
                                  },
                                      currentTime: DateTime.now(),
                                      locale: LocaleType.en);
                                  setState(() {});*/
                                },
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
            ],
            if (workday_on != null && workday_on!['clock_in_init'] != '') ...[
              if (workday_on != null &&
                  workday_on!['has_clockin'].toString() == 'true') ...[
                Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        l10n.clockin_2,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ))
              ],
              if (workday_on != null &&
                  workday_on!['has_clockin'].toString() == 'false') ...[
                Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        l10n.clockin_3,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ))
              ],
            ],
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            if (workday_on != null && workday_on!['clock_in_init'] == '') ...[
              Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 30),
                //width: MediaQuery.of(context).size.width * 0.70,
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(HexColor('EA6012')),
                        ),
                        onPressed: () async {
                          if (contractDetail!['contract_temp'].toString() ==
                              'true') {
                            _showInputDialog1(l10n.clockin_4);
                          } else {
                            _submit();
                          }
                        },
                        child: Text(
                          l10n.clockin_5,
                          style: TextStyle(fontSize: 20, color: Colors.white),
                        ),
                      ),
              )
            ],
            if (workday_on != null && workday_on!['clock_in_init'] != '') ...[
              if (workday_on != null &&
                  workday_on!['has_clockin'].toString() == 'true') ...[
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(HexColor('EA6012')),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListClockIn(
                                        user: user,
                                        workday: workday_on!['workday_id'],
                                        contract: widget.contract,
                                        work: Workday.fromJson(workday_on!),
                                        wk: workday_on,
                                      )),
                            );
                          },
                          child: Text(
                            l10n.clockin_6,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white),
                          ),
                        ),
                )
              ],
              if (workday_on != null &&
                  workday_on!['has_clockin'].toString() == 'false') ...[
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(HexColor('EA6012')),
                          ),
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ListClockIn(
                                        user: user,
                                        workday: workday_on!['workday_id'],
                                        contract: widget.contract,
                                        work: Workday.fromJson(workday_on!),
                                        wk: workday_on,
                                      )),
                            );
                          },
                          child: Text(
                            l10n.clockin_6,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : TextButton(
                          onPressed: () async {
                            if (contractDetail!['contract_temp'].toString() ==
                                'true') {
                              _showInputDialog1(l10n.clockin_4);
                            } else {
                              _submit();
                            }
                          },
                          child: Text(
                            l10n.clockin_7,
                            style: TextStyle(
                                fontSize: 20, color: HexColor('EA6012')),
                          ),
                        ),
                ),
              ],
            ]
          ],
        ],
      ),
    )));
  }
}
