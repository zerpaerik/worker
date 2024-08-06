import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:worker/local/database_creator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/model/workday.dart';
import 'dart:async';

import '../../model/user.dart';
import '../../model/clock.dart';
import '../../providers/workday.dart';
import '../widgets.dart';
import 'cam_scan_out.dart';

class DetailClockOut extends StatefulWidget {
  final User? user;
  final Workday? workday;
  final String? lat;
  final String? long;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? wk;
  Map<String, dynamic>? datas;

  DetailClockOut(
      {required this.user,
      required this.workday,
      this.lat,
      this.long,
      this.contract,
      this.wk,
      this.datas});

  @override
  _DetailClockOutState createState() => _DetailClockOutState(
      user!, workday!, lat!, long!, contract!, wk!, datas!);
}

class _DetailClockOutState extends State<DetailClockOut> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  User user;
  Workday workday;
  String? coordinates;
  String lat;
  String long;
  Map<String, dynamic> contract;
  Map<String, dynamic> wk;
  Map<String, dynamic> datas;

  _DetailClockOutState(this.user, this.workday, this.lat, this.long,
      this.contract, this.wk, this.datas);
  //DateFormat format = DateFormat("yyyy-MM-dd");
  bool isLoading = false;
  Workday? _wd;

  Clocks? clock;
  DateFormat? dateFormat = DateFormat("HH:mm:ss");
  String? _time = "Sin Cambios";
  DateTime? hourClock;

  String? _locationMessage = "";
  Map<String, dynamic>? workday_on;
  Geolocator? geolocator = Geolocator();

  Position? userLocation;

  // String formatter = DateFormat('yMd').format(hour);
  //int time = DateTime.now().millisecondsSinceEpoch;
  //String t = "$time";

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

  todayDateTime() {
    var now = new DateTime.now();
    String formattedTime = DateFormat('kk:mm:a').format(now);
    return formattedTime;
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

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });

    _locationMessage = '--- ---';

    try {
      Provider.of<WorkDay>(context, listen: false)
          .addClockOut(
        widget.user!.id,
        hourClock,
        _locationMessage,
        workday_on,
      )
          .then((response) {
        print('responseclock out');
        print(response);
        int resp = 0;
        setState(() {
          isLoading = false;
          resp = response;
        });
        getWorkdayOn(1);
        if (resp != 0) {
          /* Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ListClockOut(
                      user: user,
                      workday: this.widget.workday.id,
                      work: this.widget.workday,
                      contract: this.widget.contract,
                      wk: this.widget.wk,
                    )),
          );*/
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QRSCANOUT(
                    user: user,
                    workday: widget.workday!.id,
                    work: widget.workday,
                    contract: widget.contract,
                    wk: widget.wk)),
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

  todayDateTimeWork() {
    var now = widget.workday!.clock_out_start ?? DateTime.now();
    String formattedTime = DateFormat('hh:mm:aa').format(now);
    return formattedTime;
  }

  void _viewWorkDay() {
    Provider.of<WorkDay>(context, listen: false).fetchWorkDay().then((value) {
      setState(() {
        _wd = value;
      });
      getWorkdayOn(1);
    });
  }

  @override
  void initState() {
    _viewWorkDay();
    _getLocation().then((position) {
      userLocation = position;
    });
    super.initState();
  }

  void _showWorker() {
    print(user.profile_image.toString().replaceAll('File: ', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          height: 420,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    // ignore: prefer_interpolation_to_compose_strings
                    "Foto de"
                            ' ' +
                        user.first_name! +
                        ' ' +
                        user.last_name!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/cargando.gif',
                        image: user.profile_image
                            .toString()
                            .replaceAll('File: ', '')
                            .replaceAll("'", ""),
                      ) /*Image.network(user.profile_image
                          .toString()
                          .replaceAll('File: ', '')
                          .replaceAll("'", ""))*/
                      ,
                    )
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    //color: myColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0)),
                  ),
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                          color: HexColor('EA6012'),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: <Widget>[
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
                      Navigator.of(context).pop();
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
                          child: const Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Detalle de Clock out',
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
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(widget.datas!['company_name'],
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.worker_data,
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
                child: Text('Emplooy ID:${user.btn_id!}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showWorker();
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(user.first_name!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      )),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showWorker();
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(user.last_name!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      )),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.warnings_3,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/clock1.png',
                    width: 30,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 12),
                  child: Text(
                    l10n.clockin_26,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 60),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    todayDateTime(),
                    style: TextStyle(
                        fontSize: 25,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold),
                  )),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/clock1.png',
                    width: 30,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    l10n.hour_register,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            if (workday_on != null) ...[
              Container(
                margin: EdgeInsets.only(left: 60, right: 20),
                child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      DateFormat('hh:mm:aa').format(DateTime.parse(
                          workday_on!['default_exit'].toString())),
                      style: TextStyle(
                          fontSize: 25,
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold),
                    )),
              )
            ],
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.15,
            ),
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
                        backgroundColor:
                            MaterialStateProperty.all(HexColor('EA6012')),
                      ),
                      onPressed: _submit,
                      child: Text(
                        l10n.accept,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            ),
          ])))),
    );
  }
}
