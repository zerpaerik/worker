import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/workday.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';

import '../../../model/user.dart';
import '../../../providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'absent.dart';

// ignore: must_be_immutable
class EditAbsent extends StatefulWidget {
  final Map<String, dynamic>? user;
  final int? workday;
  final int? report;
  Map<String, dynamic>? contract;

  EditAbsent({@required this.user, this.workday, this.report, this.contract});

  @override
  _EditAbsentState createState() =>
      _EditAbsentState(user, workday, report, contract);
}

class _EditAbsentState extends State<EditAbsent> {
  final GlobalKey<FormState> _formKey = GlobalKey();

  Map<String, dynamic>? user;
  int? workday;
  int? report;

  Map<String, dynamic>? contract;

  _EditAbsentState(this.user, this.workday, this.report, this.contract);
  Geolocator geolocator = Geolocator();

  Position? userLocation;
  Workday? _wd;
  //DateFormat format = DateFormat("yyyy-MM-dd");
  bool isLoading = false;
  // DateTime hour = DateFormat('HH:mm').format(DateTime.now()) as DateTime;
  final hour = new DateTime.now();
  DateFormat? dateFormat = DateFormat("HH:mm:ss");
  String? _time = "S/H";
  DateTime? hourClock;
  String? qrCodeResult = "Not Yet Scanned";
  String? temp = '';
  int? tm;
  String? blood = '';

  String? _locationMessage = "";
  String? comments;

  // String formatter = DateFormat('yMd').format(hour);
  //int time = DateTime.now().millisecondsSinceEpoch;
  //String t = "$time";

  todayDateTime() {
    var now = new DateTime.now();
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
    int? intValue = contract.getInt('intValue');
    return intValue;
  }

  void _showErrorDialog(String message) {
    print(message);
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

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });

    try {
      Provider.of<WorkDay>(context, listen: false)
          .editAdsentWorkday(widget.user!['register_id'], comments, blood)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response == '200') {
          //_scan();
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AbsentWorkday(
                    // user: user,
                    workday: widget.workday,
                    contract: widget.contract,
                    report: widget.report)),
          );
        } else {
          _showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
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
                    '${"Foto de" + ' ' + user!['first_name']} ' +
                        user!['last_name'],
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
                        image: user!['profile_image']
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

  @override
  void initState() {
    super.initState();
    _getLocation().then((position) {
      userLocation = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    List _listDocI = [
      'Ausente con permiso de trabajo',
      'Ausente por enfermedad',
      'Ausente por accidente',
      'Abandono del trabajo',
      'Ausente sin justificación',
      'No lo se'
    ];

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
                              'Registro de Ausencia',
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
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Container(
              margin: EdgeInsets.only(left: 20),
              child: Align(
                alignment: Alignment.topLeft,
                child: Text(widget.contract!['contract_name'],
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
                child: Text('BTN',
                    style: TextStyle(
                      fontSize: 17,
                    )),
              ),
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
                child: Text('Emplooy ID:' + user!['btn_id'],
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
                  child: Text(user!['first_name'],
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
                  child: Text(user!['last_name'],
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
                child: Text('Datos de Ausencia',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: HexColor('EA6012'))),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
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
                    l10n.clockout_22,
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
              margin: EdgeInsets.only(
                left: 60,
                right: 30,
              ),
              child: FormField(
                builder: (state) {
                  return DropdownButton(
                    isExpanded: true,
                    iconEnabledColor: HexColor('EA6012'),
                    hint: Text(
                      'Seleccione',
                    ),
                    underline: Container(
                      height: 1,
                      color: Colors.grey,
                    ),
                    items: _listDocI.map((value) {
                      return DropdownMenuItem(
                        child: Text(
                          value,
                        ),
                        value: value,
                      );
                    }).toList(),
                    value: blood!.isNotEmpty ? blood : null,
                    onChanged: (value) {
                      setState(() {
                        blood = value.toString();
                        print(blood);

                        //state.didChange(value);
                      });
                    },
                  );
                },
              ),
            ),
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
                    'Comentarios',
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
              margin: EdgeInsets.only(left: 60, right: 30),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                autocorrect: true,
                enableSuggestions: true,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: const InputDecoration(labelText: 'Descripción...'),
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
                  : ElevatedButton(
                      onPressed: () {
                        if (blood == '') {
                          _showErrorDialog(l10n.specify_reason_departure);
                        } else {
                          _submit();
                        }
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
