import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import '../../../model/user.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'base.dart';

class EditWorkdayReport2 extends StatefulWidget {
  static const routeName = '/new-workday';

  Map<String, dynamic> report;
  Map<String, dynamic>? contract;

  EditWorkdayReport2({required this.report, required this.contract});

  @override
  _EditWorkdayReport2State createState() =>
      _EditWorkdayReport2State(report, contract);
}

class _EditWorkdayReport2State extends State<EditWorkdayReport2> {
  Map<String, dynamic> report;
  Map<String, dynamic>? contract;

  _EditWorkdayReport2State(this.report, this.contract);

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
  DateTime? hourClock9; // fin return
  String? durationLunch;
  String? durationStandBy;
  String? durationTravel;
  String? durationReturn;
  String? comments;
  var drivers;
  final _form = GlobalKey<FormState>();
  List data = [];

  String? questions;
  var image;
  List imageArray = [];
  bool isLoading = false;
  var rows = [];
  List results = [];
  String query = '';
  TextEditingController? tc;
  String? entry;
  String? departure;
  DateTime? start_time; // init return
  DateTime? end_time;

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

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Oops, ha ocurrido un Error!'),
        content: Text('Verifica los datos'),
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
    int report = widget.report['id'];
    try {
      Provider.of<WorkDay>(context, listen: false)
          .editWorkdayReport1(hourClock, hourClock1, durationLunch, report)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      contract: widget.contract,
                    )),
          );
        } else {
          setState(() {
            isLoading = false;
          });
          _showErrorDialog();
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
                                builder: (context) => WorkDayPage(
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
                    'Modify lunch time?',
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
                    'Select an option',
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
                  'Yes',
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
              Row(children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Text(
                    'Duration',
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
                        'Minutes:',
                        style:
                            TextStyle(fontSize: 18, color: HexColor('EA6012')),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: DropdownButton<String>(
                        iconEnabledColor: HexColor('EA6012'),
                        value: durationLunch,
                        hint: Text('Select an option'),
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
                            durationLunch = value;
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
                              _showErrorDialog();
                            }
                          },
                          child: const Text(
                            'Submit',
                            style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                ),
              ],
            ],
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
