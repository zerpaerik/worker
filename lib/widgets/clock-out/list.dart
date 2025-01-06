import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/certification.dart';
import '../../local/database_creator.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:http/http.dart' as http;

import '../../model/user.dart';
import '../../model/config.dart';
import '../../model/workday.dart';
import '../clock-in/detail.dart';
import '../global.dart';
import 'cam_scan_out.dart';
import 'confirm.dart';
import 'detail.dart';
import 'detail_ext.dart';
import 'detail_manually.dart';
import 'detail_manually_in.dart';
import 'update_out_default.dart';

class ListClockOut extends StatefulWidget {
  static const routeName = '/my-clockout';
  User? user;
  int? workday;
  Map<String, dynamic>? contract;
  Workday? work;
  Map<String, dynamic>? wk;

  ListClockOut({this.user, this.workday, this.contract, this.work, this.wk});

  @override
  _ListClockOutState createState() =>
      _ListClockOutState(user!, workday!, contract!, work!, wk!);
}

class _ListClockOutState extends State<ListClockOut> {
  User user;
  int workday;
  Map<String, dynamic> contract;
  Workday work;
  Map<String, dynamic> wk;

  _ListClockOutState(
      this.user, this.workday, this.contract, this.work, this.wk);
  // ignore: unused_field
  int? _selectedIndex = 3;
  Workday? _wd;
  bool? loading = false;
  bool isLoading = false;
  String? verified;
  bool? scanning = false;
  String? qrCodeResult = "Not Yet Scanned";
  int? workDayCurrent;
  Config? config;
  int? totalw;
  Map<String, dynamic>? workday_on;

  //List data = List();
  List data = [];
  List datae = [];

  List data1 = [];
  List data1E = [];

  Certification? crt;
  String? isData = '';
  String? isDataE = '';

  String? isData1 = '';
  String isData1E = '';

  Geolocator? geolocator = Geolocator();
  Position? userLocation;
  Map<String, dynamic>? dataContract;

  String? dat;
  int? totalp;
  int? totala;
  Map<String, dynamic>? contractCurrent;
  String isContract = "0";

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

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<String?> getHourClock() async {
    SharedPreferences hourClock = await SharedPreferences.getInstance();
    String? stringValue = hourClock.getString('stringValue');
    return stringValue;
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
            child: Text(
              'Ok',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  void _showErrorDialogCI(String message, User worker) {
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

  Future<bool?> scanQRWorker(
      String identification, String lat, String long) async {
    String contract = widget.contract!['contract_id'].toString();
    String token = await getToken();
    print(contract);
    print('llego aqui');
    setState(() {
      scanning = true;
    });

    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/get-registered-user/$identification/$contract/out'),
        headers: {"Authorization": "Token $token"});
    setState(() {
      scanning = false;
    });
    var resBody = json.decode(response.body);
    print(response.statusCode);

    if (response.statusCode == 200 &&
        resBody['first_name'] != null &&
        resBody['detail'] == null) {
      print('dio bienpara escanear');
      print(resBody);
      User worker = User.fromJson(resBody);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailClockOut(
                user: worker,
                workday: widget.work,
                lat: lat,
                long: long,
                contract: widget.contract,
                wk: workday_on)),
      );
    }
    if (response.statusCode == 200 &&
        resBody['detail'] == 'The worker has not clocked in') {
      print('dio bien para escanear sin clock in');
      print(resBody);
      User worker = User.fromJson(resBody);
      _showErrorDialogCI('Not clock', worker);
    }

    if (response.statusCode == 200 &&
        resBody['detail'] == 'The worker has already clocked out') {
      _showErrorDialog('Not clock');
    }

    if (response.statusCode == 200 &&
        resBody['detail'] == 'worker not belongs to a project') {
      _showErrorDialog('Not clock');
    }

    /*else {
      print('dio error');
      String error = resBody['detail'];
      if (error == 'The worker has not clocked in') {
        _showErrorDialogCI(AppTranslations.of(context).text("w_hasnotdone_clockin"));
      } else {
        _showErrorDialog('Verifique la información.');
      }
    }¨*/
  }

  Future<bool?> scanQRWorkerE(
      String identification, String lat, String long) async {
    String contract = widget.contract!['contract_id'].toString();
    String token = await getToken();
    print(contract);
    print('llego aqui');
    setState(() {
      scanning = true;
    });

    final response = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/user/get-registered-user/$identification/$contract/out'),
        headers: {"Authorization": "Token $token"});
    setState(() {
      scanning = false;
    });
    var resBody = json.decode(response.body);
    print(response.statusCode);

