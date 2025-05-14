import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/config.dart';

import '../../model/user.dart';
import '../../model/workday.dart';

import '../../providers/auth.dart';
import '../../providers/workday.dart';
import '../widgets.dart';
import '../global.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'cam_scan.dart';
import 'confirm.dart';
import 'init.dart';
import 'list.dart';
import 'make_in.dart';

class UpdateInitUIn extends StatefulWidget {
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;
  final Workday? work;
  Map<String, dynamic>? wk;
  String? dif;
  UpdateInitUIn(
      {required this.user,
      required this.workday,
      this.contract,
      this.work,
      this.wk,
      this.dif});

  @override
  _UpdateInitUInState createState() =>
      _UpdateInitUInState(user!, workday!, contract!, work!, wk!, dif!);
}

class _UpdateInitUInState extends State<UpdateInitUIn> {
  Map<String, dynamic> contract;
  User user;
  int workday;
  Workday work;
  Map<String, dynamic> wk;
  String dif;

  _UpdateInitUInState(
      this.user, this.workday, this.contract, this.work, this.wk, this.dif);
  final GlobalKey<FormState> _formKey = GlobalKey();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool isLoading = false;
  Map<String, dynamic>? data;
  Map<String, dynamic>? workday_on;
  bool? isData = false;

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
  User? _user;

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
    print('rrpp workday on');
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
          .addWorkday(
              contract,
              geo,
              temp,
              contractDetail!['contract_temp'].toString(),
              start_time,
              hourClock,
              true)
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
          _showErrorDialog('Check in already');
        } else {
          _showErrorDialog('Error');
        }
      });
    } catch (error) {}
  }


  Future<String> _makeClockin() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Provider.of<WorkDay>(context, listen: false)
          .addClockIn(
              _user!.id,
              hourClock,
              '12.92828 45.340480',
              workday_on,
              temp,
              contractDetail!['contract_temp'].toString());

      setState(() {
        isLoading = false;
      });

      if (response == '201') {
        print('cloqueado con exito');
        return '1';
      } else {
        print('error en clock');
        return '0';
      }
    } catch (error) {
      print('Error en makeClockin: $error');
      return '0';
    }
  }

  Future<void> _editWorkdayDef() async {
    String contract = widget.contract!['contract_id'].toString();
    setState(() {
      isLoading = true;
    });

    try {
      final response = await Provider.of<WorkDay>(context, listen: false)
          .editWorkdayIn(
        workday,
        start_time,
        hourClock,
      );

      setState(() {
        isLoading = false;
      });

      if (response['status'] == '200') {
        final clockInResult = await _makeClockin();
        
        if (clockInResult == '1') {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clock-in completed successfully!'),
              backgroundColor: HexColor('EA6012'),
              duration: Duration(seconds: 2),
            ),
          );

          // Esperar a que se muestre el mensaje antes de navegar
          await Future.delayed(Duration(seconds: 2));

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
        } else {
          _showErrorDialog('Error al realizar el clock-in');
        }
      } else if (response['status'] == '400') {
        _showErrorDialog('Check in already');
      } else {
        _showErrorDialog('Error');
      }
    } catch (error) {
      print('Error en editWorkdayDef: $error');
      _showErrorDialog('Error inesperado');
    }
  }

  
  void _viewUser() {
    Provider.of<Auth>(context, listen: false).fetchUser().then((value) {
      print('response user');
      print(value);
      setState(() {
        _user = value['data'];
      });
    });
  }

  @override
  void initState() {
    getWorkdayOn(1);
    _viewWorkDay();
    getContract(1);
    getSWData();
    _viewUser();
    // _checkGps();
    _getLocation().then((position) {
      userLocation = position;
    });
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
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Update the default clock-in time and register',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.06,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
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
                            l10n.wr_4,
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
                                  showTitleActions: true, onConfirm: (start) {
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
                              /*  DatePicker.showTimePicker(context,
                                  showTitleActions: true, onConfirm: (time) {
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
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(right: 30, top: 100),
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
                      _editWorkdayDef();
                    },
                    child: const Text(
                      'Modify',
                      style: TextStyle(fontSize: 20, color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    )));
  }
}
