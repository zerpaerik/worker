import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:worker/providers/url_constants.dart';

import '../../../model/gender.dart';
import '../../../model/user.dart';
import '../../../model/states.dart';

import '../../../providers/auth.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'part_oblig.dart';

class ViewProfileAddress extends StatefulWidget {
  static const routeName = '/view-my-profile-address';

  final User user;

  ViewProfileAddress({required this.user});

  @override
  _ViewProfileAddressState createState() => new _ViewProfileAddressState(user);
}

class _ViewProfileAddressState extends State<ViewProfileAddress> {
  late User user;
  _ViewProfileAddressState(this.user);

  late List data = [];
  late String _valDocI;
  late String street = "";
  late String zip_code = "";
  late String state_n = "";
  String city = "";
  String secondary = "";
  String addres_f = "";
  late int entries;
  var selectedValue;
  List names = [];
  List filteredNames = [];
  List dataStates = [];
  List dataCitys = [];
  int stateFin = 0;
  int cityFin = 0;
  var _isLoading = false;

  final myController = TextEditingController();
  final myController2 = TextEditingController();

  Future<dynamic> findAddress(value) async {
    var res = await http.get(
        Uri.parse(
            'https://us-autocomplete-pro.api.smartystreets.com/lookup?key=24332005472817723&search=$value'),
        headers: {"Referer": "$urlServices"});
    var resBody = json.decode(res.body);

    setState(() {
      if (resBody['errors'] != null) {
        _showErrorDialog(
            'Error consultando a Smarty Streets. Espere unos minutos');
      }
      if (resBody['suggestions'] != null) {
        data = resBody['suggestions'];
      }
    });
    print(resBody);
  }

  void _showErrorDialog(String message) {
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

  Future<dynamic> findAddressEntries(street, sec, ci, sta, zip, ent) async {
    var url =
        'https://us-autocomplete-pro.api.smartystreets.com/lookup?key=24332005472817723&search=$street&selected=$street+$sec+($ent)+$ci+$sta+$zip';
    print(url);

    var res = await http.get(
        Uri.parse(
            'https://us-autocomplete-pro.api.smartystreets.com/lookup?key=24332005472817723&search=$street&selected=$street+$sec+($ent)+$ci+$sta+$zip'),
        headers: {"Referer": "$urlServices"});
    var resBody = json.decode(res.body);

    setState(() {
      data = resBody['suggestions'];
    });
    print('respuesta despues de entries');
    setState(() {
      // state_n = resBody['state'];
      //city = resBody['city'];
      //zip_code = resBody['zipcode'];
    });
    print(resBody);
  }

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getSWState() async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse(ApiWebServer.server_name + '/api/v-1/address/state'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      dataStates = resBody;
    });

    print(dataStates);