    if (response.statusCode == 200 &&
        resBody['first_name'] != null &&
        resBody['detail'] == null) {
      print('dio bienpara escanear');
      print(resBody);
      User worker = User.fromJson(resBody);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => DetailExtClockOut(
                user: resBody,
                workday: widget.work,
                lat: lat,
                long: long,
                contract: widget.contract,
                wk: workday_on)),
      );
    }
    if (response.statusCode == 200 &&
        resBody['detail'] == 'The worker has not clocked in') {
      print('dio bien para escanear sin clock in');
      print(resBody);
      User worker = User.fromJson(resBody);
      _showErrorDialogCI('Not clock', worker);
    }

    if (response.statusCode == 200 &&
        resBody['detail'] == 'The worker has already clocked out') {
      _showErrorDialog('Not clock');
    }

    if (response.statusCode == 200 &&
        resBody['detail'] == 'worker not belongs to a project') {
      _showErrorDialog('Not clock');
    }

    /*else {
      print('dio error');
      String error = resBody['detail'];
      if (error == 'The worker has not clocked in') {
        _showErrorDialogCI(AppTranslations.of(context).text("w_hasnotdone_clockin"));
      } else {
        _showErrorDialog('Verifique la información.');
      }
    }¨*/
  }

  Future<String> getSWData() async {
    String token = await getToken();
    int? wk = widget.workday;
    setState(() {
      loading = true;
    });
    print(wk);
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$wk/clock-out/list'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);
    print(res.statusCode);

    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(res.body);
        if (data.length > 0) {
          isData = 'Y';
        } else {
          isData = 'N';
        }
      });
    } else {
      print(res.statusCode);
    }

    return "Sucess";
  }

  Future<String> getSWDataE() async {
    String token = await getToken();
    int? wk = widget.workday;
    setState(() {
      loading = true;
    });
    print(wk);
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$wk/clock-out/extemporaneus/list'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);
    print(res.statusCode);

    if (res.statusCode == 200) {
      setState(() {
        datae = json.decode(res.body);
        if (datae.length > 0) {
          isDataE = 'Y';
        } else {
          isDataE = 'N';
        }
      });
    } else {
      print(res.statusCode);
    }

    return "Sucess";
  }

  Future<String> getSWData1() async {
    String token = await getToken();
    int? wk = widget.workday;
    setState(() {
      loading = true;
    });
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$wk/not-clocked-outs/list'),
        headers: {"Authorization": "Token $token"});

    if (res.statusCode == 200) {
      setState(() {
        data1 = json.decode(res.body);
        if (data1.isNotEmpty) {
          isData1 = 'Y';
        } else {
          isData1 = 'N';
        }
      });
    } else {
      print(res.statusCode);
    }

    return "Sucess";
  }

  Future<String> getSWData1E() async {
    String token = await getToken();
    int? wk = widget.workday;
    setState(() {
      loading = true;
    });
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$wk/not-clocked-out-only/list'),
        headers: {"Authorization": "Token $token"});

    if (res.statusCode == 200) {
      setState(() {
        data1E = json.decode(res.body);
        if (data1E.isNotEmpty) {
          isData1E = 'Y';
        } else {
          isData1E = 'N';
        }
      });
    } else {
      print(res.statusCode);
    }

    return "Sucess";
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

  void _showConfirmEnd() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Estás Intentando Finalizar el Proceso'),
        content:
            Text('¿Estás seguro que deseas finalizar el proceso de clock out?'),
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
              _showviewRequest();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardHome(noti: false, data: {})),
              );
            },
          )
        ],
      ),
    );
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
    _viewContract();
    super.initState();
    getSWData();
    getSWData1();
    getSWData1E();
    getSWDataE();
    getTodo(1);
    getWorkdayOn(1);
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    totalw = data.length + data1.length;
    totalp = data.length + datae.length;
    totala = data1.length + data1E.length;

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
                            builder: (context) =>
                                DashboardHome(noti: false, data: {})),
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
                              'Clock-out',
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
                  if (workday_on!['clock_out_fin'] == '') ...[
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
                              DateTime now = DateTime.now();
                              DateTime init = workday_on!['ult_clock'] != ''
                                  ? DateTime.parse(
                                      workday_on!['ult_clock'].toString())
                                  : DateTime.now();

                              if (now.difference(init) >
                                  const Duration(minutes: 1)) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UpdateOut(
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
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => QRSCANOUT(
                                            user: user,
                                            workday: widget.workday,
                                            work: widget.work,
                                            contract: widget.contract,
                                            wk: workday_on,
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
                    child: Text(l10n.clockout_11,
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
                    child: Text(l10n.clockout_12,
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
                    child: Text(data.length.toString(),
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
                      text: '${l10n.clockout_13} ${totalp.toString()}',
                    ),
                  ),
                  Tab(
                    text: '${l10n.clockout_14} ${totala.toString()}',
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
                                                                0.30,
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
                                                          flex: 3,
                                                          child: Container(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.30,
                                                            child: Container(
                                                              child: Text(
                                                                'ID#${datae[index]['btn_id']}',
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
                                                                    '${datae[index]['last_name']} ${datae[index]['first_name']}',
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
                              child: Text(l10n.clockout_18),
                            ),
                  isData1E == ''
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : isData1E == 'Y' || isData1 == 'Y'
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
                                        child: Text(l10n.clockout_15,
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
                                            itemCount: data1E.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: <Widget>[
                                                  GestureDetector(
                                                      onTap: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) => DetailManuallyClockOut(
                                                                  user: data1E[
                                                                      index],
                                                                  workday:
                                                                      widget
                                                                          .work,
                                                                  us: widget
                                                                      .user,
                                                                  contract: widget
                                                                      .contract,
                                                                  wk: workday_on)),
                                                        );
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 10),
                                                            child: Icon(
                                                              Icons.cancel,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 5),
                                                            child: Text(
                                                              'ID# ${data1E[index]['btn_id']}',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              '${data1E[index]['last_name']} ${data1E[index]['first_name']}',
                                                              style: TextStyle(
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              );
                                            },
                                          ))),
                                  Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(l10n.clockout_16,
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
                                            itemCount: data1.length,
                                            itemBuilder: (context, index) {
                                              return Column(
                                                children: <Widget>[
                                                  GestureDetector(
                                                      onTap: () {
                                                        /*  Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DetailManuallyClockOut(
                                                                    user: data1[
                                                                        index],
                                                                    workday: this
                                                                        .widget
                                                                        .work,
                                                                    // lat: this.widget.lat,
                                                                    //long: long,
                                                                    contract: this
                                                                        .widget
                                                                        .contract,
                                                                    wk: workday_on,
                                                                    us: this
                                                                        .widget
                                                                        .user,
                                                                  )),
                                                        );*/
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  DetailManuallyClockOutIn(
                                                                    // user: user,
                                                                    workday:
                                                                        widget
                                                                            .work,
                                                                    //  work: this.widget.workday,
                                                                    contract: widget
                                                                        .contract,
                                                                    wk: workday_on,
                                                                    us: widget
                                                                        .user,
                                                                    user: data1[
                                                                        index],
                                                                  )),
                                                        );
                                                      },
                                                      child: Row(
                                                        children: <Widget>[
                                                          Container(
                                                            margin:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            child: const Icon(
                                                              Icons.cancel,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                          Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    left: 5),
                                                            child: Text(
                                                              'ID# ${data1[index]['btn_id']}',
                                                              style: const TextStyle(
                                                                  color: Colors
                                                                      .grey,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                          Container(
                                                            child: Text(
                                                              '${data1[index]['last_name']} ${data1[index]['first_name']}',
                                                              style: TextStyle(
                                                                  fontSize: 15),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 5,
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              );
                                            },
                                          ))),
                                ],
                              ),
                            )
                          : Center(
                              child: Text(l10n.clockout_17),
                            )
                ],
              ),
            ),
            if (workday_on != null) ...[
              if (workday_on!['clock_out_fin'] == '') ...[
                if (config != null) ...[
                  if (config!.role == 'supervisor') ...[
                    Container(
                      alignment: Alignment.topRight,
                      margin: const EdgeInsets.only(right: 30, bottom: 15),
                      // margin: EdgeInsets.only(left:15),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    HexColor('EA6012')),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ConfirmClockOut(
                                            user: widget.user,
                                            workday: widget.workday,
                                            work: widget.work,
                                            contract: widget.contract,
                                            geo: userLocation != null
                                                ? '${userLocation!.latitude} ${userLocation!.longitude}'
                                                : '--- ---',
                                          )),
                                );
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
              if (workday_on!['clock_out_fin'] != '') ...[
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
                          onPressed: () async {
                            DateTime now = DateTime.now();
                            DateTime init = workday_on!['ult_clock'] != ''
                                ? DateTime.parse(
                                    workday_on!['ult_clock'].toString())
                                : DateTime.now();

                            if (now.difference(init) >
                                const Duration(minutes: 1)) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UpdateOut(
                                          user: user,
                                          workday: widget.workday,
                                          work: widget.work,
                                          contract: widget.contract,
                                          wk: workday_on,
                                          dif: now.difference(init).toString(),
                                        )),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => QRSCANOUT(
                                          user: user,
                                          workday: widget.workday,
                                          work: widget.work,
                                          contract: widget.contract,
                                          wk: workday_on,
                                        )),
                              );
                            }
                            /*  Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QRSCANOUT(
                                        user: user,
                                        workday: workday_on!['workday_id'],
                                        work: widget.work,
                                        contract: widget.contract,
                                        wk: workday_on,
                                      )),
                            );*/
                          },
                          child: Text(
                            l10n.clockout_3,
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ),
                )
              ]
            ]
          ],
        ),
      ),
    );
  }

  Widget _getList() {
    return Container(
        margin: EdgeInsets.all(5),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    'ID# ${data[index]['btn_id']}',
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
                    '${data[index]['last_name']} ${data[index]['first_name']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            );
          },
        ));
  }

  Widget _getListNO() {
    return Container(
        margin: EdgeInsets.all(5),
        child: ListView.builder(
          itemCount: data1.length,
          itemBuilder: (context, index) {
            return Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.cancel,
                    color: Colors.red,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 5),
                  child: Text(
                    'ID#' + ' ' + '${data1[index]['btn_id']}',
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
                    '${data1[index]['last_name']}' +
                        ' ' +
                        '${data1[index]['first_name']}',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            );
          },
        ));
  }
}
