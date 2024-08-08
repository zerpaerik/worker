import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/widgets/projects/contract_list.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:http/http.dart' as http;
import '../../global.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'detail.dart';

class DetailCrewsheet extends StatefulWidget {
  final Map<String, dynamic>? project;
  final int? report;

  DetailCrewsheet({this.project, this.report});

  @override
  _DetailCrewsheetState createState() => _DetailCrewsheetState(project, report);
}

class _DetailCrewsheetState extends State<DetailCrewsheet> {
  Map<String, dynamic>? project;
  int? report;
  _DetailCrewsheetState(this.project, this.report);
  List? listProjects = [];
  String isData = '';
  TextEditingController? tc;
  DateTime? hourClock;

  var rows = [];
  List results = [];
  String query = '';

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getProjects() async {
    String token = await getToken();

    int? report = widget.report;

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/crew/report/$report/worker'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print('detalle');
    print(resBody);

    setState(() {
      listProjects = resBody;
      rows = resBody;
      if (rows.isNotEmpty) {
        isData = 'Y';
      } else {
        isData = 'N';
      }
    });

    print(resBody);

    return "Sucess";
  }

  void _showAlert() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
          content: Container(
        width: 260.0,
        height: 230.0,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: const Color(0xFFFFFF),
          borderRadius: BorderRadius.all(new Radius.circular(32.0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // dialog top
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    // padding: new EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Text(
                      'Rate',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                        fontFamily: 'helvetica_neue_light',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                  child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.only(
                      left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
                  hintText: ' add review',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12.0,
                    fontFamily: 'helvetica_neue_light',
                  ),
                ),
              )),
              flex: 2,
            ),

            // dialog bottom
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF33b17c),
                ),
                child: Text(
                  'Rate product',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    fontFamily: 'helvetica_neue_light',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      )),
    );
  }

  void _showInfoWorker(data) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
            height: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Container(
                      //  margin: EdgeInsets.only(left: 15, right: 80, top: 15),
                      child: Text(
                        'ID:' + ' ' + data['btn_id'].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: HexColor('EA6012'),
                            fontSize: 17),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(left: 20),
                        child: Image.asset(
                          'assets/worker.png',
                          width: 30,
                        )),
                  ],
                ),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 2,
                  indent: 15,
                  endIndent: 15,
                ),
                Container(
                    //margin: EdgeInsets.only(left: 15),
                    child: Row(
                  //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.topLeft,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Text(
                          data['last_name'] + ' ' + data['first_name'],
                          style: TextStyle(color: Colors.grey, fontSize: 17),
                        ),
                      ),
                    ),
                  ],
                )),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),

                Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/entrada.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(l10n.wr_4,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Text(data['workday_entry_time']
                              .toString()
                              .substring(11, 16)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/salida.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            l10n.wr_5,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(data['workday_departure_time']
                              .toString()
                              .substring(11, 16)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/horast.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            l10n.wr_20,
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(data['worked_hours'].toString()),
                        ],
                      ),
                    ),
                  ),
                ]),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),

                SizedBox(height: 10),
                Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/lunch.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(l10n.lunch,
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center),
                          Text(data['lunch_duration']
                              .toString()
                              .substring(0, 5)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/stand.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'StandBy',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(data['standby_duration']
                              .toString()
                              .substring(0, 5)),
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 50,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.33,
                      child: Column(
                        children: <Widget>[
                          Image.asset('assets/duracion.png', width: 30),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Travel',
                            style: TextStyle(
                                fontSize: 10, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          Text(data['travel_duration']
                              .toString()
                              .substring(0, 5)),
                        ],
                      ),
                    ),
                  ),
                ]),
                Divider(
                  color: Colors.grey[200],
                  // height: 1,
                  thickness: 1,
                  indent: 15,
                  endIndent: 15,
                ),
                //  SizedBox(height: 5)
              ],
            )),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getProjects();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.04,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 15),
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
                  margin: EdgeInsets.only(right: 15),
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                    child: Text(''),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.crew_detail,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: HexColor('EA6012')),
                ),
              )),
          Container(
            margin: EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                  DateFormat("MMMM d yyyy")
                      .format(
                          DateTime.parse(widget.project!['workday_entry_time']))
                      .toString(),
                  style: TextStyle(
                      fontSize: 15,
                      color: HexColor('EA6012'),
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${l10n.workers}: ',
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
                      listProjects != null
                          ? listProjects!.length.toString()
                          : '0',
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
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('${l10n.hours}: ',
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
                  child: Text(widget.project!['worked_hours'].toString(),
                      style: TextStyle(
                          fontSize: 15,
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            //padding: const EdgeInsets.all(10.0),
            child: TextField(
              controller: tc,
              decoration: InputDecoration(hintText: l10n.search),
              onChanged: (v) {
                setState(() {
                  query = v;
                  setResults(query);
                });
              },
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
          ),
          isData == ''
              ? Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.20,
                    ),
                    Center(
                      child: CircularProgressIndicator(),
                    )
                  ],
                )
              : isData == 'Y'
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.65,
                      child: query.isEmpty
                          ? MediaQuery.removePadding(
                              removeTop: true,
                              context: context,
                              child: ListView.builder(
                                  itemCount: rows.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            print('tocando');
                                            _showInfoWorker(rows[index]);
                                            // _showAlert();
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 30),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Text(
                                                  'ID#' +
                                                      ' ' +
                                                      '${rows[index]['btn_id']}',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                child: Text(
                                                  '${rows[index]['last_name']}' +
                                                      ' ' +
                                                      '${rows[index]['first_name']}',
                                                  style:
                                                      TextStyle(fontSize: 15),
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
                                  }))
                          : MediaQuery.removePadding(
                              removeTop: true,
                              context: context,
                              child: ListView.builder(
                                  itemCount: results.length,
                                  itemBuilder: (context, index) {
                                    return Column(
                                      children: <Widget>[
                                        SizedBox(
                                          height: 10,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _showAlert();
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 30),
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 5),
                                                child: Text(
                                                  'ID#' +
                                                      ' ' +
                                                      '${results[index]['btn_id']}',
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Container(
                                                child: Text(
                                                  '${results[index]['last_name']}' +
                                                      ' ' +
                                                      '${results[index]['first_name']}',
                                                  style:
                                                      TextStyle(fontSize: 15),
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
                                  })))
                  : Container(
                      margin: EdgeInsets.only(top: 200),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          l10n.no_register,
                          style: TextStyle(
                            color: HexColor('EA6012'),
                            fontSize: 17,
                          ),
                        ),
                      )),
        ],
      ),
    );
  }

  void setResults(String query) {
    results = rows
        .where((elem) =>
            elem['contract_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['customer']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['first_address']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }
}
