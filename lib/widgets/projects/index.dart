import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import '../global.dart';
import '../widgets.dart';
import 'detail.dart';

class ProjectList extends StatefulWidget {
  @override
  _ProjectListState createState() => _ProjectListState();
}

class _ProjectListState extends State<ProjectList> {
  List listProjects = [];
  String isData = '';
  TextEditingController? tc;
  DateTime? hourClock;

  var rows = [];
  List? results = [];
  String? query = '';

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getProjects() async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-2/contract/user-contracts'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      listProjects = resBody;
      rows = resBody;
      if (listProjects.length > 0) {
        isData = 'Y';
      } else {
        isData = 'N';
      }
    });

    print(resBody);

    return "Sucess";
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
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
              margin: EdgeInsets.only(left: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Image.asset(
                  'assets/welcome_emplooy.png',
                  width: 50,
                  color: HexColor('EA6012'),
                ),
              )),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Container(
              margin: EdgeInsets.only(left: 30, right: 30),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  l10n.list_contract,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                      color: HexColor('EA6012')),
                ),
              )),
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
                  setResults(query!);
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
                      child: query!.isEmpty
                          ? ListView.builder(
                              itemCount: rows.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailProject(
                                                project: rows[index],
                                              )),
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Card(
                                          margin: EdgeInsets.only(
                                              left: 30, right: 30),
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: HexColor('EA6012'),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.80,
                                                      child: Column(
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                          ),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index][
                                                                  'contract_name'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      '3E3E3E')),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index]
                                                                  ['customer'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      'EA6012')),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index]['first_address'] !=
                                                                      null
                                                                  ? rows[index][
                                                                      'first_address']
                                                                  : "",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                //fontWeight: FontWeight.bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              rows[index]['current_workday_status'] ==
                                                                      'CIS'
                                                                  ? l10n
                                                                      .clockin_started
                                                                  : rows[index][
                                                                              'current_workday_status'] ==
                                                                          'CIE'
                                                                      ? l10n
                                                                          .clockin_finish
                                                                      : rows[index]['current_workday_status'] ==
                                                                              'COS'
                                                                          ? l10n
                                                                              .clockout_started
                                                                          : rows[index]['current_workday_status'] == 'C0E'
                                                                              ? l10n.clockout_finish
                                                                              : rows[index]['current_workday_status'] == 'WRE'
                                                                                  ? l10n.complete_report
                                                                                  : l10n.to_init_day,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topRight,
                                                        // margin: EdgeInsets.only(left: 5),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Container(
                                                                      child:
                                                                          Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      rows[index]['current_workday'] !=
                                                                              0
                                                                          ? rows[index]['current_workday']['clock_ins']
                                                                              .toString()
                                                                          : '0',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              35,
                                                                          color:
                                                                              HexColor('EA6012')),
                                                                    ),
                                                                  )),
                                                                  Container(
                                                                      child:
                                                                          Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      'Assigned' +
                                                                          '\n' +
                                                                          'Workers',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              HexColor('3E3E3E')),
                                                                    ),
                                                                  ))
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ],
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                    ],
                                  ),
                                );
                              })
                          : ListView.builder(
                              itemCount: results!.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => DetailProject(
                                                project: results![index],
                                              )),
                                    );
                                  },
                                  child: Column(
                                    children: <Widget>[
                                      Card(
                                          margin: EdgeInsets.only(
                                              left: 30, right: 30),
                                          color: Colors.white,
                                          shape: RoundedRectangleBorder(
                                              side: BorderSide(
                                                  color: HexColor('EA6012'),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(10.0)),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      alignment:
                                                          Alignment.topLeft,
                                                      margin: EdgeInsets.only(
                                                          left: 10),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.80,
                                                      child: Column(
                                                        children: <Widget>[
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                          ),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              results![index][
                                                                  'contract_name'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      '3E3E3E')),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              results![index]
                                                                  ['customer'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      'EA6012')),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              results![index][
                                                                  'first_address'],
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                //fontWeight: FontWeight.bold,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )),
                                                          Container(
                                                              child: Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Text(
                                                              results![index][
                                                                          'current_workday_status'] ==
                                                                      'CIS'
                                                                  ? l10n
                                                                      .clockin_started
                                                                  : results![index]
                                                                              [
                                                                              'current_workday_status'] ==
                                                                          'CIE'
                                                                      ? l10n
                                                                          .clockin_finish
                                                                      : results![index]['current_workday_status'] ==
                                                                              'COS'
                                                                          ? l10n
                                                                              .clockout_started
                                                                          : results![index]['current_workday_status'] == 'C0E'
                                                                              ? l10n.clockout_finish
                                                                              : results![index]['current_workday_status'] == 'WRE'
                                                                                  ? l10n.complete_report
                                                                                  : l10n.to_init_day,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .green,
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )),
                                                          SizedBox(
                                                            height: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .height *
                                                                0.02,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topRight,
                                                        // margin: EdgeInsets.only(left: 5),
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.10,
                                                        child: Row(
                                                          children: <Widget>[
                                                            Container(
                                                              child: Column(
                                                                children: <Widget>[
                                                                  Container(
                                                                      child:
                                                                          Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      results![index]['current_workday'] !=
                                                                              0
                                                                          ? results![index]['current_workday']['clock_ins']
                                                                              .toString()
                                                                          : '0',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              35,
                                                                          color:
                                                                              HexColor('EA6012')),
                                                                    ),
                                                                  )),
                                                                  Container(
                                                                      child:
                                                                          Align(
                                                                    alignment:
                                                                        Alignment
                                                                            .topLeft,
                                                                    child: Text(
                                                                      'Workers',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              12,
                                                                          color:
                                                                              HexColor('3E3E3E')),
                                                                    ),
                                                                  ))
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ],
                                          )),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                    ],
                                  ),
                                );
                              }))
                  : Container(
                      margin: EdgeInsets.only(top: 200),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Text(
                          'No existen proyectos asociados',
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
