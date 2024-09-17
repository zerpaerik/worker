import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/certification.dart';
import 'package:worker/model/config.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
//import 'package:app_settings/app_settings.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../local/service.dart';
import '../../providers/workday.dart';

import '../../model/user.dart';
import '../../model/workday.dart';
import '../global.dart';
import 'cam_scan.dart';
import 'confirm.dart';
import 'detail.dart';
import 'update_init_default.dart';

// ignore: must_be_immutable
class ListClockIn extends StatefulWidget {
  static const routeName = '/my-clockin';
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;
  final Workday? work;
  Map<String, dynamic>? wk;

  ListClockIn({this.user, this.workday, this.contract, this.work, this.wk});

  @override
  _ListClockInState createState() =>
      _ListClockInState(user!, workday!, contract!, work!, wk!);
}

class _ListClockInState extends State<ListClockIn> {
  User user;
  int workday;
  Map<String, dynamic> contract;
  Workday work;
  Map<String, dynamic> wk;
  List _selectWorkers = [];
  List _selectWorkersInfo = [];

  Geolocator geolocator = Geolocator();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Position? userLocation;
  _ListClockInState(this.user, this.workday, this.contract, this.work, this.wk);
  // ignore: unused_field
  int? _selectedIndex = 3;
  bool? loading = false;
  String? verified;
  bool? scanning = false;
  String? qrCodeResult = "Not Yet Scanned";
  bool? finish = false;
  Workday? _wd;
  TextEditingController? tc;

  var rows = [];
  List? results = [];
  String? query = '';

  List data = [];
  List datae = [];

  List data1 = [];

  Certification? crt;
  String? isData = '';
  String? isDataE = '';

  String isData1 = '';
  bool isLoading = false;
  Config? config;
  Map<String, dynamic>? dataContract;
  String? geo;
  Map<String, dynamic>? workday_on;
  String? barcodeScanRes;

  String? dat;
  int? totalw;
  bool? exitproject = false;

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
  String? _time1 = "S/H";
  String _time2 = "S/H";
  String _time3 = "S/H";
  String _time4 = "S/H";
  String _time5 = "S/H";
  String _time6 = "S/H";
  String _time7 = "S/H";
  String _time8 = "S/H";
  String _time9 = "S/H";
  DateTime? hourClock;
  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9; // fin return
  Map<String, dynamic>? contractCurrent;
  String isContract = "0";

