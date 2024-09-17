import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import '../../providers/auth.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../global.dart';

class DashboardWorker extends StatefulWidget {
  @override
  _DashboardWorkerState createState() => _DashboardWorkerState();
}

class _DashboardWorkerState extends State<DashboardWorker> {
  late Map<String, dynamic> hours = {};
  late Map<String, dynamic> contract = {};
  late Map<String, dynamic> info = {};

  late String isContract = '';

  int _currentIndex = 0;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> _viewHours() async {
    String token = await getToken();
    DateTime now = DateTime.now();

    final response = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/user/worked-hours'),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token" + " " + "$token"
        });
    Map<String, dynamic> userData = json.decode(response.body);
    print(userData);

    if (response.statusCode == 200 && userData.isNotEmpty) {
      setState(() {
        hours = userData;
      });

      print('hours');
      print(hours);
    } else {
      return null;
    }
  }

  Future<dynamic> _viewContract() async {
    String token = await getToken();

    final response = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-2/contract/current'),
        headers: {
          "content-type": "application/json",
          "accept": "application/json",
          "Authorization": "Token" + " " + "$token"
        });
    Map<String, dynamic> resBody = json.decode(response.body);

    setState(() {
      contract = resBody;
      isContract = response.statusCode.toString();
    });

    print('iscon');
    print(isContract);
  }

  @override
  void initState() {
    super.initState();
    _viewHours();
    _viewContract();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return /*CarouselSlider(
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height * 0.37,
        enableInfiniteScroll: true,
        viewportFraction: 1.0,
        enlargeCenterPage: false,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
        // autoPlay: false,
      ),
      items: cardList.map((card) {
        return Builder(builder: (BuildContext context) {
          return Container(
            margin: EdgeInsets.only(left: 20, right: 20),
            width: MediaQuery.of(context).size.width,
            child: Card(
              color: HexColor('F8F8FA'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 5,
              // color: Colors.white,
              child: card,
            ),
          );
        });
      }).toList(),
    );*/
        SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Card(
            elevation: 10,
            margin: EdgeInsets.only(left: 20, right: 20),
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.020,
                ),

                if (isContract == '200') ...[
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(l10n.current_contract,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: HexColor('EA6012'),
                            )),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          contract['contract_name'],
                          style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          contract['contract_owner'].toString(),
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.010,
                  ),
                ],
                if (isContract == '404') ...[
                  Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          l10n.standingby,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      )),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.010,
                  ),
                ],
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      //color: HexColor('009444'),
                      // alignment: Alignment.topLeft,
                      margin: EdgeInsets.only(left: 10),
                      //height: MediaQuery.of(context).size.width * 0.1,
                      child: Text(
                        l10n.total_hours_worked,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: HexColor('EA6012')),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.20,
                        child: Text(
                          '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HexColor('EA6012'),
                              fontSize: 18),
                          textAlign: TextAlign.left,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(left: 10.0),
                              child: Text(
                                  hours != null
                                      ? hours['regular_hours_worked'] != null
                                          ? hours['regular_hours_worked']
                                              .toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 2,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/Regular.png',
                                    width: 15,
                                    // color: Colors.grey[900],
                                  ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text('Regular',
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: HexColor('EA6012')),
                                      textAlign: TextAlign.center),
                                ],
                              ))
                        ],
                      )),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      height: 30, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                  hours != null
                                      ? hours['extra_hours_worked'] != null
                                          ? hours['extra_hours_worked']
                                              .toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/Overtime.png',
                                width: 15,
                                // color: Colors.grey[900],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text('Overtime',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012')),
                                  textAlign: TextAlign.center),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 30, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                  hours != null
                                      ? hours['total_travel_hours'] != null
                                          ? hours['total_travel_hours']
                                              .toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/traveltime.png',
                                width: 15,
                                // color: Colors.grey[900],
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text('Traveling',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012')),
                                  textAlign: TextAlign.center),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 30, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                  hours != null
                                      ? hours['total_standby_hours'] != null
                                          ? hours['total_standby_hours']
                                              .toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            width: 6,
                          ),
                          Row(
                            children: [
                              Image.asset(
                                'assets/standby.png',
                                width: 15,
                                // color: Colors.grey[900],
                              ),
                              SizedBox(
                                width: 2,
                              ),
                              Text('Stand-by',
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012')),
                                  textAlign: TextAlign.center),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ]),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Container(
                  //color: HexColor('009444'),
                  // alignment: Alignment.topLeft,
                  margin: EdgeInsets.only(left: 10),
                  //height: MediaQuery.of(context).size.width * 0.1,
                  child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        l10n.rank_time,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: HexColor('EA6012')),
                        textAlign: TextAlign.left,
                      )),
                ),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),

                Row(children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      //color: HexColor('009444'),
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Center(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.only(left: 10.0),
                              child: Text(
                                  hours != null
                                      ? hours['worked_hours_yesterday'] != null
                                          ? hours['worked_hours_yesterday']
                                              .toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 2,
                          ),
                          Container(
                              margin: EdgeInsets.only(left: 10.0),
                              child: Row(
                                children: [
                                  Image.asset('assets/001-clock.png',
                                      width: 15, color: HexColor('EA6012')
                                      // color: Colors.grey[900],
                                      ),
                                  SizedBox(
                                    width: 6,
                                  ),
                                  Text(l10n.ayer,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: HexColor('EA6012')),
                                      textAlign: TextAlign.center),
                                ],
                              ))
                        ],
                      )),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  Container(
                      height: 30, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                  hours != null
                                      ? hours['hours_last_week'] != null
                                          ? hours['hours_last_week'].toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              Image.asset('assets/7.png',
                                  width: 15, color: HexColor('EA6012')
                                  // color: Colors.grey[900],
                                  ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(l10n.last7,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012')),
                                  textAlign: TextAlign.center),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 30, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Align(
                              alignment: Alignment.topCenter,
                              child: Text(
                                  hours != null
                                      ? hours['monthly_hours'] != null
                                          ? hours['monthly_hours'].toString()
                                          : '0'
                                      : '0',
                                  style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold))),
                          SizedBox(
                            height: 2,
                          ),
                          Row(
                            children: [
                              Image.asset('assets/mensual.png',
                                  width: 15, color: HexColor('EA6012')
                                  // color: Colors.grey[900],
                                  ),
                              SizedBox(
                                width: 3,
                              ),
                              Text(l10n.monthly,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012')),
                                  textAlign: TextAlign.center),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  Container(
                      height: 30, child: VerticalDivider(color: Colors.grey)),
                  Expanded(
                    flex: 1,
                    child: Container(
                      alignment: Alignment.center,
                      //height: MediaQuery.of(context).size.width * 0.1,
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: Column(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topCenter,
                            child: Text(
                              hours != null
                                  ? hours['annual_hours'] != null
                                      ? hours['annual_hours'].toString()
                                      : '0'
                                  : '0',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 6,
                          ),
                          Row(
                            children: [
                              Image.asset('assets/anual.png',
                                  width: 15, color: HexColor('EA6012')
                                  // color: Colors.grey[900],
                                  ),
                              SizedBox(
                                width: 2,
                              ),
                              Text(l10n.annual,
                                  style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: HexColor('EA6012')),
                                  textAlign: TextAlign.center),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ]),

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Container(
                    margin: EdgeInsets.only(left: 10, right: 20),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        l10n.text_confirm_hours,
                        style:
                            TextStyle(fontSize: 12, color: HexColor('EA6012')),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                )

                //  SizedBox(height: 5)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
