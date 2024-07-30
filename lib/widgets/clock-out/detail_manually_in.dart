import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/workday.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../../model/user.dart';
import '../../providers/workday.dart';
import '../widgets.dart';

// ignore: must_be_immutable
class DetailManuallyClockOutIn extends StatefulWidget {
  final Map<String, dynamic>? user;
  final Workday? workday;
  final String? lat;
  final String? long;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? wk;
  final User? us;

  DetailManuallyClockOutIn(
      {required this.user,
      this.workday,
      this.lat,
      this.long,
      this.contract,
      this.wk,
      this.us});

  @override
  _DetailManuallyClockOutInState createState() =>
      _DetailManuallyClockOutInState(
          user, workday, lat, long, contract, wk, us);
}

class _DetailManuallyClockOutInState extends State<DetailManuallyClockOutIn> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, dynamic> user;
  Workday workday;
  String lat;
  String long;
  Map<String, dynamic> wk;
  User us;

  Map<String, dynamic> contract;

  _DetailManuallyClockOutInState(this.user, this.workday, this.lat, this.long,
      this.contract, this.wk, this.us);
  Geolocator geolocator = Geolocator();

  Position userLocation;
  Workday _wd;
  //DateFormat format = DateFormat("yyyy-MM-dd");
  bool isLoading = false;
  // DateTime hour = DateFormat('HH:mm').format(DateTime.now()) as DateTime;
  final hour = new DateTime.now();
  DateFormat dateFormat = DateFormat("HH:mm:ss");
  String _time = "S/H";
  DateTime hourClock;
  String qrCodeResult = "Not Yet Scanned";
  String temp = '';
  int tm;
  String blood = '';

  String _locationMessage = "";
  String comments;

  // String formatter = DateFormat('yMd').format(hour);
  //int time = DateTime.now().millisecondsSinceEpoch;
  //String t = "$time";

  todayDateTime() {
    var now = new DateTime.now();
    String formattedTime = DateFormat('hh:mm:aa').format(now);
    return formattedTime;
  }

  todayDateTimeWork() {
    var now = this.widget.workday.clock_in_start;
    String formattedTime = DateFormat('hh:mm:aa').format(now);
    return formattedTime;
  }

  Future<Position> _getLocation() async {
    var currentLocation;
    try {
      currentLocation = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int intValue = contract.getInt('intValue');
    return intValue;
  }

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppTranslations.of(context).text("error")),
        content: Text(message),
        titleTextStyle: TextStyle(
            color: HexColor('373737'),
            fontFamily: 'OpenSansRegular',
            fontWeight: FontWeight.bold,
            fontSize: 20),
        actions: <Widget>[
          FlatButton(
            child: Text('Ok'),
            textColor: HexColor('EA6012'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });

    String geo;

    if (userLocation != null) {
      geo = userLocation.latitude.toString() +
          ' ' +
          userLocation.longitude.toString();
    } else {
      geo = '--- ---';
    }

    try {
      Provider.of<WorkDay>(context, listen: false)
          .addClockInM(this.widget.workday.id, this.widget.user['id'],
              hourClock, comments, geo, temp)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailManuallyClockOut(
                    user: this.widget.user,
                    workday: this.widget.workday,
                    us: this.widget.us,
                    contract: this.widget.contract,
                    wk: this.widget.wk)),
          );
        } else {
          _showErrorDialog('Error');
        }
      });
    } catch (error) {}
  }

  void _showWorker() {
    print(user['profile_image'].toString().replaceAll('File: ', ''));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          height: 420,
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    AppTranslations.of(context).text("picture_of") +
                        ' ' +
                        user['first_name'] +
                        ' ' +
                        user['last_name'],
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black)),
                  ),
                ],
              ),
              SizedBox(
                height: 5.0,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0),
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.03,
                    ),
                    Container(
                      child: FadeInImage.assetNetwork(
                        placeholder: 'assets/cargando.gif',
                        image: user['profile_image']
                            .toString()
                            .replaceAll('File: ', '')
                            .replaceAll("'", ""),
                      ),
                    )
                  ],
                ),
              ),
              InkWell(
                child: Container(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  decoration: BoxDecoration(
                    //color: myColor,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32.0),
                        bottomRight: Radius.circular(32.0)),
                  ),
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    child: Text(
                      'Ok',
                      style: TextStyle(
                          color: HexColor('EA6012'),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(this.widget.wk);

    return new Scaffold(
      body: Form(
          key: _formKey,
          child: SingleChildScrollView(
              child: Container(
                  child: Column(children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.04),
            Container(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                      color: HexColor('EA6012'),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: EdgeInsets.only(left: 20),
                    alignment: Alignment.topLeft,
                    //height: MediaQuery.of(context).size.width * 0.1,
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Image.asset(
                            'assets/in.png',
                            color: Colors.black,
                            width: 40,
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 10, right: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              AppTranslations.of(context).text("clockin_17"),
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      color: Colors.black)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(this.widget.contract['contract_name'],
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: HexColor('EA6012')))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('BTN',
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                      fontSize: 17,
                    ))),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(AppTranslations.of(context).text("worker_data"),
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: HexColor('EA6012')))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('Emplooy ID:' + user['btn_id'],
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ))),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showWorker();
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(user['first_name'],
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ))),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                _showWorker();
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(user['last_name'],
                      style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ))),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(AppTranslations.of(context).text("warnings_3"),
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: HexColor('EA6012')))),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/clock1.png',
                    width: 30,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10, top: 12),
                  child: Text(
                    AppTranslations.of(context).text("clockin_26"),
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 60),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    todayDateTime(),
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontSize: 25,
                            color: HexColor('EA6012'),
                            fontWeight: FontWeight.bold)),
                  )),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/termometro.png',
                    width: 30,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    AppTranslations.of(context).text("clockin_8"),
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  width: 50,
                  child: TextFormField(
                    textInputAction: TextInputAction.done,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      setState(() {
                        temp = value;
                        tm = int.parse(temp);
                      });
                    },
                  ),
                ),
                Text('F°')
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/comentarios.png',
                    width: 28,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    AppTranslations.of(context).text("clockout_19"),
                    style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
                  ),
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 60, right: 30),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                    labelText: AppTranslations.of(context).text("description")),
                onChanged: (value) {
                  setState(() {
                    comments = value;
                  });
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30, bottom: 15),
              // margin: EdgeInsets.only(left:15),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : RaisedButton(
                      elevation: 5.0,
                      onPressed: () {
                        print(blood);
                        print(hourClock);
                        if (temp == '') {
                          _showErrorDialog(
                              'La temperatura es obligatoria para el ingreso');
                        } else if (tm >= 100) {
                          _showErrorDialog(
                              'La temperatura del worker es muy elevada');
                        } else if (comments == null) {
                          _showErrorDialog('Debe escribir un comentario');
                        } else {
                          _submit();
                        }
                      },
                      padding: EdgeInsets.only(
                          left: 40, right: 40, top: 10, bottom: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      color: HexColor('EA6012'),
                      child: Text(
                        AppTranslations.of(context).text("accept"),
                        style: GoogleFonts.montserrat(
                            textStyle:
                                TextStyle(fontSize: 20, color: Colors.white)),
                      ),
                    ),
            ),
          ])))),
    );
  }
}
