import 'dart:convert';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart' show DateFormat;

import '../../../model/config.dart';
import '../../global.dart';
import '../../widgets.dart';
import '../../../model/user.dart';
import '../../../model/certification.dart';
import '../index.dart';
import 'detail.dart';

class JobOfferPage extends StatefulWidget {
  static const routeName = '/my-jobs';
  final User user;

  JobOfferPage({required this.user});

  @override
  _JobOfferPageState createState() => _JobOfferPageState(user);
}

class _JobOfferPageState extends State<JobOfferPage> {
  late User user;
  _JobOfferPageState(this.user);

  // ignore: unused_field
  late int _selectedIndex = 4;

  late final String url =
      '${ApiWebServer.server_name}/api/v-2/contract/joboffer';
  late final String url1 =
      '${ApiWebServer.server_name}/api/v-1/contract/joboffer/accepted';

  late List data = [];
  late List data1 = [];
  late Certification crt;
  late String isData = '';
  late String isData1 = '';
  late bool reading = false;
  late Config config;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<String> getSWData() async {
    String token = await getToken();
    var res = await http
        .get(Uri.parse(url), headers: {"Authorization": "Token $token"});
    var resBody = json.decode(utf8.decode(res.bodyBytes));
    print(resBody);

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

  Future<dynamic> readAll(list) async {
    List<Map<String, dynamic>> dataS;
    dataS = [];

    list.asMap().forEach((i, value) {
      dataS.add({
        "id": value['id'],
        "read": true,
      });
    });

    String token = await getToken();
    setState(() {
      reading = true;
    });

    try {
      final response = await http.patch(
          Uri.parse(
              ApiWebServer.server_name + '/api/v-1/contract/joboffer/read'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print(responseData);
      print(response.statusCode);

      if (response.statusCode == 200) {
        setState(() {
          reading = false;
        });
        _showReads();
        this.getSWData();
      }

      Map<String, dynamic> success = {
        "status": response.statusCode.toString(),
        "data": responseData
      };

      return success;
    } catch (error) {
      print(error);
      throw error;
    }
  }

  void _showReads() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Container(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/aceptar-1.png',
                width: 80,
                color: HexColor('EA6012'),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
                margin: EdgeInsets.only(left: 10, right: 10),
                alignment: Alignment.center,
                child: Text('¡Leidas correctamente!'))
          ],
        ),
        titleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          color: HexColor('EA6012'),
          fontSize: 17,
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Ok',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: HexColor('EA6012'),
                  fontSize: 17,
                )),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    this.getSWData();
    super.initState();
    AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: ListView(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.02,
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
                        //Navigator.of(context).pop();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MyProfile(
                                    user: widget.user,
                                  )),
                        );
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
                    child: Text(''),
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(left: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Image.asset(
                'assets/offer.jpeg',
                width: 50,
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.01),
          Container(
            margin: EdgeInsets.only(left: 30, right: 30),
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(l10n.my_job_offers,
                  style: TextStyle(
                      fontSize: 25,
                      color: HexColor('EA6012'),
                      fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.01,
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
                      margin: EdgeInsets.only(left: 10, right: 10),
                      height: MediaQuery.of(context).size.height * 0.70,
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 5,
                              margin:
                                  EdgeInsets.only(top: 5, left: 20, right: 20),
                              //shape: Border.all(color: HexColor('EA6012'), width: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  side: BorderSide(
                                      color: data[index]['read'] != true
                                          ? HexColor('EA6012')
                                          : Colors.grey,
                                      width: 1)),
                              color: Colors.white,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                            left: 15, right: 80, top: 15),
                                        child: Text(
                                          data[index]['customer'] ?? "",
                                          style: TextStyle(
                                              fontSize: 18,
                                              color: data[index]['read'] != true
                                                  ? HexColor('EA6012')
                                                  : Colors.grey,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                      if (data[index]['read'] == true) ...[
                                        Container(
                                          margin: EdgeInsets.only(
                                              left: 15, right: 10, top: 15),
                                          child: Text(
                                            l10n.reads,
                                            style: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey,
                                                fontWeight: FontWeight.bold),
                                            textAlign: TextAlign.left,
                                          ),
                                        )
                                      ],
                                    ],
                                  ),
                                  Divider(
                                    color: Colors.grey[200],
                                    // height: 1,
                                    thickness: 1,
                                    indent: 15,
                                    endIndent: 15,
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                              // margin: EdgeInsets.only(right: 70),
                                              child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    l10n.date,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))),
                                          //data[index]['created']data[index]['created']
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: Text(data[index]['created']
                                                .toString()),
                                          )
                                        ],
                                      )),
                                  Divider(
                                    color: Colors.grey[200],
                                    // height: 1,
                                    thickness: 1,
                                    indent: 15,
                                    endIndent: 15,
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 15),
                                      child: Row(
                                        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Container(
                                              // margin: EdgeInsets.only(right: 70),
                                              child: Align(
                                                  alignment: Alignment.topLeft,
                                                  child: Text(
                                                    l10n.offer_location,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ))),
                                          Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                  '${data[index]['city']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.normal)))
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
                                        //color: HexColor('009444'),
                                        alignment: Alignment.center,
                                        //height: MediaQuery.of(context).size.width * 0.1,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.33,
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset('assets/contrato.png',
                                                width: 25, color: Colors.black),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              l10n.start_date,
                                              style: TextStyle(
                                                fontSize: 10,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                                data[index]['start_date']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                        height: 50,
                                        child: VerticalDivider(
                                            color: Colors.grey[400])),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        //color: HexColor('009444'),
                                        alignment: Alignment.center,
                                        //height: MediaQuery.of(context).size.width * 0.1,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.33,
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset('assets/efectivo.png',
                                                width: 25, color: Colors.black),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(l10n.pay_hour,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.center),
                                            Text(
                                                data[index]['worker_category'] !=
                                                        null
                                                    ? data[index][
                                                                'worker_category']
                                                            [
                                                            'regular_hour_worker']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                        height: 50,
                                        child: VerticalDivider(
                                            color: Colors.grey[400])),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        //color: HexColor('009444'),
                                        alignment: Alignment.center,
                                        //height: MediaQuery.of(context).size.width * 0.1,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.33,
                                        child: Column(
                                          children: <Widget>[
                                            Image.asset(
                                              'assets/hora_extra.png',
                                              width: 30,
                                              color: Colors.black,
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(l10n.overtime_pay,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                                textAlign: TextAlign.center),
                                            Text(
                                                data[index]['worker_category'] !=
                                                        null
                                                    ? data[index][
                                                                'worker_category']
                                                            [
                                                            'extra_hour_worker']
                                                        .toString()
                                                    : '0',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                                  SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01),
                                  SizedBox(
                                      width: 800,
                                      height: 25,
                                      // margin: EdgeInsets.only(left: 190),
                                      //padding: EdgeInsets.only(left: 60, right: 60),
                                      child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    HexColor('EA6012')),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailJobOfferPage(
                                                          user: widget.user,
                                                          offer:
                                                              '${data[index]['id']}')),
                                            );
                                          },
                                          child: Text(
                                            l10n.see_detail,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Colors.white,
                                                // letterSpacing: 2,
                                                fontWeight: FontWeight.bold),
                                          ))),
                                  //  SizedBox(height: 5)
                                ],
                              ),
                            );
                          }))
                  : Column(
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.10),
                        Align(
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/work.png',
                              color: HexColor('EA6012'),
                              width: 150,
                            )),
                        SizedBox(height: 20),
                        Container(
                            margin: EdgeInsets.only(left: 20, right: 20),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                'No tienes ofertas recibidas',
                                style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: HexColor('EA6012')),
                                textAlign: TextAlign.justify,
                              ),
                            )),
                      ],
                    ),
        ],
      ),
    );
  }
}
