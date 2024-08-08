import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/widgets/projects/contract_list.dart';
import 'package:http/http.dart' as http;
import '../global.dart';
import '../widgets.dart';
import 'detail.dart';

class LocationsList extends StatefulWidget {
  final Map<String, dynamic>? project;

  LocationsList({this.project});

  @override
  _LocationsListState createState() => _LocationsListState(project);
}

class _LocationsListState extends State<LocationsList> {
  Map<String, dynamic>? project;
  _LocationsListState(this.project);
  List listProjects = [];
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

    int project = widget.project!['id'];

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/project/$project/location'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(utf8.decode(res.bodyBytes));

    setState(() {
      listProjects = resBody;
      rows = resBody;
      if (listProjects.isNotEmpty) {
        isData = 'Y';
      } else {
        isData = 'N';
      }
    });
    print('locaciones');
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
                    child: Text(''),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  margin: EdgeInsets.only(left: 30),
                  alignment: Alignment.topLeft,
                  //height: MediaQuery.of(context).size.width * 0.1,
                  width: MediaQuery.of(context).size.width * 0.50,
                  child: Container(
                      child: Align(
                    alignment: Alignment.topLeft,
                    child: Image.asset(
                      'assets/welcome_emplooy.png',
                      width: 50,
                      color: HexColor('EA6012'),
                    ),
                  )),
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
                  l10n.locations_list,
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
                          ? ListView.builder(
                              itemCount: rows.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ContractList(
                                                location: rows[index],
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
                                                              rows[index]
                                                                      ['name']
                                                                  .toString(),
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
                                                              rows[index][
                                                                  'first_address'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      'EA6012')),
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
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('Clocked-in',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: HexColor(
                                                                        '3E3E3E'))),
                                                            Text(
                                                                rows[index][
                                                                        'today_clock_ins']
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: HexColor(
                                                                        'EA6012'))),
                                                            Text('Today',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: HexColor(
                                                                        '3E3E3E')))
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('Absents',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: HexColor(
                                                                        '3E3E3E'))),
                                                            Text(
                                                                rows[index][
                                                                        'today_absents']
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: HexColor(
                                                                        'EA6012'))),
                                                            Text('Today',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: HexColor(
                                                                        '3E3E3E')))
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('Worked hours',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: HexColor(
                                                                        '3E3E3E'))),
                                                            Text(
                                                                rows[index][
                                                                        'yesterday_wh']
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: HexColor(
                                                                        'EA6012'))),
                                                            Text('Yesterday',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: HexColor(
                                                                        '3E3E3E')))
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
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
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => ContractList(
                                                location: results[index],
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
                                                              results[index][
                                                                  'first_address'],
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
                                                              results[index]
                                                                  ['country'],
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 16,
                                                                  color: HexColor(
                                                                      'EA6012')),
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
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('Clocked-in',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: HexColor(
                                                                        '3E3E3E'))),
                                                            Text(
                                                                results[index]
                                                                        [
                                                                        'today_clock_ins']
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: HexColor(
                                                                        'EA6012'))),
                                                            Text('Today',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: HexColor(
                                                                        '3E3E3E')))
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('Absents',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: HexColor(
                                                                        '3E3E3E'))),
                                                            Text(
                                                                results[index]
                                                                        [
                                                                        'today_absents']
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: HexColor(
                                                                        'EA6012'))),
                                                            Text('Today',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: HexColor(
                                                                        '3E3E3E')))
                                                          ],
                                                        ),
                                                      )),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        alignment:
                                                            Alignment.topCenter,
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.33,
                                                        child: Column(
                                                          children: <Widget>[
                                                            Text('Worked hours',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    color: HexColor(
                                                                        '3E3E3E'))),
                                                            Text(
                                                                results[index]
                                                                        [
                                                                        'yesterday_wh']
                                                                    .toString(),
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        30,
                                                                    color: HexColor(
                                                                        'EA6012'))),
                                                            Text('Yesterday',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        11,
                                                                    color: HexColor(
                                                                        '3E3E3E')))
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.02,
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
                          'No existen ubicaciones asociadas',
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
