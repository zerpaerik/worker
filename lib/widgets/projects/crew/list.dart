import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/certification.dart';
import 'package:worker/model/config.dart';
import 'package:worker/widgets/projects/crewsheets/step_0.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:worker/widgets/projects/crewsheets/step_1.dart';
import 'package:intl/intl.dart' show DateFormat;
import '../../../providers/workday.dart';
import '../../../providers/crew.dart';

import '../../../model/user.dart';
import '../../../widgets/projects/crew/cam_scan.dart';
import '../../../model/workday.dart';
import '../../global.dart';
import '../contract_list.dart';
import 'detal_scan.dart';
import 'init_out.dart';
import 'update_init_crew.dart';

// ignore: must_be_immutable
class ListCrew extends StatefulWidget {
  static const routeName = '/my-crew-list';
  final int? workday;
  Map<String, dynamic>? shift;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? location;
  Map<String, dynamic>? crew;

  ListCrew(
      {required this.workday,
      this.contract,
      this.shift,
      this.location,
      this.crew});

  @override
  _ListCrewState createState() =>
      _ListCrewState(workday, contract, shift, crew);
}

class _ListCrewState extends State<ListCrew> {
  int? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? shift;
  Map<String, dynamic>? crew;

  Geolocator? geolocator = Geolocator();

  Position? userLocation;
  _ListCrewState(this.workday, this.contract, this.shift, this.crew);
  // ignore: unused_field
  int _selectedIndex = 3;
  bool loading = false;
  String? verified;
  bool scanning = false;
  String? qrCodeResult = "Not Yet Scanned";
  bool finish = false;
  Workday? _wd;
  TextEditingController? tc;
  DateTime? hourClock;

  var rows = [];
  List results = [];
  String query = '';

  List? data = [];
  List? datar = [];

  List? data1 = [];

  Certification? crt;
  String isData = '';
  String isDataR = '';
  String isDataE = '';

  String isData1 = '';
  bool isLoading = false;
  String _time = "Sin Cambios";
  Config? config;
  Map<String, dynamic>? dataContract;
  String? geo;
  Map<String, dynamic>? workday_on;
  String? barcodeScanRes;

  String? dat;
  int? totalw;
  bool exitproject = false;
  Map<String, dynamic>? crewCurrent;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  DateTime? start_time;
  DateTime? end_time;

  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9;