  getWorkdayOn(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      workday_on = todo;
    });

    print('response workday_on');
    print(workday_on);
    return workday_on;
  }

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<String?> getHourClock() async {
    SharedPreferences hourClock = await SharedPreferences.getInstance();
    String? stringValue = hourClock.getString('stringValue');
    return stringValue;
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
                height: 30,
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
                                  onPressed: () {
                                    exitProyect(_selectWorkers);
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

  void _showviewExitProject() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/aceptar-1.png',
                width: 80,
                color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Text('Worker removed'))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
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

  void _showquitabstense(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Card(
                elevation: 3,
                color: HexColor('F7F7F7'),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        /* DatePicker.showTimePicker(context,
                            showTitleActions: true, onConfirm: (time) {
                          print('confirm $time');
                          hourClock = time;
                          String formattedTime =
                              DateFormat('hh:mm:aa').format(time);
                          _time = formattedTime;
                          setState(() {});
                        }, currentTime: DateTime.now(), locale: LocaleType.en);
                        setState(() {});*/
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Row(
                                    children: <Widget>[
                                      Icon(
                                        Icons.access_time,
                                        size: 17.0,
                                        color: HexColor('EA6012'),
                                      ),
                                      Text(
                                        " $_time",
                                        style: TextStyle(
                                            color: HexColor('EA6012'),
                                            fontSize: 17.0),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            Text(
                              "Cambiar Hora Clock-in",
                              style: TextStyle(
                                  color: HexColor('EA6012'), fontSize: 17.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
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

  void _onWorkerSelected(
      bool selected, worker_id, worker_name, worker_lastname, worker_btnid) {
    if (selected == true) {
      setState(() {
        _selectWorkers.add(worker_id);
        _selectWorkersInfo
            .add(worker_name + ' ' + worker_lastname + ' ' + worker_btnid);
        print(_selectWorkers);
        print(_selectWorkersInfo);
      });
    } else {
      setState(() {
        _selectWorkers.remove(worker_id);
        _selectWorkersInfo
            .remove(worker_name + ' ' + worker_lastname + ' ' + worker_btnid);
        print(_selectWorkers);
        print(_selectWorkersInfo);
      });
    }
  }

  void _showErrorDialogADD(String message, int worker) {
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
          ),
          TextButton(
              child: Text('Enviar oferta.'),
              onPressed: () {
                Navigator.of(ctx).pop();
                _submitOffer(worker);
              })
        ],
      ),
    );
  }

  void _showConfirmEnd() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Estás Intentando Finalizar el Proceso'),
        content:
            Text('¿Estás seguro que deseas finalizar el proceso de clock in?'),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          TextButton(
            child: Text('No',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
          TextButton(
            child: Text(
              'Si',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _submit();
            },
          )
        ],
      ),
    );
  }

  Future<bool?> scanQRWorker(
      String identification, String lat, String long) async {
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();

    setState(() {
      scanning = true;
    });
    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/get-registered-user/$identification/$contract/in'),
        headers: {"Authorization": "Token $token"});
    setState(() {
      scanning = false;
    });
    print(response.statusCode);
    print(response.body);

    var resBody = json.decode(response.body);

    if (response.statusCode == 200 && resBody['first_name'] != null) {
      print('dio 200 scan list');
      User _user = User.fromJson(resBody);

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailClockIn(
                user: _user,
                workday: widget.workday,
                lat: lat,
                long: long,
                contract: widget.contract,
                wk: workday_on,
                us: widget.user)),
      );
    } else {
      print('dio error');
      //The worker has already clocked-in
      String error = resBody['detail'];
      if (error == 'worker not belongs to a project') {
        _showErrorDialogADD(
            'worker not belongs to a project', resBody['worker']);
      }
      if (error == 'The worker has already clocked-in') {
        _showErrorDialog('El trabajador ya hizo clock in en la jornada.');
      }
      /*else {
        _showErrorDialog('Verifique la información.');
      }*/
    }
  }

  Future<dynamic> getSWData() async {
    String? token = await getToken();
    int? wd = widget.workday;
    setState(() {
      loading = true;
    });

    // ignore: use_build_context_synchronously
    Provider.of<WorkDay>(context, listen: false)
        .listClockIn(wd)
        .then((response) {
      if (response['status'] == '200') {
        setState(() {
          data = response['data'];
          if (data.isNotEmpty) {
            isData = 'Y';
          } else {
            isData = 'N';
          }
        });
      }
    });
  }

  Future<dynamic> fetchWorkday() async {
    String? token = await getToken();

    Provider.of<WorkDay>(context, listen: false)
        .fetchWorkDay()
        .then((response) {
      print('response workday');
      print(response);
    });
  }

  Future<dynamic> getSWDataE() async {
    int? wd = widget.workday;
    setState(() {
      loading = true;
    });

    Provider.of<WorkDay>(context, listen: false)
        .listClockInE(wd)
        .then((response) {
      if (response['status'] == '200') {
        setState(() {
          datae = response['data'];
          if (datae.isNotEmpty) {
            isDataE = 'Y';
          } else {
            isDataE = 'N';
          }
        });
      }
    });
  }

  Future<String?> getSWDataNO() async {
    int? wd = widget.workday;
    setState(() {
      loading = true;
    });

    Provider.of<WorkDay>(context, listen: false)
        .listClockInA(wd)
        .then((response) {
      if (response['status'] == '200') {
        setState(() {
          data1 = response['data'];
          print(data1);
          if (data1.isNotEmpty) {
            isData1 = 'Y';
          } else {
            isData1 = 'N';
          }
        });
      }
    });
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

  void _showviewRequest() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              child: Image.asset(
                'assets/aceptar-1.png',
                width: 110,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                alignment: Alignment.center,
                child: Text('¡El Proceso se ha Finalizado con Exito!'))
          ],
        ),
        titleTextStyle: TextStyle(
          color: HexColor('373737'),
          fontFamily: 'OpenSansRegular',
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
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
          .endClockIn(widget.workday, geo, widget.user!.id)
          .then((response) {
        setState(() {
          isLoading = false;
          finish = true;
        });
        print(finish);
        if (response == '200') {
          _showviewRequest();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DashboardHome(
                      noti: false,
                      data: {},
                    )),
          );
        } else {
          _showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
  }

  Future<void> _editworkdayin() async {
    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayIn(widget.workday, start_time, hourClock)
          .then((response) {
        setState(() {
          isLoading = false;
          finish = true;
        });
        print(finish);
        if (response == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListClockIn(
                      user: user,
                      workday: widget.workday,
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
  }

  Future<void> _submitOffer(int worker) async {
    String? token = await getToken();
    String contract = widget.contract!['id'].toString();

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/check-worker-profile/$worker/$contract/'),
        headers: {"Authorization": "Token $token"});

    var response = json.decode(res.body);
    print(res.body);
    if (response['code'] == 0) {
      _showErrorDialog(
          'El trabajador no cumple los requerimientos minimos para aplicar a la oferta.');
    } else {
      _showErrorDialog(
          'Se envío la oferta al trabajador, debe aceptarla para poder hacer clock in.');
    }
    print(response);
  }

  Future<dynamic> exitProyect(workers) async {
    List<Map<String, dynamic>> dataS;
    dataS = [];

    workers.asMap().forEach((i, value) {
      dataS.add({"id": value, "is_finalized": true});
    });

    String? token = await getToken();
    setState(() {
      exitproject = true;
    });
    try {
      final response = await http.patch(
          Uri.parse(ApiWebServer.server_name +
              '/api/v-1/contract/workers-accepted/finalize'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });

      print(response.statusCode);
      setState(() {
        exitproject = false;
      });
      if (response.statusCode == 200) {
        _showviewExitProject();
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ListClockIn(
                    user: user,
                    workday: widget.workday,
                    contract: widget.contract,
                    work: widget.work,
                    wk: widget.wk,
                  )),
        );
      } else {
        _showErrorDialog('Error');
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void _showEditHour(String title, String inact) {
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
                          Container(
                            margin:
                                EdgeInsets.only(left: 10, right: 10, top: 10),
                            child: Text('Inactividad: ' + inact.substring(0, 7),
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
                            children: [
                              Expanded(
                                  flex: 2,
                                  child: Container(
                                      //color: HexColor('009444'),
                                      alignment: Alignment.topLeft,
                                      margin: EdgeInsets.only(left: 30),
                                      //height: MediaQuery.of(context).size.width * 0.1,
                                      width: MediaQuery.of(context).size.width *
                                          0.10,
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            margin: EdgeInsets.only(
                                                left: 5, top: 5),
                                            child: Text(
                                              'Entry',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  color: HexColor('EA6012')),
                                            ),
                                          )
                                        ],
                                      ))),
                              Expanded(
                                flex: 2,
                                child: Container(
                                    //color: HexColor('009444'),
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(left: 10),
                                    //height: MediaQuery.of(context).size.width * 0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.50,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          DateFormat("MMMM d yyyy").format(
                                              DateTime.parse(
                                                  start_time.toString())),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: HexColor('EA6012')),
                                        ),
                                        Text(
                                          _time!,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: HexColor('EA6012'),
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
                                    width: MediaQuery.of(context).size.width *
                                        0.40,
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(
                                          width: 35,
                                          child: IconButton(
                                            icon: Icon(Icons.calendar_today),
                                            color: HexColor('EA6012'),
                                            onPressed: () {
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
                                            color: HexColor('EA6012'),
                                            onPressed: () {
                                              /* DatePicker.showTimePicker(context,
                                                  showTitleActions: true,
                                                  onConfirm: (time) {
                                                print('confirm $time');
                                                hourClock = time;
                                                String formattedTime =
                                                    DateFormat('hh:mm aa')
                                                        .format(time);
                                                setState(() {
                                                  _time = formattedTime;
                                                });
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
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text('',
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
                                              onPressed: () async {},
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

  Future<dynamic> _viewContract() async {
    String? token = await getToken();

    final response = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-2/contract/current'),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token" + " " + "$token"
        });
    Map<String, dynamic> resBody = json.decode(response.body);

    setState(() {
      contractCurrent = resBody;
      isContract = response.statusCode.toString();
    });

    print('iscon');
    print(isContract);
  }

  @override
  void initState() {
    print('widget contract');
    print(widget.contract);
    _viewContract();
    getWorkdayOn(1);
    super.initState();
    fetchWorkday();
    getSWData();
    getSWDataE();
    getSWDataNO();
    setState(() {
      start_time = DateTime.parse(DateTime.now().toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse((DateTime.now().toString())));
      hourClock = DateTime.parse((DateTime.now().toString()));
    });
    getTodo(1);
    print(workday_on!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    totalw = data.length + datae.length;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: Column(
          // Column
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: HexColor('EA6012'),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DashboardHome(
                                  noti: false,
                                  data: {},
                                )),
                      );
                    }),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    alignment: Alignment.topLeft,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/in.png',
                            color: Colors.black,
                            width: 40,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Clock-in',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (workday_on != null) ...[
                  if (workday_on!['clock_in_fin'] == '') ...[
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(right: 20, top: 10),
                        alignment: Alignment.topRight,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.05,
                        child: Container(
                          child: FloatingActionButton(
                            child: Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 40,
                            ),
                            backgroundColor: HexColor('EA6012'),
                            onPressed: () async {
                              await getWorkdayOn(1);

                              // print(workday_on['ult_clock'].toString());
                              //print(hourClockT);
                              DateTime now = DateTime.now();
                              print(workday_on!['ult_clock']);
                              DateTime init = workday_on!['ult_clock'] != ''
                                  ? DateTime.parse(
                                      workday_on!['ult_clock'].toString())
                                  : DateTime.now();
                              //  print(now);
                              //print(init);
                              // print(now.difference(init).toString());
                              if (now.difference(init) > Duration(minutes: 1)) {
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateInit(
                                            user: user,
                                            workday: widget.workday,
                                            work: widget.work,
                                            contract: widget.contract,
                                            wk: workday_on,
                                            dif:
                                                now.difference(init).toString(),
                                          )),
                                );
                              } else {
                                // ignore: use_build_context_synchronously
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRSCAN(
                                            user: user,
                                            workday: widget.workday,
                                            work: widget.work,
                                            contract: widget.contract,
                                            wk: workday_on,
                                            us: widget.user,
                                          )),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    )
                  ]
                ],
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(widget.contract!['contract_name'],
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            if (contractCurrent != null) ...[
              Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(contractCurrent!['contract_owner'].toString(),
                      style: TextStyle(
                        fontSize: 17,
                      )),
                ),
              ),
            ],
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.clockin_10,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(totalw.toString(),
                        style: TextStyle(
                            fontSize: 15,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(l10n.clockin_11,
                        style: TextStyle(
                            fontSize: 15,
                            color: Colors.black,
                            fontWeight: FontWeight.bold)),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                        workday_on != null
                            ? workday_on!['clock_in_init']
                                .toString()
                                .substring(0, 10)
                            : '',
                        style: TextStyle(
                            fontSize: 15,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            if (_selectWorkers.length > 0) ...[
              Container(
                alignment: Alignment.topLeft,
                margin: EdgeInsets.only(
                  left: 15,
                ),
                //  margin: EdgeInsets.only(left: 30),
                //width: MediaQuery.of(context).size.width * 0.70,
                child: ElevatedButton(
                  onPressed: () {
                    _showInputDialog(l10n.remove_project_c);
                    //exitProyect(_selectWorkers);
                  },
                  child: Text(
                    l10n.remove_proyect,
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.white),
                  ),
                ),
              )
            ],
            if (exitproject!) ...[
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20),
                    child: Text(l10n.clockin_19),
                  ),
                  Container(
                    child: Image.asset(
                      'assets/cargando.gif',
                      width: 50,
                    ),
                  )
                ],
              )
            ],
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              color: Colors.white, // Tab Bar color change
              child: TabBar(
                // TabBar
                unselectedLabelColor: Colors.grey,
                labelColor: Colors.black,
                indicatorWeight: 3,
                indicatorColor: HexColor('EA6012'),
                labelStyle:
                    TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                tabs: [
                  Container(
                    child: Tab(
                      text: '${l10n.clockin_12} ${totalw.toString()}',
                    ),
                  ),
                  Tab(
                    text: '${l10n.clockin_13} ${data1.length.toString()}',
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: TabBarView(
                physics: BouncingScrollPhysics(),
                children: <Widget>[
                  isData == ''
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : isData == 'Y'
                          ? SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.02,
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(l10n.clockin_14,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                  Container(
                                      margin: EdgeInsets.all(5),
                                      child: MediaQuery.removePadding(
                                          removeTop: true,
                                          context: context,
                                          child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: data.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.02,
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.25,
                                                            child: Container(
                                                              child: Text(
                                                                'ID#${data[index]['btn_id']}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                          )),
                                                      Expanded(
                                                          flex: 6,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.70,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              2),
                                                                  child: Text(
                                                                    '${data[index]['last_name']} ${data[index]['first_name']}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                              ],
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          ))),
                                  Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(l10n.clockin_15,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      )),
                                  Container(
                                      margin: EdgeInsets.all(5),
                                      child: MediaQuery.removePadding(
                                          removeTop: true,
                                          context: context,
                                          child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: datae.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: <Widget>[
                                                  Row(
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(
                                                          alignment:
                                                              Alignment.topLeft,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.02,
                                                          child: Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.18,
                                                            child: Container(
                                                              child: Text(
                                                                'ID#' +
                                                                    '' +
                                                                    '${datae[index]['btn_id']}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .grey,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        15),
                                                              ),
                                                            ),
                                                          )),
                                                      Expanded(
                                                          flex: 7,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.80,
                                                            child: Row(
                                                              children: <Widget>[
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              2),
                                                                  child: Text(
                                                                    '${datae[index]['last_name']}' +
                                                                        ' ' +
                                                                        '${datae[index]['first_name']}',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                              ],
                                                            ),
                                                          ))
                                                    ],
                                                  ),
                                                ],
                                              );
                                            },
                                          )))
                                ],
                              ),
                            )
                          : Center(
                              child: Text(l10n.clockin_18),
                            ),
                  isData1 == ''
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : isData1 == 'Y'
                          ? _getListNO()
                          : Center(
                              child: Text(l10n.clockin_18),
                            )
                ],
              ),
            ),
            if (workday_on != null) ...[
              if (workday_on!['clock_in_fin'] == '') ...[
                if (config != null) ...[
                  if (config!.role == 'supervisor') ...[
                    Container(
                      alignment: Alignment.topRight,
                      margin: EdgeInsets.only(right: 30, bottom: 15),
                      // margin: EdgeInsets.only(left:15),
                      child: isLoading
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    HexColor('EA6012')),
                              ),
                              onPressed: () async {
                                /*final String currentTimeZone =
                                    await FlutterNativeTimezone
                                        .getLocalTimezone();*/
                                //print(currentTimeZone)
                                print('finalizando clockin');
                                // ignore: unnecessary_null_comparison
                                if (widget.work!.clock_in_end == null) {
                                  // ignore: use_build_context_synchronously
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ConfirmClockIn(
                                              user: widget.user,
                                              workday: widget.workday,
                                              work: widget.work,
                                              contract: widget.contract,
                                              geo: userLocation != null
                                                  ? '${userLocation!.latitude} ${userLocation!.longitude}'
                                                  : '--- ---',
                                            )),
                                  );
                                } else {
                                  _showErrorDialog(
                                      'Ya el Proceso fue Finalizado');
                                }
                              },
                              child: Text(
                                l10n.clockin_16,
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                    )
                  ]
                ]
              ],
              if (workday_on!['clock_in_fin'] != '') ...[
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30, bottom: 15),
                  // margin: EdgeInsets.only(left:15),
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          onPressed: () async {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QRSCAN(
                                        user: user,
                                        workday: widget.workday,
                                        work: widget.work,
                                        contract: widget.contract,
                                        wk: workday_on,
                                      )),
                            );
                            /*  if (!(await Geolocator()
                                .isLocationServiceEnabled())) {
                              _checkGps();
                            } else {
                              String codeSanner =
                                  await BarcodeScanner.scan(); //barcode scnner
                              setState(() {
                                qrCodeResult = codeSanner;
                              });
                              print(qrCodeResult);
                              if (userLocation != null) {
                                bool scanResult = await scanQRWorker(
                                    qrCodeResult,
                                    userLocation.latitude.toString(),
                                    userLocation.longitude.toString());
                              } else {
                                bool scanResult = await scanQRWorker(
                                    qrCodeResult, '---', '---');
                              }
                            }*/
                          },
                          child: Text(
                            l10n.clockin_17,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                )
              ]
            ],
          ],
        ),
      ),
    );
  }

  Widget _getListNO() {
    return Container(
        margin: EdgeInsets.all(5),
        child: MediaQuery.removePadding(
            removeTop: true,
            context: context,
            child: ListView.builder(
              itemCount: data1.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                    onTap: () {
                      print('sacarlo de contrato');
                    },
                    child: SizedBox(
                      height: 20,
                      child: Row(
                        children: <Widget>[
                          Container(
                            //margin: EdgeInsets.only(left: 10),
                            child: Checkbox(
                              activeColor: HexColor('EA6012'),
                              value: _selectWorkers
                                  .contains(data1[index]['worker_accepted_id']),
                              onChanged: (bool? selected) {
                                _onWorkerSelected(
                                  selected!,
                                  data1[index]['worker_accepted_id'],
                                  data1[index]['first_name'],
                                  data1[index]['last_name'],
                                  data1[index]['btn_id'],
                                );
                              },
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 5),
                            child: Text(
                              'ID# ${data1[index]['btn_id']}',
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            child: Text(
                              '${data1[index]['last_name']} ${data1[index]['first_name']}',
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            )));
  }
}