    return "Sucess";
  }

  Future<dynamic> getSWData1(int state) async {
    String token = await getToken();

    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/address/state/$state/city'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      dataCitys = resBody;
      dataCitys.forEach((element) {
        if (element['name'].toString() == city) {
          setState(() {
            cityFin = element['id'];
          });
        }
      });
    });

    return "Sucess";
  }

  Future<dynamic> _updateAddress() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<Auth>(context, listen: false)
          .updateAddressNew(
              stateFin, city, myController.text, myController2.text, zip_code)
          .then((response) {
        setState(() {
          _isLoading = false;
        });

        if (response == '200') {
          print('updateada la direccion');
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewProfileOblig(
                      user: widget.user,
                    )),
          );
        }
        //
      });
    } catch (error) {}
  }

  _printLatestValue() {
    print("Second text field: ${myController.text}");
  }

  @override
  void initState() {
    this.getSWState();
    super.initState();
    myController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Limpia el controlador cuando el widget se elimine del árbol de widgets
    // Esto también elimina el listener _printLatestValue
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd");
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      //endDrawer: EndDrawer(),
      body: Form(
        child: ListView(
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
                    'assets/direccion.png',
                    width: 70,
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
                    l10n.address,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(l10n.address_o,
                  style: TextStyle(fontSize: 18, color: HexColor('EA6012'))),
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  controller: myController,
                  onChanged: (value) {
                    if (value.length != 0) {
                      findAddress(value);
                    }
                  },
                )),
            Container(
              margin: EdgeInsets.only(left: 30, right: 30, top: 10),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(
                  '',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                        onTap: () {
                          if (data[index]['entries'] > 1) {
                            print('varias direcciones');

                            findAddressEntries(
                                data[index]['street_line'],
                                data[index]['secondary'],
                                data[index]['city'],
                                data[index]['state'],
                                data[index]['zipcode'],
                                data[index]['entries']);
                          } else {
                            setState(() {
                              street = data[index]['street_line'];
                              secondary = data[index]['secondary'];
                              myController2.text = secondary;
                              state_n = data[index]['state'];
                              city = data[index]['city'];
                              zip_code = data[index]['zipcode'];
                              data = [];
                              myController.text = street +
                                  '' +
                                  secondary +
                                  ' ' +
                                  city +
                                  ' ' +
                                  state_n +
                                  ',' +
                                  zip_code;
                            });
                            dataStates.forEach((element) {
                              if (element['code'].toString() == state_n) {
                                print('datos de estado seleccionador');
                                setState(() {
                                  stateFin = element['id'];
                                  getSWData1(stateFin);
                                });
                                print(element);
                              }
                            });

                            /* setState(() {
                          street = data[index]['street_line'];
                          secondary = data[index]['secondary'];
                          state_n = data[index]['state'];
                          city = data[index]['city'];
                          zip_code = data[index]['zipcode'];
                          data = [];
                        });*/

                            print(street);
                            print(secondary);
                            print(state_n);

                            print('una sola direccion');
                          }
                        },
                        child: Container(
                            alignment: Alignment.topLeft,
                            child: data[index]['entries'] > 1
                                ? Column(
                                    children: [
                                      Text(
                                        '${data[index]['street_line']} ${data[index]['secondary']} ${data[index]['city']}, ${data[index]['state']} ${data[index]['zipcode']} Entries:${data[index]['entries']}',
                                        style: TextStyle(
                                            //color: Colors.grey,
                                            // fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      )
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Text(
                                        '${data[index]['street_line']} ${data[index]['secondary']} ${data[index]['city']}, ${data[index]['state']} ${data[index]['zipcode']}',
                                        style: TextStyle(fontSize: 16),
                                      ),
                                      SizedBox(
                                        height: 4,
                                      )
                                    ],
                                  )));
                  },
                )),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(l10n.house,
                  style: TextStyle(fontSize: 18, color: HexColor('EA6012'))),
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: TextFormField(
                  controller: myController2,
                  onChanged: (value) {
                    setState(() {});
                  },
                )),
            /* Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(secondary,
                  style: GoogleFonts.montserrat(
                      textStyle: TextStyle(
                    fontSize: 17,
                  ))),
            ),*/
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(l10n.city_n,
                  style: TextStyle(fontSize: 18, color: HexColor('EA6012'))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(city,
                  style: TextStyle(
                    fontSize: 17,
                  )),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(l10n.state_n,
                  style: TextStyle(fontSize: 18, color: HexColor('EA6012'))),
            ),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(state_n,
                  style: TextStyle(
                    fontSize: 17,
                  )),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(
                left: 30,
                right: 30,
              ),
              alignment: Alignment.topLeft,
              child: Text(l10n.zip_code,
                  style: TextStyle(fontSize: 18, color: HexColor('EA6012'))),
            ),
            Container(
                margin: EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                alignment: Alignment.topLeft,
                child: Text(zip_code,
                    style: TextStyle(
                      fontSize: 17,
                    ))),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30),
              //width: MediaQuery.of(context).size.width * 0.70,
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: stateFin == 0 ? null : _updateAddress,
                      child: Text(
                        l10n.next,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
