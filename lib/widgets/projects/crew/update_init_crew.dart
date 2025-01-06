// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';

import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:worker/model/config.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../local/database_creator.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../global.dart';
import '../../../providers/crew.dart';
import 'cam_scan.dart';

class UpdateInitCrew extends StatefulWidget {
  Map<String, dynamic>? contract;
  int? workday;
  int? typeC;

  UpdateInitCrew({this.contract, this.workday, this.typeC});

  @override
  _UpdateInitCrewState createState() =>
      _UpdateInitCrewState(contract, workday, typeC);
}

class _UpdateInitCrewState extends State<UpdateInitCrew> {
  Map<String, dynamic>? contract;
  int? typeC;
  int? workday;
  _UpdateInitCrewState(this.contract, this.workday, this.typeC);

  Geolocator geolocator = Geolocator();

  Position? userLocation;
  String? geo;
  Map<String, dynamic>? crewCurrent;
  bool isLoading = false;
  List shifts = [];
  List categorys = [];

  var selectedValue;
  var selectedValue1;
  Config? config;

  int type = 0;
  List dataCategory = [];
  String cate = "";
  var selectedValuec;
  String? namec;
  int? category;
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
  DateTime? end_time;

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
  DateTime? hourClock9;

// fin return
  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getShifts() async {
    String token = await getToken();
    int locations = widget.contract!['id'];
    setState(() {});
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/project/location/$locations/shift'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('es shifts');
    print(resBody);

    setState(() {
      shifts = resBody;
      if (shifts.isNotEmpty) {
        selectedValue = shifts[0];
        type = shifts[0]['id'];
      }
    });
  }

  Future<dynamic> getCategory() async {
    String token = await getToken();
    int project = widget.contract!['project_id'];
    setState(() {});
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/project/$project/category'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('es categorys');
    print(resBody);

    setState(() {
      categorys = resBody;
      if (categorys.isNotEmpty) {
        selectedValue1 = categorys[0];
        category = categorys[0]['id'];
      }
    });
  }

  Future<dynamic> submit() async {
    print('llego a pv');

    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<CrewProvider>(context, listen: false)
          .editCrewIn(crewCurrent!['id'], _time, hourClock, widget.typeC)
          .then((response) async {
        print('response edit crew in');
        print(response);
        await getCrew();
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QRSCANCREW(
                      workday: widget.workday,
                      crew: crewCurrent,
                      contract: widget.contract,
                    )),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QRSCANCREW(
                      workday: widget.workday,
                      crew: crewCurrent,
                      contract: widget.contract,
                    )),
          );
        }
      });
    } catch (error) {}
  }

  Future<String> getCrew() async {
    String token = await getToken();
    setState(() {});
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/crew/current'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));

    print('es crew');
    print(resBody);

    setState(() {
      crewCurrent = resBody;
    });

    return "Sucess";
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
    print('widget type');
    print(widget.typeC);

    getTodo(1);
    getCategory();
    getCrew();
    getShifts();
    setState(() {
      start_time = DateTime.parse(DateTime.now().toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse((DateTime.now().toString())));
      hourClock = DateTime.parse((DateTime.now().toString()));
      end_time = DateTime.parse(DateTime.now().toString());

      hourClock1 = DateTime.parse((DateTime.now().toString()));
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
      width: double.infinity,
      /*decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
            HexColor('FE7E1F'),
            HexColor('F57E07'),
            HexColor('F8AF04'),
            HexColor('F5AE07'),
            HexColor('FD821E'),
          ])),*/
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
                  margin: EdgeInsets.only(left: 10),
                  alignment: Alignment.topLeft,
                  //height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: HexColor('EA6012'),
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
                  margin: EdgeInsets.only(right: 10),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        color: HexColor('EA6012'),
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
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/002-data.png',
                  color: HexColor('EA6012'),
                  width: 60,
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  'Update default time due to inactivity',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: HexColor('EA6012')),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.03,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.offer_location + ': ',
                  style: TextStyle(
                      //fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: HexColor('EA6012')),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.contract!['name'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                      color: HexColor('EA6012')),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.08,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                    //color: HexColor('009444'),
                    alignment: Alignment.topLeft,
                    margin: EdgeInsets.only(left: 20),
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.10,
                    child: Row(
                      children: <Widget>[
                        Image.asset(
                          'assets/entrada.png',
                          width: 40,
                        ),
                        if (widget.typeC == 1) ...[
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              l10n.wr_4,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ],
                        if (widget.typeC == 2) ...[
                          Container(
                            margin: EdgeInsets.only(left: 5, top: 5),
                            child: Text(
                              l10n.wr_5,
                              style: TextStyle(fontSize: 16),
                            ),
                          )
                        ]
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
                          style: TextStyle(fontSize: 16),
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
                            color: HexColor('EA6012'),
                            onPressed: () {
                              setState(() {});
                            },
                          ),
                        ),
                        SizedBox(
                          width: 35,
                          child: IconButton(
                            icon: Icon(Icons.timer),
                            color: HexColor('EA6012'),
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
                            },
                          ),
                        )
                      ],
                    )),
              )
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.10,
          ),
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
                    onPressed: () {
                      submit();
                    },
                    child: Text(
                      l10n.accept,
                      style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 20,
                          color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    )));
  }
}
