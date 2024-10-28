import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/workday.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../model/user.dart';
import '../../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'step_2.dart';

class NewCresheet1 extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? location;
  Map<String, dynamic>? crew;

  NewCresheet1(
      {this.user,
      required this.workday,
      this.contract,
      this.location,
      this.crew});

  @override
  _NewCresheet1State createState() =>
      _NewCresheet1State(user, workday, contract, location, crew);
}

class _NewCresheet1State extends State<NewCresheet1> {
  User? user;
  int? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? location;
  Map<String, dynamic>? crew;

  _NewCresheet1State(
      this.user, this.workday, this.contract, this.location, this.crew);

  // ignore: unused_field
  int _selectedIndex = 4;
  bool yes_offer = false;
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
  DateTime? now = DateTime.now(); // fin return
  String? durationLunch;
  String? durationStandBy;
  String? durationTravel;
  String? durationReturn;
  String? comments;
  var drivers;
  final _form = GlobalKey<FormState>();
  List data = [];

  var image;
  List? imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  int _currentStep = 0;
  DateTime? start_time;
  Map<String, dynamic>? dataCrew;
  DateTime? end_time; // fin return
// fin return

  getToken() async {
    SharedPreferences token = await SharedPreferences.getInstance();
    String? stringValue = token.getString('stringValue');
    return stringValue;
  }

  getContract() async {
    SharedPreferences contract = await SharedPreferences.getInstance();
    //Return String
    int? intValue = contract.getInt('intValue');
    return intValue;
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

  void _showErrorDialog1(String message) {
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
    setState(() {
      start_time = DateTime.parse(widget.crew!['clock_in_start'].toString());
      end_time = DateTime.parse(widget.crew!['default_exit_time'].toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse(widget.crew!['clock_in_start']));
      _time1 = DateFormat('hh:mm aa')
          .format(DateTime.parse(widget.crew!['default_exit_time'].toString()));
      hourClock = DateTime.parse(widget.crew!['clock_in_start']);
      hourClock1 = DateTime.parse(widget.crew!['default_exit_time'].toString());
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    DateFormat format = DateFormat("yyyy-MM-dd");
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
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
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
                    l10n.wr_3,
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
                        margin: EdgeInsets.only(left: 20),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.10,
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
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              DateFormat("MMMM d yyyy").format(
                                  DateTime.parse(start_time.toString())),
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              _time!,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(left: 30),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(Icons.calendar_today),
                                color: HexColor('EA6012'),
                                onPressed: () async {
                                  /*  DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2100));
                                  print(pickedDate);
                                  setState(() {
                                    start_time = pickedDate;
                                  });*/
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(Icons.timer),
                                color: HexColor('EA6012'),
                                onPressed: () async {
                                  /*  TimeOfDay? picketTime = await showTimePicker(
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
                                    String formattedTime =
                                        DateFormat('hh:mm aa')
                                            .format(selectedDateTime);
                                    _time = formattedTime;
                                    setState(() {
                                      hourClock = selectedDateTime;
                                    }); // You can use the selectedDateTime as needed.
                                  }*/
                                },
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 20),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.10,
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
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              DateFormat("MMMM d yyyy")
                                  .format(DateTime.parse(end_time.toString())),
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              _time1!,
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topRight,
                        margin: EdgeInsets.only(left: 30),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(Icons.calendar_today),
                                color: HexColor('EA6012'),
                                onPressed: () async {
                                  /*DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(1950),
                                      //DateTime.now() - not to allow to choose before today.
                                      lastDate: DateTime(2100));
                                  print(pickedDate);
                                  setState(() {
                                    end_time = pickedDate;
                                  });*/
                                },
                              ),
                            ),
                            SizedBox(
                              width: 35,
                              child: IconButton(
                                icon: Icon(Icons.timer_off),
                                color: HexColor('EA6012'),
                                onPressed: () async {
                                  /*  TimeOfDay? picketTime = await showTimePicker(
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
                                    String formattedTime =
                                        DateFormat('hh:mm aa')
                                            .format(selectedDateTime);
                                    _time1 = formattedTime;
                                    setState(() {
                                      hourClock1 = selectedDateTime;
                                    }); // You can use the selectedDateTime as needed.
                                  }*/
                                },
                              ),
                            )
                          ],
                        )),
                  )
                ],
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.23,
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
                        onPressed: hourClock != null &&
                                hourClock1 != null &&
                                start_time != null &&
                                end_time != null
                            ? () {
                                if (start_time!.isAfter(end_time!)) {
                                  _showErrorDialog1(
                                      l10n.warning_departure_date);
                                } else if (start_time!
                                        .isAtSameMomentAs(end_time!) &&
                                    hourClock!.isAfter(hourClock1!)) {
                                  _showErrorDialog1(
                                      l10n.warning_departure_hour);
                                } else {
                                  setState(() {
                                    dataCrew = {
                                      "inicio_s": contract!['inicio_s'],
                                      "fin_s": contract!['fin_s'],
                                      "lunch_s": contract!['lunch_s'],
                                      "travel_s": contract!['travel_s'],
                                      "standby_s": contract!['standby_s'],
                                      "inicio": DateTime.parse(start_time
                                              .toString()
                                              .substring(0, 11) +
                                          hourClock
                                              .toString()
                                              .substring(10, 23)
                                              .replaceAll(" ", "")),
                                      "fin": DateTime.parse(
                                          end_time.toString().substring(0, 11) +
                                              hourClock1
                                                  .toString()
                                                  .substring(10, 23)
                                                  .replaceAll(" ", ""))
                                    };
                                  });

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => NewCresheet2(
                                              workday: widget.workday,
                                              location: widget.location,
                                              contract: dataCrew,
                                            )),
                                  );
                                  //_submit();
                                }
                              }
                            : null,
                        child: Text(
                          l10n.next,
                          style: const TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
              ),
            ],
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
