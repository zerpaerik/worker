import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/workday.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/widgets/projects/crew/cam_scan.dart';
import 'dart:convert';
import '../../global.dart';

import '../../../model/user.dart';
import 'package:http/http.dart' as http;
import '../../../providers/crew.dart';
import '../../widgets.dart';

// ignore: must_be_immutable
class DetailCrew extends StatefulWidget {
  final User? user;
  final int? workday;
  final String? lat;
  final String? long;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? datas;
  Map<String, dynamic>? crew;

  DetailCrew(
      {required this.user,
      this.workday,
      this.lat,
      this.long,
      this.contract,
      this.datas,
      this.crew});

  @override
  _DetailCrewState createState() =>
      _DetailCrewState(user, workday, lat, long, contract, datas, crew);
}

class _DetailCrewState extends State<DetailCrew> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  User? user;
  int? workday;
  Workday? work;
  String? lat;
  String? long;
  Map<String, dynamic>? wk;
  Map<String, dynamic>? datas;

  Map<String, dynamic>? contract;
  User? us;
  Map<String, dynamic>? crew;

  _DetailCrewState(this.user, this.workday, this.lat, this.long, this.contract,
      this.datas, this.crew);
  Geolocator geolocator = Geolocator();

  Position? userLocation;
  Workday? _wd;
  //DateFormat format = DateFormat("yyyy-MM-dd");
  bool isLoading = false;
  // DateTime hour = DateFormat('HH:mm').format(DateTime.now()) as DateTime;
  final hour = DateTime.now();
  DateFormat? dateFormat = DateFormat("HH:mm:ss");
  String _time = "Sin Cambios";
  DateTime? hourClock;
  String qrCodeResult = "Not Yet Scanned";
  String temp = '';
  int? tm;

  String? geo;
  String _locationMessage = "";
  Map<String, dynamic>? crewCurrent;
  List? dataCategory = [];
  String? cate = "";
  var selectedValue;
  String? namec;
  int? category;
  String type = "IN";

  // String formatter = DateFormat('yMd').format(hour);
  //int time = DateTime.now().millisecondsSinceEpoch;
  //String t = "$time";

  todayDateTime() {
    var now = new DateTime.now();
    String formattedTime = DateFormat('hh:mm:aa').format(now);
    return formattedTime;
  }

  todayDateTimeWork() {
    //var now = this.widget.wk['clock_in_init'];
    // String formattedTime = DateFormat('hh:mm:aa').format(now);
    //return formattedTime;
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
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  void _showErrorDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text(message,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: HexColor('EA6012'))),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => QRSCANCREW(
                          workday: widget.workday,
                          contract: widget.contract,
                          crew: widget.crew,
                        )),
              );
            },
          )
        ],
      ),
    );
  }

  void _showInfoDialog(String message) {
    print(message);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Atenciòn, verifique por favor!'),
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
              _submit();
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
    await getCrew();
    if (crewCurrent!['clock_in_end'] == null) {
      type = "IN";
    } else {
      type = "OUT";
    }

    print('se va a pv');
    print(type);

    try {
      Provider.of<CrewProvider>(context, listen: false)
          .addClockIn(widget.user!.id, _locationMessage, widget.workday, null,
              type, crewCurrent)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        print('response escan');
        if (response == '201') {
          //_scan();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => QRSCANCREW(
                      workday: widget.workday,
                      contract: widget.contract,
                      crew: widget.crew,
                    )),
          );
        } else {
          _showErrorDialog("This QR has already been scanned today");
        }
      });
    } catch (error) {}

    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  void _showWorker() {
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
                    // ignore: prefer_interpolation_to_compose_strings
                    "Foto de"
                            ' ' +
                        user!.first_name! +
                        ' ' +
                        user!.last_name!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
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
                        image: user!.profile_image
                            .toString()
                            .replaceAll('File: ', '')
                            .replaceAll("'", ""),
                      ) /*Image.network(user.profile_image
                          .toString()
                          .replaceAll('File: ', '')
                          .replaceAll("'", ""))*/
                      ,
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
                  child: TextButton(
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

  Future<String?> getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  Future<String> getCrew() async {
    String? token = await getToken();
    setState(() {});
    var res = await http.get(
        Uri.parse('${ApiWebServer.server_name}/api/v-1/crew/current'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      crewCurrent = resBody;
      dataCategory = crewCurrent!['project_categories'];
    });

    return '1';
  }

  @override
  void initState() {
    print('widget datas');
    print(widget.datas);
    _getLocation().then((position) {
      userLocation = position;
    });
    getCrew();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
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
                          margin: EdgeInsets.only(left: 10),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              l10n.crew_detail1,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 25,
                                  color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(l10n.worker_data,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(widget.datas!['company_name'],
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: HexColor('EA6012'))),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('Emplooy ID:${user!.btn_id!}',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    )),
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
                  child: Text(user!.first_name!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      )),
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
                  child: Text(user!.last_name!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      )),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text('Detalle de chequeo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
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
                    l10n.clockin_26,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
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
                    style: TextStyle(
                        fontSize: 25,
                        color: HexColor('EA6012'),
                        fontWeight: FontWeight.bold),
                  )),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20),
                  child: Image.asset(
                    'assets/verificado.png',
                    width: 28,
                    color: Colors.black,
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    l10n.hour_register + ': ',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
              ],
            ),
            if (crewCurrent != null &&
                crewCurrent!['clock_in_end'] == null) ...[
              Container(
                  margin: EdgeInsets.only(left: 60),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      DateFormat("hh:mm:aa").format(DateTime.parse(
                          crewCurrent!['default_entry_time'].toString())),
                      style: TextStyle(
                          fontSize: 25,
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold),
                    ),
                  ))
            ],
            if (crewCurrent != null &&
                crewCurrent!['clock_in_end'] != null) ...[
              Container(
                  margin: EdgeInsets.only(left: 60),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      DateFormat("hh:mm:aa").format(DateTime.parse(
                          crewCurrent!['default_exit_time'].toString())),
                      style: TextStyle(
                          fontSize: 25,
                          color: HexColor('EA6012'),
                          fontWeight: FontWeight.bold),
                    ),
                  ))
            ],
            Container(
              alignment: Alignment.topRight,
              margin: EdgeInsets.only(right: 30, bottom: 15, top: 40),
              // margin: EdgeInsets.only(left:15),
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        _submit();
                      },
                      child: Text(
                        l10n.accept,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
            ),
          ])))),
    );
  }
}
