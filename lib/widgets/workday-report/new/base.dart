// ignore_for_file: deprecated_member_use

import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/model/workday.dart';
import 'package:worker/providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:worker/widgets/workday-report/new/new2cj.dart';

import '../../../local/database_creator.dart';
import '../../../model/user.dart';
import '../../widgets.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../base.dart';
import 'new1.dart';

class NewWorkdayReportBase extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  final Workday? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? workday_on;

  NewWorkdayReportBase(
      {this.user, @required this.workday, this.contract, this.workday_on});

  @override
  _NewWorkdayReportBaseState createState() =>
      _NewWorkdayReportBaseState(user, workday, contract, workday_on);
}

class _NewWorkdayReportBaseState extends State<NewWorkdayReportBase> {
  User? user;
  Workday? workday;
  Map<String, dynamic>? contract;
  Map<String, dynamic>? workday_on;

  _NewWorkdayReportBaseState(
      this.user, this.workday, this.contract, this.workday_on);

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
  bool isWorkday = false;

  String? questions;
  var image;
  List? imageArray = [];
  bool isLoading = false;
  bool? _viewW = false;
  var rows = [];
  List? results = [];
  String? query = '';
  TextEditingController? tc;
  int? _currentStep = 0;
  DateTime? start_time;
  DateTime? end_time; // fin return
  Workday? _wd;
  String _time = '';
  String _time1 = '';

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

  void _showErrorDialog() {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.error),
        content: Text(l10n.verify_data),
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

  void _showErrorDialog1(title) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.error),
        content: Text(title),
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
    print(widget.workday!.id);
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayReportBase(
              _wd!.id, hourClock, hourClock1, start_time, end_time)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReport1(
                      user: user,
                      workday: _wd!.id,
                      report: response['report'],
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

  Future<void> _submit1() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    print(questions);
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayReportNO(
        widget.workday,
        questions,
      )
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => WorkDayPage(
                      user: user,
                      workday: _wd!.id,
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

  Future<void> _submitSJ() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    print(questions);
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayReportNOJ(
        widget.workday,
      )
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReportCJ(
                      user: user,
                      workday: _wd!.id,
                      contract: widget.contract,
                      report: response['report'],
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

  getWorkdayOn(int id) async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable6}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await db.rawQuery(sql, params);

    final todo = data.first;
    setState(() {
      workday_on = todo;
    });
    print(workday_on);
    return workday_on;
  }

  void _viewWorkDay() async {
    Provider.of<WorkDay>(context, listen: false).fetchWorkDay().then((value) {
      setState(() {
        _wd = value;
        isWorkday = true;
      });
      getWorkdayOn(1);
    });
  }

  @override
  void initState() {
    _viewWorkDay();
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
      start_time =
          DateTime.parse(widget.workday_on!['clock_in_init'].toString());
      end_time = DateTime.parse(widget.workday_on!['default_exit'].toString());
      _time = DateFormat('hh:mm aa')
          .format(DateTime.parse(widget.workday_on!['clock_in_init']));
      _time1 = DateFormat('hh:mm aa')
          .format(DateTime.parse(widget.workday_on!['default_exit']));
      hourClock = DateTime.parse(widget.workday_on!['clock_in_init']);
      hourClock1 = DateTime.parse(widget.workday_on!['default_exit']);
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DateFormat format = DateFormat("yyyy-MM-dd");
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
                    flex: 1,
                    child: Container(
                        //color: HexColor('009444'),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(left: 20),
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
                        alignment: Alignment.topLeft,
                        width: MediaQuery.of(context).size.width * 0.50,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              DateFormat("MMMM d yyyy").format(DateTime.parse(
                                  widget.workday_on!['clock_in_init']
                                      .toString())),
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              DateFormat('hh:mm:aa').format(DateTime.parse(
                                  workday_on!['clock_in_init'].toString())),
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )),
                  ),
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
                        //  margin: EdgeInsets.only(left: 10),
                        //height: MediaQuery.of(context).size.width * 0.1,
                        width: MediaQuery.of(context).size.width * 0.40,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              DateFormat("MMMM d yyyy").format(DateTime.parse(
                                  widget.workday_on!['default_exit']
                                      .toString())),
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              DateFormat('hh:mm:aa').format(DateTime.parse(
                                  workday_on!['default_exit'].toString())),
                              style: TextStyle(fontSize: 16),
                            ),
                            /*  Text(
                              _time1,
                              style: GoogleFonts.montserrat(
                                  textStyle: TextStyle(fontSize: 16)),
                            ),*/
                          ],
                        )),
                  ),
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
                    : isWorkday
                        ? ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(HexColor('EA6012')),
                            ),
                            onPressed: () {
                              _submit();
                              /* if (start_time.isAfter(end_time)) {
                            _showErrorDialog1(AppTranslations.of(context)
                                .text("warning_departure_date"));
                          } else if (start_time.isAtSameMomentAs(end_time) &&
                              hourClock.isAfter(hourClock1)) {
                            _showErrorDialog1(AppTranslations.of(context)
                                .text("warning_departure_hour"));
                          } else {
                            _submit();
                          }*/
                            },
                            child: Text(
                              l10n.next,
                              style: TextStyle(
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.white),
                            ),
                          )
                        : Text(''),
              ),
            ],
            if (selectedRadio1 == 2) ...[
              Container(
                  margin: EdgeInsets.only(left: 30),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      l10n.wr_6,
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
                    l10n.finish,
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
                  child: Text(l10n.next,
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              if (selectedRadio2 == 1) ...[
                Container(
                    margin: EdgeInsets.only(left: 30, right: 30),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Motivo:',
                        style:
                            TextStyle(fontSize: 18, color: HexColor('EA6012')),
                      ),
                    )),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Container(
                  margin: EdgeInsets.only(left: 30, right: 30),
                  child: TextField(
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration:
                        InputDecoration(labelText: 'Describe el motivo...'),
                    onChanged: (value) {
                      setState(() {
                        questions = value;
                      });
                    },
                  ),
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
                          onPressed: _submit1,
                          child: Text(
                            'Finalizar',
                            style: TextStyle(
                                // fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.white),
                          ),
                        ),
                )
              ],
              if (selectedRadio2 == 2) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.20,
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
                          onPressed: _submitSJ,
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
          ],
        ),
      )),
    );
  }

  // ignore: unused_element
}
