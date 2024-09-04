import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../model/user.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'absent.dart';
import 'new22.dart';
import 'new3.dart';

class NewWorkdayReport21 extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  final int? workday;
  final int? report;
  Map<String, dynamic>? contract;
  List<dynamic>? workday_vehicle;

  NewWorkdayReport21(
      {required this.user,
      required this.workday,
      required this.report,
      this.contract,
      this.workday_vehicle});

  @override
  _NewWorkdayReport21State createState() => _NewWorkdayReport21State(
      user, workday, report, contract, workday_vehicle);
}

class _NewWorkdayReport21State extends State<NewWorkdayReport21> {
  User? user;
  int? workday;
  int? report;
  Map<String, dynamic>? contract;
  List<dynamic>? workday_vehicle;

  _NewWorkdayReport21State(this.user, this.workday, this.report, this.contract,
      this.workday_vehicle);

  // ignore: unused_field
  int? _selectedIndex = 4;
  bool? yes_offer = false;
  bool? selec = false;
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
  List? _vehicles;
  //List _workersForDisplay = List();
  List? _driversWork;
  List? _driversWorkers;

  List? _driversWorkInfo = [];
  var image;
  List? imageArray = [];
  bool isLoading = false;
  bool _viewW = false;
  var rows = [];
  List? results = [];
  String? query = '';
  TextEditingController? tc;

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

  Future<dynamic> getSWData() async {
    int? wk = widget.report;
    String token = await getToken();
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/workday-report/$wk/available-vehicles'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(res.body);
    print(res.statusCode);

    setState(() {
      _vehicles = resBody;
    });

    print(_vehicles);

    return _vehicles;
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

  Future<dynamic> getSWData1() async {
    String token = await getToken();
    int contract = await getContract();
    int? wk = widget.workday;
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/$wk/get-clocked-workers'),
        headers: {"Authorization": "Token $token"});
    var resBody = json.decode(res.body);

    setState(() {
      rows = resBody;
    });

    return rows;
  }

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayVehicle(widget.workday, _driversWork, widget.report)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '200') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReport3(
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
          _showErrorDialog(
              'Verifique que los drivers tengan vehículo asignado');
        }
      });
    } catch (error) {}
    /* Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProfilePartOblig2()),
          );*/
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

  void _onWorkerSelected(
      bool selected, worker_id, worker_name, worker_lastname, worker_btnid) {
    if (selected == true) {
      setState(() {
        _driversWorkers!.add(worker_id);
        _driversWorkInfo!.add({
          "worker_id": worker_id,
          "worker_btn": worker_btnid,
          "worker_name": worker_name,
          "worker_lastname": worker_lastname
        });
        print(_driversWorkers);
        print(_driversWorkInfo);
      });
    } else {
      setState(() {
        _driversWorkers!.remove(worker_id);
        _driversWorkInfo!.removeWhere((item) => item['worker_id'] == worker_id);
        print(_driversWorkers);
        print(_driversWorkInfo);
      });
    }
  }

  @override
  void initState() {
    tc = TextEditingController();
    _driversWork = [];
    _driversWorkers = [];

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
    getSWData();
    getSWData1();
    /*getSWData().then((value) {
      setState(() {
        _workers.addAll(value);
        _workersForDisplay = _workers;
      });
    });*/
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
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.03,
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
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Conductores',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                        color: HexColor('EA6012')),
                  ),
                )),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
            Container(
                margin: EdgeInsets.only(left: 30, right: 30),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    l10n.w_driver_list,
                    style: TextStyle(fontSize: 18, color: HexColor('EA6012')),
                  ),
                )),
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
              if (_driversWorkers != null) ...[
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 30),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text(l10n.w_selected,
                            style: TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 5),
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Text('${_driversWorkers!.length}',
                            style: TextStyle(
                                fontSize: 15,
                                color: HexColor('EA6012'),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
              Container(
                // height: 340,
                color: Colors.white,
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          child: TextField(
                            controller: tc,
                            decoration: InputDecoration(
                                hintText: 'Buscar por Nombre o Emplooy ID.',
                                hintStyle: TextStyle(
                                  fontSize: 16,
                                )),
                            onChanged: (v) {
                              setState(() {
                                query = v;
                                setResults(query!);
                              });
                            },
                          ),
                        ),
                        Container(
                          height: 200,
                          margin: EdgeInsets.only(left: 20, right: 20),
                          color: Colors.white,
                          child: query!.isEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: rows.length,
                                  itemBuilder: (con, ind) {
                                    return Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              tc!.text =
                                                  rows[ind]['first_name'];
                                              query = rows[ind]['btn_id'];
                                              setResults(query!);
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                child: Checkbox(
                                                  activeColor:
                                                      HexColor('EA6012'),
                                                  value: _driversWorkers!
                                                      .contains(
                                                          rows[ind]['id']),
                                                  onChanged: (selected) {
                                                    _onWorkerSelected(
                                                        selected!,
                                                        rows[ind]['id'],
                                                        rows[ind]['first_name'],
                                                        rows[ind]['last_name'],
                                                        rows[ind]['btn_id']);
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 2),
                                                child: Text(
                                                  'ID#${rows[ind]['btn_id']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 4),
                                                child: Text(
                                                  '${rows[ind]['first_name']} ${rows[ind]['last_name']}',
                                                  style: TextStyle(
                                                      // fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: results!.length,
                                  itemBuilder: (con, ind) {
                                    return Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              tc!.text =
                                                  results![ind]['first_name'];
                                              query = results![ind]['btn_id'];
                                              setResults(query!);
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                child: Checkbox(
                                                  activeColor:
                                                      HexColor('EA6012'),
                                                  value: _driversWorkers!
                                                      .contains(
                                                          results![ind]['id']),
                                                  onChanged: (selected) {
                                                    _onWorkerSelected(
                                                        selected!,
                                                        results![ind]['id'],
                                                        results![ind]
                                                            ['first_name'],
                                                        results![ind]
                                                            ['last_name'],
                                                        results![ind]
                                                            ['btn_id']);
                                                  },
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 2),
                                                child: Text(
                                                  'ID#${results![ind]['btn_id']}',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      // fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 4),
                                                child: Text(
                                                  '${results![ind]['first_name']} ${results![ind]['last_name']}',
                                                  style: TextStyle(
                                                      // fontWeight: FontWeight.bold,
                                                      fontSize: 16),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.03,
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
                    if (_driversWorkers!.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewWorkdayReport22(
                                  user: user,
                                  workday: widget.workday,
                                  report: widget.report,
                                  contract: widget.contract,
                                  workers_drivers: _driversWorkInfo,
                                )),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AbsentWorkday(
                                  user: user,
                                  workday: widget.workday,
                                  report: widget.report,
                                  contract: widget.contract,
                                )),
                      );
                      /* Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewWorkdayReport3(
                                  user: user,
                                  workday: this.widget.workday,
                                  report: this.widget.report,
                                  contract: this.widget.contract,
                                )),
                      );*/
                    }
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
            ],
            if (selectedRadio1 == 2) ...[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.45,
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AbsentWorkday(
                                      user: user,
                                      workday: widget.workday,
                                      report: widget.report,
                                      contract: widget.contract,
                                    )),
                          );
                          /* Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => NewWorkdayReport3(
                                      user: user,
                                      workday: this.widget.workday,
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
              ),
            ]
          ],
        ),
      )),
    );
  }

  void setResults(String query) {
    results = rows
        .where((elem) =>
            elem['first_name']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['btn_id']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }

  // ignore: unused_element
}
