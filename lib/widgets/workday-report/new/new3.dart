import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:provider/provider.dart';

import '../../../model/user.dart';
import '../../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'new4.dart';

class NewWorkdayReport3 extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  final int? workday;
  final int? report;
  Map<String, dynamic>? contract;
  List<dynamic>? workday_vehicle;

  NewWorkdayReport3(
      {required this.user,
      required this.workday,
      required this.report,
      this.contract,
      this.workday_vehicle});

  @override
  _NewWorkdayReport3State createState() =>
      _NewWorkdayReport3State(user, workday, report, contract, workday_vehicle);
}

class _NewWorkdayReport3State extends State<NewWorkdayReport3> {
  User? user;
  int? workday;
  int? report;
  Map<String, dynamic>? contract;
  List<dynamic>? workday_vehicle;

  _NewWorkdayReport3State(this.user, this.workday, this.report, this.contract,
      this.workday_vehicle);

  // ignore: unused_field
  int? _selectedIndex = 4;
  bool? yes_offer = false;
  int? selectedRadio;
  int? selectedRadio1;
  int? selectedRadio2;
  int? selectedRadio3;
  int? selectedRadio4;
  int? selectedRadio5;
  int? selectedRadio6;
  int? selectedRadio7;
  int? selectedRadio8;
  int? selectedRadio9;
  int? selectedRadio10;

  String? _time = "S/H";
  String? _time1 = "S/H";

  DateTime? hourClock; // init workday
  DateTime? hourClock1; // fin workday
  DateTime? hourClock2; // init lunch
  DateTime? hourClock3; // fin lunch
  DateTime? hourClock4; // init standby
  DateTime? hourClock5; // fin standby
  DateTime? hourClock6; // init travel
  DateTime? hourClock7; // fin travel
  DateTime? hourClock8; // init return
  DateTime? hourClock9; // fin return
  String? durationLunch;
  String? durationStandBy;
  String? durationTravel;
  String? durationReturn;
  String? comments;
  var drivers;
  final _form = GlobalKey<FormState>();
  List? data = [];

  var image;
  List imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  int _currentStep = 0;

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  setSelectedRadio1(int val) {
    setState(() {
      selectedRadio1 = val;
    });
  }

  setSelectedRadio2(int val) {
    setState(() {
      selectedRadio2 = val;
    });
  }

  setSelectedRadio3(int val) {
    setState(() {
      selectedRadio3 = val;
    });
  }

  setSelectedRadio4(int val) {
    setState(() {
      selectedRadio4 = val;
    });
  }

  setSelectedRadio5(int val) {
    setState(() {
      selectedRadio5 = val;
    });
  }

  setSelectedRadio6(int val) {
    setState(() {
      selectedRadio6 = val;
    });
  }

  setSelectedRadio7(int val) {
    setState(() {
      selectedRadio7 = val;
    });
  }

  setSelectedRadio8(int val) {
    setState(() {
      selectedRadio8 = val;
    });
  }

  setSelectedRadio9(int val) {
    setState(() {
      selectedRadio9 = val;
    });
  }

