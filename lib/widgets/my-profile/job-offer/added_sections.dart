import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../model/user.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'package:worker/model/certification.dart';

import 'list.dart';

class AAddedSectionsOffer extends StatefulWidget {
  static const routeName = '/my-jobs-sections';
  final User user;
  final String sections;
  final String check;

  AAddedSectionsOffer(
      {required this.user, required this.sections, required this.check});

  @override
  _AAddedSectionsOfferState createState() =>
      _AAddedSectionsOfferState(user, sections, check);
}

class _AAddedSectionsOfferState extends State<AAddedSectionsOffer> {
  late User user;
  late String sections;
  late String check;
  _AAddedSectionsOfferState(this.user, this.sections, this.check);

  late bool address = false;

  late final String url =
      '${ApiWebServer.server_name}/api/v-1/contract/joboffer/';

  Map<String, dynamic> data = {};
  late var benefitsO;
  late Certification crt;
  late String isData = '';

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  @override
  void initState() {
    super.initState();
    AutoOrientation.portraitAutoMode();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    void _showErrorInput(String message) {
      print(message);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error!'),
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

    print(sections);
    return Scaffold(
      body: SingleChildScrollView(
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
                        if (address == true) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JobOfferPage(
                                      user: widget.user,
                                    )),
                          );
                        } else {
                          _showErrorInput('');
                        }
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
              child: Text(l10n.additional_sections,
                  style: TextStyle(
                      fontSize: 25,
                      color: HexColor('EA6012'),
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 0.45,
            width: MediaQuery.of(context).size.width * 0.92,
            child: SingleChildScrollView(
                child: Column(children: <Widget>[
              Container(
                margin:
                    EdgeInsets.only(left: 10, right: 10, top: 10, bottom: 5),
                child:
                    /*Text(
                            data['contract']['contracting_conditions'],
                            style: TextStyle(color: Colors.grey, fontSize: 17),
                            textAlign: TextAlign.justify,
                          )*/
                    Html(
                  data: sections,
                ),
              ),
            ])),
          ),
          SizedBox(height: 10),
          Row(children: <Widget>[
            Container(
                margin: EdgeInsets.only(left: 17, right: 5),
                child: Checkbox(
                  activeColor: HexColor('EA6012'),
                  value: address,
                  onChanged: (value) async {
                    setState(() {
                      address = value!;
                    });
                  },
                )),
            Container(
                // margin: EdgeInsets.only(right: 40),
                child: Expanded(
              child: Text(l10n.accept_sections,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.left,
                  style: TextStyle(color: HexColor('EA6012'), fontSize: 20)),
            ))
          ]),
          SizedBox(height: 30),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(right: 30),
            //width: MediaQuery.of(context).size.width * 0.70,
            child: ElevatedButton(
              onPressed: () {
                if (address == true) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => JobOfferPage(
                              user: this.widget.user,
                            )),
                  );
                } else {
                  _showErrorInput(l10n.accep_sections_check);
                }
              },
              child: Text(
                l10n.submit,
                style: TextStyle(
                    // fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      )),
    );
  }
}
