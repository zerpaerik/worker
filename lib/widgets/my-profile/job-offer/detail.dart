import 'dart:convert';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';

import '../../../model/user.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'package:worker/model/certification.dart';
import 'package:worker/widgets/my-profile/job-offer/postulation.dart';

import 'list.dart';

class DetailJobOfferPage extends StatefulWidget {
  static const routeName = '/my-jobs';
  final User user;

  final String offer;

  DetailJobOfferPage({required this.user, required this.offer});

  @override
  _DetailJobOfferPageState createState() =>
      _DetailJobOfferPageState(user, offer);
}

class _DetailJobOfferPageState extends State<DetailJobOfferPage> {
  late User user;
  late String offer;
  _DetailJobOfferPageState(this.user, this.offer);

  late int _selectedIndex = 4;

  late final String url =
      ApiWebServer.server_name + '/api/v-2/contract/joboffer/';

  late Map<String, dynamic> data = {};
  late List benefitsO;
  late Certification crt;
  late String isData = '';

  late bool address = false;
  late bool accepta = false;
  late ScrollController scollBarController = ScrollController();

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<dynamic> getSWData() async {
    print('detalle de offerta');
    String token = await getToken();
    var res = await http.get(Uri.parse(url + offer),
        headers: {"Authorization": "Token $token"});
    // var resBody = json.decode(res.body);

    if (res.statusCode == 200) {
      setState(() {
        data = json.decode(utf8.decode(res.bodyBytes));
        benefitsO = data['contract']['benefits'];
        isData = 'Y';
        print('data de worker category');
        print(data['contract']['starting_points']);
      });
    } else {
      print(res.statusCode);
      print('error');
      return 'ok';
    }
  }

  Future<dynamic> readAll() async {
    List<Map<String, dynamic>> dataS;
    dataS = [];

    dataS.add({
      "id": this.widget.offer,
      "read": true,
    });

    String token = await getToken();

    try {
      final response = await http.patch(
          Uri.parse(
              '${ApiWebServer.server_name}/api/v-1/contract/joboffer/read'),
          body: json.encode(dataS),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': "Token" + " " + "$token"
          });
      //final responseData = json.decode(response.body);
      final responseData = json.decode(response.body);
      print('response read');
      print(responseData);
      print(response.statusCode);

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

  @override
  void initState() {
    this.getSWData();
    super.initState();
    this.readAll();
    AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: isData == ''
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
              children: <Widget>[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
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
                                        JobOfferPage(user: widget.user)),
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
                Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(left: 20, top: 5),
                        child: Text(l10n.detail_offer,
                            style: TextStyle(
                                fontSize: 23,
                                color: HexColor('EA6012'),
                                fontWeight: FontWeight.bold)),
                      ),
                    ]),
                SizedBox(
                  height: 15,
                ),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 165),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.offer_location,
                          style: TextStyle(
                              fontSize: 18, color: HexColor('EA6012'))),
                    )),
                Row(children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 21),
                    child: Text(data['contract']['city_name'] ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                      height: 10,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(data['contract']['state'],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                      height: 10,
                      child: VerticalDivider(color: Colors.grey[400])),
                  Container(
                    margin: EdgeInsets.only(left: 10),
                    child: Text(data['contract']['country'],
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center),
                  ),
                ]),
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.worker_category,
                          style: TextStyle(
                            fontSize: 18,
                            color: HexColor('EA6012'),
                          )),
                    )),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          data['worker_category'] != null
                              ? data['worker_category']['name']
                              : "",
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ))),
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.hour_pay,
                          style: TextStyle(
                              fontSize: 18, color: HexColor('EA6012'))),
                    )),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '\$ ' +
                              (data['worker_category'] != null
                                  ? data['worker_category']
                                      ['regular_hour_worker']
                                  : ""),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ))),
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.hour_extra,
                          style: TextStyle(
                              fontSize: 18, color: HexColor('EA6012'))),
                    )),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          '\$ ' +
                              (data['worker_category'] != null
                                  ? data['worker_category']['extra_hour_worker']
                                  : ""),
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ))),
                SizedBox(height: 10),
                /*  Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          AppTranslations.of(context).text("hour_travel"),
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  fontSize: 18, color: HexColor('EA6012')))),
                    )),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          data['worker_category']['travel_hour_worker'],
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            fontSize: 16,
                          )),
                        ))),
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                          AppTranslations.of(context).text("hour_stand"),
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                                  fontSize: 18, color: HexColor('EA6012')))),
                    )),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          data['worker_category']['standby_hour_worker'],
                          style: GoogleFonts.montserrat(
                              textStyle: TextStyle(
                            fontSize: 16,
                          )),
                        ))),*/
                SizedBox(height: 10),
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(l10n.conditions,
                          style: TextStyle(
                              fontSize: 18, color: HexColor('EA6012'))),
                    )),
                SizedBox(height: 5),
                Container(
                    height: MediaQuery.of(context).size.height * 0.40,
                    width: MediaQuery.of(context).size.width * 0.92,
                    child: Scrollbar(
                      thumbVisibility: true,
                      controller: scollBarController,
                      child: ListView(
                          controller: scollBarController,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(
                                  left: 10, right: 10, bottom: 5),
                              child: Html(
                                data: data['contract']
                                            ['contracting_conditions'] !=
                                        ''
                                    ? data['contract']['contracting_conditions']
                                    : 'N/A',
                              ),
                            ),
                            Row(children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(left: 17),
                                  child: Checkbox(
                                    activeColor: HexColor('EA6012'),
                                    value: address,
                                    onChanged: (value) async {
                                      setState(() {
                                        address = value!;
                                        accepta = value;
                                      });
                                      print(address);
                                    },
                                  )),
                              Container(
                                margin: EdgeInsets.only(right: 20),
                                child: Text(l10n.accept_conditions,
                                    style: TextStyle(
                                      fontSize: 18,
                                    )),
                              )
                            ]),
                          ]),
                    )),
                SizedBox(height: 10),
                if (data['is_accepted'] == true) ...[
                  Container(
                      // margin: EdgeInsets.only(left: 55, right: 10, top: 32),
                      child: Text(
                    l10n.you_applied,
                    style: TextStyle(
                        fontSize: 23,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold),
                  ))
                ],
                SizedBox(height: 10),
                if (data['is_accepted'] == false) ...[
                  Container(
                    alignment: Alignment.topRight,
                    margin: EdgeInsets.only(right: 30),
                    //width: MediaQuery.of(context).size.width * 0.70,
                    child: ElevatedButton(
                      onPressed: () {
                        if (address && data['worker_category'] != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PostulationPage(
                                    user: this.widget.user,
                                    offer: this.widget.offer,
                                    detail: data)),
                          );
                        } else {}
                      },
                      child: Text(
                        l10n.apply,
                        style: TextStyle(
                            // fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white),
                      ),
                    ),
                  )
                ],
              ],
            )),
    );
  }

  renderBenefits(benefitsO) {
    return Column(
        children: benefitsO
            .map<Widget>((ben) =>
                //Mostar items
                Container(
                    margin: EdgeInsets.only(left: 21, right: 21),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child:
                          Text((ben['concept'] != null) ? ben['concept'] : '',
                              style: TextStyle(
                                fontSize: 16,
                              )),
                    )))
            .toList());
  }
}
