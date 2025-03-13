import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
//import 'package:app_settings/app_settings.dart';
import 'package:worker/widgets/clock-out/self_clock_ext.dart';
import '../../local/database_creator.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:worker/widgets/clock-out/detail_ext_sc.dart';
import 'dart:convert';
import '../../model/user.dart';
import '../../model/workday.dart';
import '../../providers/workday.dart';
import '../clock-in/detail.dart';
import '../global.dart';
import '../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'list.dart';

class InitClockOutAut extends StatefulWidget {
  User? user;
  Workday? work;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? wk;

  InitClockOutAut({super.key, this.user, this.work, this.contract, this.wk});

  @override
  _InitClockOutAutState createState() =>
      // ignore: no_logic_in_create_state
      _InitClockOutAutState(user!, work!, contract!, wk!);
}

class _InitClockOutAutState extends State<InitClockOutAut> {
  User? user;
  Workday? work;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? wk;

  _InitClockOutAutState(this.user, this.work, this.contract, this.wk);
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isLoading = false;
  Geolocator? geolocator = Geolocator();
  String? qrCodeResult = "Not Yet Scanned";
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Position? userLocation;
  String? geo;
  Map<String, dynamic>? workday_on;
  String? temp = '';
  int? tm;
  Workday? _wd;
  bool? isData = false;
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
      isData = true;
    });
    print(workday_on);
    return workday_on;
  }

  void _viewWorkDay() {
    Provider.of<WorkDay>(context, listen: false).fetchWorkDay().then((value) {
      setState(() {
        _wd = value;
      });
      getWorkdayOn(1);
    });
  }

  Future<void> _submitClockIn() async {
    setState(() {
      isLoading = true;
    });
    _getLocation().then((position) {
      userLocation = position;
    });
    if (userLocation != null) {
      geo = userLocation!.latitude.toString() +
          ' ' +
          userLocation!.longitude.toString();
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
        if (response == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SelfClockOut(
                      user: user,
                      workday: widget.wk!['workday_id'],
                      contract: widget.contract,
                      work: widget.work,
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

  void _showInputTempClockin(String title) {
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
                                  'Temperatura',
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
                            child: Text('¿Seguro que deseas iniciar?',
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
                                    child: isLoading
                                        ? Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Container(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 1.0),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.35,
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                if (temp == '') {
                                                  _showErrorDialog(
                                                      'La temperatura es obligatoria para el ingreso');
                                                } else if (tm! >= 100) {
                                                  _showErrorDialog(
                                                      'La temperatura del worker es muy elevada');
                                                } else {
                                                  Navigator.of(context).pop();
                                                  _submitClockIn();
                                                }
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                    width: 5.0,
                                                    color: HexColor('EA6012')),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0)),
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
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ))));
        });
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

  void _showInputSelf(String title) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        //isScrollControlled: true,
        context: context,
        builder: (ctx) {
          return Scaffold(
              body: Column(
            //mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 30,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text(title,
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02),
              Container(
                margin: EdgeInsets.only(left: 10, top: 5),
                child: Text(
                  'Do you want to become an automatic clockout?',
                  style: TextStyle(
                    color: HexColor('EA6012'),
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              SizedBox(height: MediaQuery.of(context).size.height * 0.08),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                        //margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.0),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: OutlinedButton(
                            //onPressed: () => select("English"),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _submit(false);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 5.0, color: HexColor('EA6012')),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
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
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.0),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: OutlinedButton(
                            onPressed: () async {
                              /* if (temp == '') {
                                _showErrorDialog('Temp ob');
                              } else if (tm! >= 100) {
                                _showErrorDialog('Temp elev');
                              } else {*/
                              Navigator.of(context).pop();
                              _submit(true);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 5.0, color: HexColor('EA6012')),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
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
                height: 15,
              ),
            ],
          ));
        });
  }

  Future<void> _submit(bool auto) async {
    setState(() {
      isLoading = true;
    });
    int wk = widget.wk!['workday_id'];
    print(wk);
    if (userLocation != null) {
      geo = '${userLocation!.latitude} ${userLocation!.longitude}';
    } else {
      geo = '--- ---';
    }
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkday(wk, geo, start_time, hourClock, auto)
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
                    workday: widget.wk!['workday_id'],
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
              widget.user!.id, widget.wk, widget.wk!['clock_out_init'], geo)
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
                    workday: widget.wk!['workday_id'],
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

  void _showInputDialog(String title) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        context: context,
        builder: (ctx) {
          return Column(
            mainAxisSize: MainAxisSize.min,
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
                height: 10,
              ),
              Image.asset(
                'assets/alert.png',
                width: 90,
              ),
              SizedBox(
                height: 15,
              ),
              Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Text('Error',
                    style: TextStyle(
                      // fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center),
              ),
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                        //margin: EdgeInsets.only(left: 20),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 1.0),
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: OutlinedButton(
                            //onPressed: () => select("English"),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  width: 5.0, color: HexColor('EA6012')),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0)),
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
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : Container(
                                padding: EdgeInsets.symmetric(vertical: 1.0),
                                width: MediaQuery.of(context).size.width * 0.35,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    Navigator.of(context).pop();

                                    String codeSanner =
                                        (await BarcodeScanner.scan())
                                            as String; //barcode scnner
                                    setState(() {
                                      qrCodeResult = codeSanner;
                                    });
                                    print(qrCodeResult);
                                    if (userLocation != null) {
                                      bool? scanResult = await scanQRWorkerE(
                                          qrCodeResult!,
                                          userLocation!.latitude.toString(),
                                          userLocation!.longitude.toString());
                                    } else {
                                      bool? scanResult = await scanQRWorkerE(
                                          qrCodeResult!, '---', '---');
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                        width: 5.0, color: HexColor('EA6012')),
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
              SizedBox(
                height: 20,
              ),
            ],
          );
        });
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showErrorDialogCII(String message, User worker) {
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
            child: Text(
              'Ok',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text(
              'Hacer Clock in',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();

              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailClockIn(
                          user: widget.user,
                          // workday: this.widget.work,
                          lat: '----',
                          long: '----',
                        )),
              );
            },
          )
        ],
      ),
    );
  }

  Future<bool?> scanQRWorkerE(
      String identification, String lat, String long) async {
    String contract = widget.contract!['contract_id'].toString();
    String token = await getToken();
    print(contract);
    print('llego aqui');
    setState(() {});

    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/get-registered-user/$identification/$contract/out'),
        headers: {"Authorization": "Token $token"});
    setState(() {});
    var resBody = json.decode(response.body);
    print(response.statusCode);

    if (response.statusCode == 200 &&
        resBody['first_name'] != null &&
        resBody['detail'] == null) {
      print('dio bienpara escanear');
      print(resBody);
      User worker = new User.fromJson(resBody);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailExtSCClockOut(
                user: resBody,
                workday: widget.work,
                lat: lat,
                long: long,
                contract: this.widget.contract,
                wk: this.widget.wk)),
      );
    }
    if (response.statusCode == 200 &&
        resBody['detail'] == 'The worker has not clocked in') {
      print('dio bien para escanear sin clock in');
      print(resBody);
      User worker = User.fromJson(resBody);
      _showErrorDialogCII('Error', worker);
    }

    if (response.statusCode == 200 &&
        resBody['detail'] == 'The worker has already clocked out') {
      _showErrorDialog('Error');
    }

    if (response.statusCode == 200 &&
        resBody['detail'] == 'worker not belongs to a project') {
      _showErrorDialog('Error');
    }
  }

  @override
  void initState() {
    super.initState();
    _viewWorkDay();
    setState(() {
      start_time = DateTime.parse(DateTime.now().toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse((DateTime.now().toString())));
      hourClock = DateTime.parse((DateTime.now().toString()));
    });
    _getLocation().then((position) {
      userLocation = position;
    });
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
              child: const Align(
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
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          if (!isData!) ...[
            Container(
              margin: EdgeInsets.only(top: 100),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          ],
          if (workday_on != null && workday_on!['clock_out_init'] == '') ...[
            Container(
                margin: EdgeInsets.only(left: 30, right: 30, bottom: 10),
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
                              l10n.wr_5,
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
                            DateFormat("MMMM d yyyy")
                                .format(DateTime.parse(start_time.toString())),
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                          Text(
                            _time!,
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                                /* DatePicker.showDatePicker(context,
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
                                  String formattedTime = DateFormat('hh:mm aa')
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
                          ),
                          Container(
                              //margin: EdgeInsets.only(left: 20),
                              alignment: Alignment.center,
                              //height: MediaQuery.of(context).size.width * 0.1,
                              width: MediaQuery.of(context).size.width * 0.50,
                              child: isLoading
                                  ? Center(
                                      child: CircularProgressIndicator(),
                                    )
                                  : Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 1.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.35,
                                      child: OutlinedButton(
                                        onPressed: () async {
                                          _submit(false);
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
                                          'Submit',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 17,
                                              color: HexColor('EA6012')),
                                        ),
                                      ),
                                    )),
                        ],
                      )),
                )
              ],
            ),
          ],
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.20,
          ),
          Container(
              //margin: EdgeInsets.only(left: 20),
              alignment: Alignment.center,
              //height: MediaQuery.of(context).size.width * 0.1,
              width: MediaQuery.of(context).size.width * 0.50,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container(
                      padding: EdgeInsets.symmetric(vertical: 1.0),
                      width: MediaQuery.of(context).size.width * 0.35,
                      child: OutlinedButton(
                        onPressed: () async {
                          _submit(false);
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(width: 5.0, color: Colors.white),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0)),
                        ),
                        child: Text(
                          'Submit',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              color: Colors.white),
                        ),
                      ),
                    )),
        ],
      ),
    )));
  }
}