  setSelectedRadio10(int val) {
    setState(() {
      selectedRadio10 = val;
    });
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

  Future<dynamic> deleteWV() async {
    print('se fue delete');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .deleteWorkdayVehicle(widget.workday_vehicle)
          .then((response) {});
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayReport3(widget.workday, hourClock, hourClock1,
              durationLunch, widget.report)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReport4(
                      user: user,
                      workday: widget.workday,
                      report: widget.report,
                      contract: widget.contract,
                    )),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog('Verifique los datos.');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  @override
  void initState() {
    tc = TextEditingController();
    selectedRadio = 0;
    selectedRadio1 = 0;
    selectedRadio2 = 0;
    selectedRadio3 = 0;
    selectedRadio4 = 0;
    selectedRadio5 = 0;
    selectedRadio6 = 0;
    selectedRadio7 = 0;
    selectedRadio8 = 0;
    selectedRadio9 = 0;
    selectedRadio10 = 0;

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
        key: _form,
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
                    margin: EdgeInsets.only(left: 20),
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
                          deleteWV();
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
                    margin: EdgeInsets.only(right: 20),
                    width: MediaQuery.of(context).size.width * 0.50,
                    child: Container(
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          color: HexColor('EA6012'),
                        ),
                        onPressed: () {
                          deleteWV();
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Image.asset(
                    'assets/002-data.png',
                    color: HexColor('EA6012'),
                    width: 70,
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.04,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.wr_14,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
                margin: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.select,
                    style: TextStyle(fontSize: 18, color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            Row(children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 30),
                child: Text(
                  l10n.si,
                  style: TextStyle(fontSize: 18, color: HexColor('EA6012')),
                ),
              ),
              Radio(
                value: 1,
                groupValue: selectedRadio1,
                activeColor: HexColor('EA6012'),
                onChanged: (val) {
                  print("sr2 $val");
                  setSelectedRadio1(val!);
                },
              ),
              Container(
                margin: EdgeInsets.only(left: 40),
                child: Text(l10n.no,
                    style: TextStyle(fontSize: 18, color: HexColor('EA6012'))),
              ),
              Radio(
                value: 2,
                groupValue: selectedRadio1,
                activeColor: HexColor('EA6012'),
                onChanged: (val) {
                  print("sr2 $val");
                  setSelectedRadio1(val!);
                },
              ),
            ]),
            if (selectedRadio1 == 1) ...[
              Row(children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    l10n.wr_8,
                    style: TextStyle(fontSize: 18, color: HexColor('EA6012')),
                  ),
                ),
                Radio(
                  value: 1,
                  groupValue: selectedRadio2,
                  activeColor: HexColor('EA6012'),
                  onChanged: (val) {
                    print("sr2 $val");
                    setSelectedRadio2(val!);
                  },
                ),
                Container(
                  margin: EdgeInsets.only(left: 40),
                  child: Text(l10n.wr_9,
                      style:
                          TextStyle(fontSize: 18, color: HexColor('EA6012'))),
                ),
                Radio(
                  value: 2,
                  groupValue: selectedRadio2,
                  activeColor: HexColor('EA6012'),
                  onChanged: (val) {
                    print("sr2 $val");
                    setSelectedRadio2(val!);
                  },
                ),
              ]),
              if (selectedRadio2 == 1) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Text(
                        l10n.wr_10,
                        style:
                            TextStyle(fontSize: 18, color: HexColor('EA6012')),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: DropdownButton<String>(
                        iconEnabledColor: HexColor('EA6012'),
                        value: durationLunch,
                        hint: Text(l10n.select),
                        items: <String>[
                          '0',
                          '5',
                          '10',
                          '15',
                          '30',
                          '45',
                          '60',
                          '75',
                          '90',
                          '120'
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: new Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            durationLunch = value!;
                          });
                          print(durationLunch);
                        },
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.18,
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(HexColor('EA6012')),
                          ),
                          onPressed: () {
                            if (durationLunch != null) {
                              _submit();
                            } else {
                              _showErrorDialog(l10n.required_data);
                            }
                          },
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
              if (selectedRadio2 == 2) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                          //color: HexColor('009444'),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 30),
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'assets/entrada.png',
                                width: 40,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  l10n.wr_4,
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: Text(
                          _time!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(right: 20),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: IconButton(
                          icon: Icon(Icons.timer),
                          color: HexColor('EA6012'),
                          onPressed: () async {
                            TimeOfDay? picketTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );

                            if (picketTime != null) {
                              DateTime selectedDateTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                picketTime.hour,
                                picketTime.minute,
                              );
                              String formattedTime = DateFormat('hh:mm aa')
                                  .format(selectedDateTime);
                              _time = formattedTime;
                              setState(() {
                                hourClock = selectedDateTime;
                              }); // You can use the selectedDateTime as needed.
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: Container(
                          //color: HexColor('009444'),
                          alignment: Alignment.topLeft,
                          margin: EdgeInsets.only(left: 30),
                          //height: MediaQuery.of(context).size.width * 0.1,
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Row(
                            children: <Widget>[
                              Image.asset(
                                'assets/salida.png',
                                width: 40,
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 5, top: 5),
                                child: Text(
                                  l10n.wr_5,
                                  style: TextStyle(fontSize: 16),
                                ),
                              )
                            ],
                          )),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.center,
                        margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: Text(
                          _time1!,
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(right: 20),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.30,
                        child: IconButton(
                          icon: Icon(Icons.timer_off),
                          color: HexColor('EA6012'),
                          onPressed: () async {
                            TimeOfDay? picketTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );

                            if (picketTime != null) {
                              DateTime selectedDateTime = DateTime(
                                DateTime.now().year,
                                DateTime.now().month,
                                DateTime.now().day,
                                picketTime.hour,
                                picketTime.minute,
                              );
                              String formattedTime = DateFormat('hh:mm aa')
                                  .format(selectedDateTime);
                              _time1 = formattedTime;
                              setState(() {
                                hourClock1 = selectedDateTime;
                              }); // You can use the selectedDateTime as needed.
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.03,
                ),
                Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.only(right: 30),
                  //width: MediaQuery.of(context).size.width * 0.70,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(HexColor('EA6012')),
                          ),
                          onPressed: hourClock != null && hourClock1 != null
                              ? () {
                                  _submit();
                                  /* if (hourClock.isAfter(hourClock1)) {
                                    _showErrorDialog(
                                        'Hora inicio no puede ser menor que fin.');
                                  } else {
                                    _submit();
                                  }*/
                                }
                              : null,
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
            ],
            if (selectedRadio1 == 2) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.30,
              ),
              Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(right: 30),
                //width: MediaQuery.of(context).size.width * 0.70,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(HexColor('EA6012')),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => NewWorkdayReport4(
                                user: user,
                                workday: widget.workday,
                                report: widget.report,
                                contract: widget.contract,
                              )),
                    );
                  },
                  child: Text(
                    l10n.continues,
                    style: TextStyle(
                        // fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white),
                  ),
                ),
              ),
            ]
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