  getWorkdayOn(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      workday_on = todo;
    });

    return workday_on;
  }

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<bool> scanQRWorker(
      String identification, String lat, String long) async {
    String? token = await getToken();
    String contract = widget.contract!['contract_id'].toString();

    setState(() {
      scanning = true;
    });
    int? crew = widget.workday;

    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/crew/$crew/user/$identification'),
        headers: {"Authorization": "Token $token"});
    setState(() {});

    var resBody = json.decode(response.body);

    if (response.statusCode == 200 && resBody['first_name'] != null) {
      setState(() {
        scanning = false;
      });
      User _user = new User.fromJson(resBody);

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailCrew(
                  datas: resBody,
                  user: _user,
                  workday: widget.workday,
                  lat: lat,
                  long: long,
                  contract: widget.contract,
                )),
      );
    } else if (response.statusCode == 404) {
      //_showErrorDialog(AppTranslations.of(context).text("error"));
      setState(() {});
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                ListCrew(workday: widget.workday, contract: widget.contract)),
      );
    } else {
      print('dio error');
      setState(() {
        scanning = false;
      });
      //The worker has already clocked-in
      String error = resBody['detail'];
      print(resBody);
      if (error == 'worker not belongs to a project') {
        setState(() {});
      }
      if (error == 'The worker has already clocked-in') {
        // _showErrorDialog('El trabajador ya hizo clock in en la jornada.');
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ListCrew(workday: widget.workday, contract: widget.contract)),
        );
      }

      if (error == 'Not found.') {
        //_showErrorDialog(AppTranslations.of(context).text("w_dont_exist"));
        setState(() {});
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ListCrew(workday: widget.workday, contract: widget.contract)),
        );
      }
    }

    return true;
  }

  Future<dynamic> getSWData() async {
    int? wd = widget.workday;
    setState(() {
      loading = true;
    });

    await getCrew();

    Provider.of<CrewProvider>(context, listen: false)
        .listClockIn(wd)
        .then((response) {
      if (response['status'] == '200') {
        setState(() {
          data = response['data'];
          print('data de checkin');
          print(data);
          if (data!.isNotEmpty) {
            isData = 'Y';
          } else {
            isData = 'N';
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

  Future<String> getCrew() async {
    String? token = await getToken();
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

  void showDialog(title) {
    AlertDialog(
      content: Text(title,
          style: TextStyle(
            color: HexColor('EA6012'),
            fontWeight: FontWeight.bold,
            fontSize: 17,
          )),
      actions: [
        TextButton(
            onPressed: () {},
            child: Text('Ir al login',
                style: TextStyle(
                  color: HexColor('EA6012'),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                )))
      ],
    );
  }

  Future<dynamic> endIn() async {
    print('llego a pv');

    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<CrewProvider>(context, listen: false)
          .endIn(
        widget.crew!['id'],
      )
          .then((response) async {
        setState(() {
          isLoading = false;
        });
        showDialog('El checkin fue finalizado con exito....');

        await getCrew();
        print('response end crew in');
        print(response);
        setState(() {
          isLoading = false;
        });
      });
    } catch (error) {}
  }

  Future<dynamic> endOut() async {
    print('llego a pv');

    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<CrewProvider>(context, listen: false)
          .endOut(
        widget.crew!['id'],
      )
          .then((response) async {
        setState(() {
          isLoading = false;
        });
        showDialog('El checkout fue finalizado con exito....');

        await getCrew();
        print('response end crew in');
        print(response);
        setState(() {
          isLoading = false;
        });
      });
    } catch (error) {}
  }

  Future<dynamic> editCrew() async {
    print('llego a pv');

    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<CrewProvider>(context, listen: false)
          .editCrew(widget.crew!['id'], hourClock!)
          .then((response) async {
        setState(() {
          isLoading = false;
        });
        if (response['status'].toString() == '200') {
          showDialog('El checkout fue iniciado con exito...');
          print('entro aqui a list crew');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListCrew(
                      workday: widget.workday,
                      contract: widget.contract,
                      shift: widget.shift,
                      crew: crewCurrent,
                    )),
          );
          // _showErrorDialog('Checkin finalizado con exito');
        }
        await getCrew();
        print('response end crew in');
        print(response);
        setState(() {
          isLoading = false;
        });
      });
    } catch (error) {}
  }

  void _showInputDialog1(String title) {
    final l10n = AppLocalizations.of(context)!;

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
                              Expanded(
                                flex: 2,
                                child: Container(
                                    //color: HexColor('009444'),
                                    alignment: Alignment.topLeft,
                                    margin: EdgeInsets.only(left: 20),
                                    //height: MediaQuery.of(context).size.width * 0.1,
                                    width: MediaQuery.of(context).size.width *
                                        0.10,
                                    child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          'assets/salida.png',
                                          width: 40,
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.only(left: 5, top: 5),
                                          child: Text(
                                            l10n.wr_5,
                                            style: TextStyle(fontSize: 16),
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
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          _time,
                                          style: TextStyle(fontSize: 16),
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
                                              TimeOfDay? picketTime =
                                                  await showTimePicker(
                                                initialTime: TimeOfDay.now(),
                                                context: context,
                                              );

                                              if (picketTime != null) {
                                                DateTime selectedDateTime =
                                                    DateTime(
                                                  DateTime.now().year,
                                                  DateTime.now().month,
                                                  DateTime.now().day,
                                                  picketTime.hour,
                                                  picketTime.minute,
                                                );
                                                String formattedTime =
                                                    DateFormat('hh:mm aa')
                                                        .format(
                                                            selectedDateTime);
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
                              height:
                                  MediaQuery.of(context).size.height * 0.08),
                          Container(
                            margin: EdgeInsets.only(left: 10, right: 10),
                            child: Text(l10n.yes_ch,
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
                                        onPressed: () {},
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(
                                              width: 5.0,
                                              color: HexColor('EA6012')),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20.0)),
                                        ),
                                        child: Text(
                                          l10n.no,
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
                                                Navigator.of(context).pop();
                                                editCrew();
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
                                                l10n.si,
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
    super.initState();
    setState(() {
      start_time = DateTime.parse(DateTime.now().toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse((DateTime.now().toString())));
      hourClock = DateTime.parse((DateTime.now().toString()));
    });
    getCrew();
    getSWData();
    print(widget.crew);
    getTodo(1);
    getWorkdayOn(1);
  }

  List<List<String>> listsData = [
    ['Item 1', 'Item 2', 'Item 3'],
    ['Item A', 'Item B', 'Item C', 'Item D'],
    ['Item X', 'Item Y', 'Item Z'],
    ['Item P', 'Item Q', 'Item R'],
    ['Item M', 'Item N', 'Item O'],
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    totalw = data!.length;
    return Scaffold(
      body: Column(
        // Column
        children: <Widget>[
          SizedBox(height: MediaQuery.of(context).size.height * 0.03),
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
                          builder: (context) => ContractList(
                                location: widget.contract,
                              )),
                    );
                    //Navigator.of(context).pop();
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
                  //height: MediaQuery.of(context).size.width * 0.1,
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
                            'Crew',
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
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(right: 10, top: 10),
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
                        DateTime init =
                            DateTime.parse(workday_on!['ult_clock'].toString());
                        print(now);
                        print(init);
                        print(now.difference(init).toString());
                        int type = 1;

                        if (crewCurrent != null &&
                            crewCurrent!['clock_in_end'] == null) {
                          type = 1;
                        } else {
                          type = 2;
                        }

                        if (now.difference(init) > Duration(minutes: 1)) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UpdateInitCrew(
                                      contract: widget.contract,
                                      workday: widget.workday,
                                      typeC: type,
                                    )),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QRSCANCREW(
                                      crew: widget.crew,
                                      workday: widget.workday,
                                      contract: widget.contract,
                                    )),
                          );
                        }
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(widget.contract!['first_address'],
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: HexColor('EA6012'))),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text('BTN',
                  style: TextStyle(
                    fontSize: 17,
                  )),
            ),
          ),
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
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                  widget.shift != null && widget.shift!['name'] != null
                      ? widget.shift!['name']
                      : l10n.no_shift,
                  style: TextStyle(
                    fontSize: 17,
                  )),
            ),
          ),
          isData == ''
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : isData == 'Y'
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.60,
                      child: ListView.builder(
                        itemCount: data!.length,
                        itemBuilder: (context, index) {
                          return Card(
                              margin: EdgeInsets.only(left: 15, right: 15),
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: HexColor('EA6012'), width: 1),
                                  borderRadius: BorderRadius.circular(10.0)),
                              child: Column(
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 10, top: 10),
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.40,
                                            child: Container(
                                              child: Text(
                                                'ID#' +
                                                    '' +
                                                    '${data![index]['btn_id']}',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15),
                                              ),
                                            ),
                                          )),
                                      Expanded(
                                          flex: 7,
                                          child: Container(
                                            margin: EdgeInsets.only(
                                                left: 20, top: 10),
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.60,
                                            child: Row(
                                              children: <Widget>[
                                                Container(
                                                  margin:
                                                      EdgeInsets.only(left: 2),
                                                  child: Text(
                                                    '${data![index]['last_name']} ${data![index]['first_name']}',
                                                    style:
                                                        TextStyle(fontSize: 15),
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
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          'Check-in: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        child: Text(
                                            DateFormat("MMMM d yyyy hh:mm:aa")
                                                .format(DateTime.parse(
                                                    data![index]['check_in']
                                                        .toString()))),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: Text(
                                          'Check-out: ',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Container(
                                        child: Text(data![index]['check_out'] !=
                                                null
                                            ? DateFormat(
                                                    "MMMM dd, yyyy hh:mm:aa")
                                                .format(DateTime.parse(
                                                    data![index]['check_out']
                                                        .toString()))
                                            : 'S/H'),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10)
                                ],
                              ));
                        },
                      ))
                  : Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.20,
                        ),
                        Container(
                            margin: EdgeInsets.only(left: 30, right: 30),
                            child: Text(l10n.no_register_crew))
                      ],
                    ),
          if (data!.isEmpty) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.30,
            ),
          ],
          if (data!.isNotEmpty) ...[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
          ],
          if (crewCurrent != null && crewCurrent!['clock_in_end'] == null) ...[
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 20),
              // margin: EdgeInsets.only(left:15),
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
                        endIn();
                      },
                      child: Text(
                        'Finalizar check-in',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            )
          ],
          if (crewCurrent != null &&
              crewCurrent!['clock_in_end'] != null &&
              crewCurrent!['clock_out_start'] == null) ...[
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 20),
              // margin: EdgeInsets.only(left:15),
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
                              builder: (context) => OutCrewReport(
                                    shift: widget.shift,
                                    workday: widget.workday,
                                    crew: widget.crew,
                                    contract: widget.contract,
                                  )),
                        );
                        //_showInputDialog1('Iniciar checkout');
                        //endIn();
                      },
                      child: Text(
                        'Iniciar Check-out',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            )
          ],
          if (crewCurrent != null &&
              crewCurrent!['clock_out_start'] != null &&
              crewCurrent!['clock_out_end'] == null) ...[
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 20),
              // margin: EdgeInsets.only(left:15),
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
                        endOut();
                      },
                      child: Text(
                        'Finalizar Check-out',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            )
          ],
          if (crewCurrent != null && crewCurrent!['clock_out_end'] != null) ...[
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 20),
              // margin: EdgeInsets.only(left:15),
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all(HexColor('EA6012')),
                ),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewCresheet0(
                              workday: widget.workday,
                              contract: widget.contract,
                              location: widget.contract,
                              crew: crewCurrent,
                            )),
                  );
                },
                child: Text(
                  l10n.create_report,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            )
          ]
        ],
      ),
    );
  }
}
