import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/local/database_creator.dart';
import 'package:worker/model/certification.dart';
import 'package:worker/model/config.dart';
import 'package:worker/providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../providers/workday.dart';

import '../../model/user.dart';
import '../../model/workday.dart';

// ignore: must_be_immutable
class TodayClockIn extends StatefulWidget {
  static const routeName = '/my-clockin';
  final int? workday;
  Map<String, dynamic>? contract;

  TodayClockIn({this.workday, this.contract});

  @override
  _TodayClockInState createState() => _TodayClockInState(workday, contract);
}

class _TodayClockInState extends State<TodayClockIn> {
  User? user;
  int? workday;
  DateTime? workdayDate;
  Map<String, dynamic>? contract;
  Workday? work;
  Map<String, dynamic>? wk;

  Geolocator? geolocator = Geolocator();

  Position? userLocation;
  _TodayClockInState(this.workday, this.contract);
  // ignore: unused_field
  int _selectedIndex = 3;
  bool? loading = false;
  String? verified;
  bool scanning = false;
  String? qrCodeResult = "Not Yet Scanned";
  bool finish = false;
  Workday? _wd;
  TextEditingController? tc;
  DateTime? hourClock;
  var rows = [];
  List? results = [];
  String? query = '';

  List? data = [];
  List? datae = [];

  List? data1 = [];

  Certification? crt;
  String? isData = '';
  String? isDataE = '';
  bool _isData = false;

  String? isData1 = '';
  bool isLoading = false;
  String? _time = "Sin Cambios";
  Config? config;
  Map<String, dynamic>? dataContract;
  String? geo;
  Map<String, dynamic>? workday_on;
  String? barcodeScanRes;

  String? dat;
  int? totalw;

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

  void _showWorker(data) {
    //print(user.profile_image.toString().replaceAll('File: ', ''));
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
                    data['first_name'] + '\n' + data['last_name'],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: HexColor('EA6012')),
                  ),
                ],
              ),
              SizedBox(
                height: 4.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Emplooy ID#' + ' ' + data['btn_id'],
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black),
                  ),
                ],
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
                        width: 250,
                        height: 250,
                        placeholder: 'assets/cargando.gif',
                        image: data['profile_image']
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

  Future<dynamic> getSWData() async {
    String? token = await getToken();
    int? wd = widget.workday;
    setState(() {
      loading = true;
    });

    Provider.of<WorkDay>(context, listen: false)
        .listClockIn(wd)
        .then((response) {
      if (response['status'] == '200') {
        setState(() {
          _isData = true;
          data = response['data'];
          rows = response['data'];
          print('rowss');
          print(rows);
          if (data!.isNotEmpty) {
            isData = 'Y';
          } else {
            isData = 'N';
          }
        });
      }
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
          if (datae!.isNotEmpty) {
            isDataE = 'Y';
          } else {
            isDataE = 'N';
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

  @override
  void initState() {
    super.initState();
    getSWData();
    getSWDataE();
    getTodo(1);
    getWorkdayOn(1);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    totalw = data!.length + datae!.length;
    var now = DateTime.now();

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
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
                    Navigator.of(context).pop();
                  }),
            ),
          ),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.contract != null
                      ? widget.contract!['contract_name']
                      : '---',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('3E3E3E')),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.contract != null
                      ? widget.contract!['customer']
                      : '---',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: HexColor('EA6012')),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  widget.contract != null
                      ? widget.contract!['first_address'] ?? ""
                      : '---',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  now.toString().substring(0, 11),
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black),
                ),
              )),
          Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '${data?.length} ${l10n.workers}',
                  style: TextStyle(
                    //fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          Container(
            margin: EdgeInsets.only(left: 20),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text('Clock-in diario',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: HexColor('EA6012'))),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          if (!_isData) ...[
            SizedBox(height: MediaQuery.of(context).size.height * 0.20),
            Center(
              child: CircularProgressIndicator(),
            )
          ],
          if (data != null && data!.isNotEmpty) ...[
            Container(
              margin: EdgeInsets.only(left: 20, right: 20),
              //padding: const EdgeInsets.all(10.0),
              child: TextField(
                controller: tc,
                decoration: InputDecoration(hintText: 'Buscar.'),
                onChanged: (v) {
                  setState(() {
                    query = v;
                    setResults(query!);
                  });
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Regulares',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                )),
            Container(
                margin: EdgeInsets.all(5),
                child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: query!.isEmpty
                        ? ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: data!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _showWorker(rows[index]);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          //flex: 1,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.19,
                                            // margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              'ID#' +
                                                  ' ' +
                                                  '${rows[index]['btn_id']}',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                            //margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${rows[index]['last_name']},' +
                                                  ' ' +
                                                  '${rows[index]['first_name']}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          )
                        : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: results!.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      _showWorker(results![index]);
                                    },
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          //flex: 1,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            margin: EdgeInsets.only(left: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.01,
                                            child: Icon(
                                              Icons.check,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.19,
                                            // margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              'ID#' +
                                                  ' ' +
                                                  '${results![index]['btn_id']}',
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 6,
                                          child: Container(
                                            alignment: Alignment.topLeft,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.80,
                                            //margin: EdgeInsets.only(left: 5),
                                            child: Text(
                                              '${results![index]['last_name']}, ${results![index]['first_name']}',
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            },
                          ))),
            Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Extemporáneos',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                )),
            Container(
                margin: EdgeInsets.all(5),
                child: MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: datae!.length,
                      itemBuilder: (context, index) {
                        return Column(
                          children: <Widget>[
                            Row(
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
                                    'ID#' + ' ' + '${datae![index]['btn_id']}',
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
                                    '${datae![index]['last_name']}' +
                                        ' ' +
                                        '${datae![index]['first_name']}',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    )))
          ]
        ],
      ),
    ));
  }

  void setResults(String query) {
    results = rows
        .where((elem) =>
            elem['first_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['last_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['btn_id']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }
}
