import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/workday_register.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:worker/widgets/workday-report/new/new2cj.dart';

import '../../../model/user.dart';
import '../../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../detail.dart';
import 'lunch.dart';

class EditWorkdayInd4 extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  final int? workday;
  Map<String, dynamic>? contract;
  final WorkdayRegister? wr;
  Map<String, dynamic>? report;

  EditWorkdayInd4(
      {this.user, @required this.workday, this.contract, this.wr, this.report});

  @override
  _EditWorkdayInd4State createState() =>
      _EditWorkdayInd4State(user, workday, contract, wr, report);
}

class _EditWorkdayInd4State extends State<EditWorkdayInd4> {
  User? user;
  int? workday;
  Map<String, dynamic>? contract;
  WorkdayRegister? wr;
  Map<String, dynamic>? report;
  _EditWorkdayInd4State(
      this.user, this.workday, this.contract, this.wr, this.report);

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

  String? questions;
  var image;
  List? imageArray = [];
  bool isLoading = false;
  bool? _viewW = false;
  var rows = [];
  List? results = [];
  String? query = '';
  TextEditingController? tc;
  int _currentStep = 0;

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

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text('Verify data'),
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

  void _showErrorDialog1() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Error'),
        content: Text('Time'),
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
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayReportTravel(
              widget.workday, hourClock, hourClock1, widget.wr)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailWorkDay(
                      user: user,
                      workday: widget.workday,
                      //wr: this.widget.wr,
                      report: widget.report,
                      contract: widget.contract,
                    )),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog();
          //_showErrorDialog('Verifique la información');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
  }

  Future<void> _submitReview() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayReportVerified(widget.workday, widget.wr)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DetailWorkDay(
                      user: user,
                      workday: widget.workday,
                      //wr: this.widget.wr,
                      report: widget.report,
                      contract: widget.contract,
                    )),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog();
          //_showErrorDialog('Verifique la información');
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => DetailWorkDay(
                                      user: user,
                                      workday: widget.workday,
                                      //wr: this.widget.wr,
                                      report: widget.report,
                                      contract: widget.contract,
                                    )),
                          );
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
                    l10n.want_to_modify_time,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: HexColor('EA6012')),
                  ),
                )),
            Container(
                margin: EdgeInsets.only(left: 28, top: 5),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    ' ${widget.wr!.first_name} ${widget.wr!.last_name}',
                    style: TextStyle(
                        //fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
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
                    l10n.select_one_option,
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
                child: Text('No',
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
                                l10n.start_inicio,
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
                        _time != 'S/H'
                            ? _time!
                            : widget.wr!.travel_start_time != null
                                ? DateFormat('hh:mm:aa')
                                    .format(widget.wr!.travel_start_time)
                                : 'S/H',
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
                            String formattedTime =
                                DateFormat('hh:mm aa').format(selectedDateTime);
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
                                l10n.end_fin,
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
                        _time1 != 'S/H'
                            ? _time1!
                            : widget.wr!.travel_end_time != null
                                ? DateFormat('hh:mm:aa')
                                    .format(widget.wr!.travel_end_time)
                                : 'S/H',
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
                            String formattedTime =
                                DateFormat('hh:mm aa').format(selectedDateTime);
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
                height: MediaQuery.of(context).size.height * 0.15,
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
                                if (hourClock!.isAfter(hourClock1!)) {
                                  _showErrorDialog1();
                                } else {
                                  _submit();
                                }
                              }
                            : null,
                        child: Text(
                          l10n.continues,
                          style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
              ),
            ],
            if (selectedRadio1 == 2) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.15,
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
                          _submitReview();
                          /*  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DetailWorkDay(
                                user: user,
                                workday: this.widget.workday,
                                //wr: this.widget.wr,
                                report: this.widget.report,
                                contract: this.widget.contract,
                              )),
                    );*/
                        },
                        child: Text(
                          l10n.continues,
                          style: TextStyle(
                              // fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white),
                        ),
                      ),
              )
            ],
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
