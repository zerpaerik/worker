import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../model/user.dart';
import '../../model/workday_register.dart';

import '../global.dart';
import '../widgets.dart';

class ListWorkdayReports extends StatefulWidget {
  static const routeName = '/workday-page';
  final User? user;
  int? contract;

  ListWorkdayReports({this.user, this.contract});

  @override
  _ListWorkdayReportsState createState() =>
      _ListWorkdayReportsState(user, contract);
}

class _ListWorkdayReportsState extends State<ListWorkdayReports> {
  User? user;
  int? contract;

  _ListWorkdayReportsState(this.user, this.contract);
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  int? selectedRadio;
  bool _isData = false;

  final String url =
      '${ApiWebServer.server_name}/api/v-1/workday/80/workday-report/worker-report/';

  //List data = List();
  List? data = [];
  Map<String, dynamic>? dataw;
  Map<String, dynamic>? data1;

  String isData = '';

  // FOR EDIT DATA

  var drivers;
  final _form = GlobalKey<FormState>();

  // ignore: unused_field
  int _selectedIndex = 4;

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  void _showScaffold(String message) {}

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  Future<String> getSWData() async {
    String token = await getToken();
    String contract = widget.contract.toString();
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$contract/workday-report/'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);
    print(resBody);

    if (res.statusCode == 200) {
      setState(() {
        _isData = true;
      });
      if (resBody.length == 0) {
        print('no hay data');
        setState(() {
          isData = 'N';
        });
      } else {
        print('hay data');
        setState(() {
          isData = 'Y';
          data = resBody;
        });
      }
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  @override
  void initState() {
    getSWData();
    selectedRadio = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      body: !_isData
          ? Center(
              child: CircularProgressIndicator(),
            )
          : isData == 'Y'
              ? ListView(
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
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
                          child: Image.asset('assets/002-data.png',
                              width: 50, color: HexColor('EA6012')),
                        )),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Text(l10n.daily_report,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: HexColor('EA6012'))),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    SingleChildScrollView(
                      child: _getListWorkDay(),
                    )
                  ],
                )
              : _getBase()
      // ignore: unrelated_type_equality_checks
      ,
      /*  bottomNavigationBar: AppBarButton(
        user: user,
        selectIndex: 0,
      ),*/
    );
  }

  Widget _getBase() {
    return Center(
      child: Container(
          margin: EdgeInsets.only(top: 50),
          child: Column(children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.20),
            Image.asset('assets/002-data.png',
                width: 100, color: HexColor('EA6012')),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Text('No hay reportes creados',
                style: TextStyle(
                    fontSize: 25,
                    color: HexColor('EA6012'),
                    fontWeight: FontWeight.bold)),
            SizedBox(height: MediaQuery.of(context).size.width * 0.02),
          ])),
    );
  }

  Widget _getListWorkDay() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
        height: MediaQuery.of(context).size.height * 0.75,
        child: ListView.builder(
          itemCount: data!.length,
          itemBuilder: (context, index) {
            return Card(
              /* shape: (selectedIndex == position)
            ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.green, width: 2))
            : null,*/
              //elevation: 6,
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Row(
                    children: <Widget>[
                      Expanded(
                        flex: 2,
                        child: Container(
                          //color: HexColor('009444'),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 10),
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.90,
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      /*
                            data[index]['workday_entry_time'] != null
                                ? AppTranslations.of(context).text("date") +
                                    ' ' +
                                    '${data[index]['workday_entry_time'].substring(0, 10)}'
                                : ''*/
                                      DateFormat("MMMM d yyyy").format(
                                          DateTime.parse(
                                              data![index]['created'])),
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: HexColor('EA6012'),
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.left,
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(l10n.wr_20 + ': ',
                                        style: TextStyle(
                                          fontSize: 16,
                                        )),
                                  ),
                                  Container(
                                    child: Text(
                                        data![index]['worked_hours']
                                                        .toString() ==
                                                    'None' ||
                                                data![index]['worked_hours']
                                                        .toString() ==
                                                    '0:00:00'
                                            ? 'S/H'
                                            : data![index]['worked_hours']
                                                        .toString()
                                                        .length >
                                                    3
                                                ? data![index]['worked_hours']
                                                    .toString()
                                                : data![index]['worked_hours']
                                                    .toString(),
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: HexColor('EA6012'),
                                            fontWeight: FontWeight.bold)),
                                  )
                                ],
                              )
                              /*Text(
                                  'Horas T: ' +
                                      data[index]['worked_hours']
                                          .toString()
                                          .substring(0, 4),
                                  style: GoogleFonts.montserrat(
                                      textStyle: TextStyle(
                                          fontSize: 16,
                                          color: HexColor('EA6012'),
                                          fontWeight: FontWeight.bold)))*/
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          //color: HexColor('009444'),
                          alignment: Alignment.topRight,
                          margin: EdgeInsets.only(right: 10, top: 5),
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.10,
                          child: data![index]['status'].toString() == '1'
                              ? Text(
                                  l10n.wr_21,
                                  style: TextStyle(
                                      color: Colors.red,
                                      // fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                )
                              : data![index]['status'].toString() == '2'
                                  ? Text(l10n.wr_22,
                                      style: TextStyle(
                                          color: Colors.blue,
                                          //fontWeight: FontWeight.bold,
                                          fontSize: 16))
                                  : Text('Finalizado',
                                      style: TextStyle(
                                          color: Colors.green,
                                          //  fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                        ),
                      ),
                    ],
                  ),

                  Divider(
                    color: Colors.grey[200],
                    // height: 1,
                    thickness: 2,
                    indent: 15,
                    endIndent: 15,
                  ),

                  Row(children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.center,
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset('assets/001-clock.png', width: 30),
                            SizedBox(
                              height: 5,
                            ),
                            const Text(
                              'Clock-in',
                              style: TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            Text(data![index]['clock_in_start'].toString() ==
                                    'null'
                                ? 'S/J'
                                : '${data![index]['clock_in_start'].toString().substring(11, 16)}' /*'${data[index]['clock_in_start'].toString().substring(11, 16)}'*/),
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
                        width: MediaQuery.of(context).size.width * 0.25,
                        child: Column(
                          children: <Widget>[
                            Image.asset(
                              'assets/002-clock-1.png',
                              width: 30,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text('Clock-out',
                                style: TextStyle(
                                    fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center),
                            Text(/* '${data[index]['clock_out_start'].toString().substring(11, 16)}'*/ data![
                                            index]['clock_out_start']
                                        .toString() ==
                                    'null'
                                ? 'S/J'
                                : '${data![index]['clock_out_start'].toString().substring(11, 16)}'),
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
                        width: MediaQuery.of(context).size.width * 0.25,
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
                            Text(data![index]['workday_entry_time']
                                        .toString() !=
                                    'null'
                                ? '${data![index]['workday_entry_time'].substring(11, 16)}'
                                : 'S/J'),
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
                        width: MediaQuery.of(context).size.width * 0.25,
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
                            Text(data![index]['workday_departure_time']
                                        .toString() !=
                                    'null'
                                ? '${data![index]['workday_departure_time'].substring(11, 16)}'
                                : 'S/J'),
                          ],
                        ),
                      ),
                    ),
                  ]),
                  SizedBox(
                    height: 10,
                  ),

                  //  SizedBox(height: 5)
                ],
              ),
            );
          },
        ));
  }

  // ignore: unused_element
}
