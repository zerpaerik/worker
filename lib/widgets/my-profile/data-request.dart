import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/widgets/dashboard/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;

import '../../model/user.dart';
import '../global.dart';

class DataRequestProfile extends StatefulWidget {
  static const routeName = '/data-request-profile';
  final User user;

  DataRequestProfile({required this.user});

  @override
  _DataRequestProfileState createState() => _DataRequestProfileState(user);
}

class _DataRequestProfileState extends State<DataRequestProfile> {
  late User user;
  _DataRequestProfileState(this.user);
  late List _selectWorkers = [];
  late int selectedRadio = 0;

  final String url = ApiWebServer.server_name + '/api/v-1/workday/77/detail';

  //List data = List();
  late List data = [];
  late Map<String, dynamic> dataw;
  late Map<String, dynamic> data1;

  late String isData = '';
  late bool _isEdit = false;
  late bool _selectw = false;
  late bool ondata = false;

  // ignore: unused_field
  late int _selectedIndex = 4;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<String> getSWData() async {
    String token = await getToken();
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/user/data-requests'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    if (res.statusCode == 200) {
      setState(() {
        data = resBody;
        if (data.isNotEmpty) {
          isData = 'Y';
        } else {
          isData = 'N';
        }
      });
    } else {
      // print(res.statusCode);
    }

    return "Sucess";
  }

  void _showDetail(data, image, comments) {
    print(image);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
            height: 400,
            child: Column(
              children: <Widget>[
                if (data == '1') ...[
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        'En revisión',
                        style: TextStyle(
                            color: HexColor('233062'),
                            fontWeight: FontWeight.bold),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Image.asset(
                        'assets/revisar.png',
                        width: 30,
                      ))
                ],
                if (data == '2') ...[
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        'Rechazado',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.bold),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Image.asset(
                        'assets/cancelar.png',
                        width: 30,
                      ))
                ],
                if (data == '3') ...[
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Text(
                        'Aceptado',
                        style: TextStyle(
                            color: HexColor('009444'),
                            fontWeight: FontWeight.bold),
                      )),
                  Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Image.asset(
                        'assets/aceptar-1.png',
                        width: 30,
                      ))
                ],
                SizedBox(
                  height: 10,
                ),
                Container(
                  child: Image.network(
                    image,
                    height: 250,
                  ),
                ),
                SizedBox(
                  height: 10,
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
                                  'Comentarios:',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 18),
                                ))),
                        Container(
                            margin: EdgeInsets.only(left: 5),
                            child: comments != null
                                ? Text(
                                    comments,
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : Text(
                                    'S/C',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )),
                      ],
                    )),
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: TextButton(
                    child: Text(
                      'Accept',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: HexColor('EA6012')),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                  ),
                )
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
    this.getSWData();
    selectedRadio = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        body: Column(
      // Column
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.08,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                margin: EdgeInsets.only(left: 5),
                alignment: Alignment.topLeft,
                //height: MediaQuery.of(context).size.width * 0.1,
                width: MediaQuery.of(context).size.width * 0.50,
                child: Container(
                  child: Text(''),
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
            child: Text(l10n.list_moderate,
                style: TextStyle(
                    fontSize: 25,
                    color: HexColor('EA6012'),
                    fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.01,
        ),
        SizedBox(
          height: 10,
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
                ? _getListCert()
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
                              'No tienes ajustes pendientes',
                              style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: HexColor('EA6012')),
                              textAlign: TextAlign.justify,
                            ),
                          )),
                    ],
                  )
      ],
    ));
  }

  Widget _getListCert() {
    return Container(
        height: 120,
        margin: EdgeInsets.all(5),
        child: ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return Card(
              /* shape: (selectedIndex == position)
            ? RoundedRectangleBorder(
                side: BorderSide(color: Colors.green, width: 2))
            : null,*/
              elevation: 10,
              margin: EdgeInsets.only(top: 10, left: 20, right: 20),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 15, right: 80, top: 15),
                        child: Text(
                          'Date: ${data[index]['created'].toString().substring(0, 10)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: HexColor('EA6012'),
                              fontSize: 17),
                          textAlign: TextAlign.left,
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
                                    'Estatus de Solicitud:',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 18),
                                  ))),
                          if (data[index]['status'] == '1') ...[
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  'En revisión',
                                  style: TextStyle(
                                      color: HexColor('233062'),
                                      fontWeight: FontWeight.bold),
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Image.asset(
                                  'assets/revisar.png',
                                  width: 30,
                                ))
                          ],
                          if (data[index]['status'] == '2') ...[
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  'Rechazado',
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold),
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Image.asset(
                                  'assets/cancelar.png',
                                  width: 30,
                                ))
                          ],
                          if (data[index]['status'] == '3') ...[
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Text(
                                  'Aceptado',
                                  style: TextStyle(
                                      color: HexColor('009444'),
                                      fontWeight: FontWeight.bold),
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 5),
                                child: Image.asset(
                                  'assets/aceptar-1.png',
                                  width: 30,
                                ))
                          ],
                        ],
                      )),

                  SizedBox(height: 10),
                  SizedBox(
                      width: 800,
                      height: 30,
                      // margin: EdgeInsets.only(left: 190),
                      //padding: EdgeInsets.only(left: 60, right: 60),
                      child: ElevatedButton(
                          onPressed: () {
                            _showDetail(data[index]['status'],
                                data[index]['photo'], data[index]['comments']);
                          },
                          child: const Text(
                            'Ver Detalle',
                            style: TextStyle(
                              color: Colors.white,
                              letterSpacing: 1,
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ))),

                  //  SizedBox(height: 5)
                ],
              ),
            );
          },
        ));
  }

  // ignore: unused_element
}
