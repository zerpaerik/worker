import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:worker/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:worker/widgets/workday-report/new/edit_absent.dart';
import 'package:worker/widgets/workday-report/new/new2sj.dart';

import '../../../model/user.dart';
import '../../global.dart';
import '../../widgets.dart';

class NewWorkdayReportSJ1 extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  Map<String, dynamic>? report;
  Map<String, dynamic>? contract;

  NewWorkdayReportSJ1({this.user, @required this.report, this.contract});

  @override
  _NewWorkdayReportSJ1State createState() =>
      _NewWorkdayReportSJ1State(user, report, contract);
}

class _NewWorkdayReportSJ1State extends State<NewWorkdayReportSJ1> {
  User? user;
  Map<String, dynamic>? report;
  Map<String, dynamic>? contract;

  _NewWorkdayReportSJ1State(this.user, this.report, this.contract);

  // ignore: unused_field
  int _selectedIndex = 4;
  bool yes_offer = false;
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
  //List _workersForDisplay = List();
  List? _driversWorkers;

  List? _driversWorkInfo = [];
  var image;
  List? imageArray = [];
  bool? isLoading = false;
  bool? _viewW = false;
  var rows = [];
  List? results = [];
  String? query = '';
  TextEditingController? tc;
  int _currentStep = 0;
  String isData = '';

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
    int wk = widget.report!['id'];
    String token = await getToken();
    var res = await http.get(
        Uri.parse(
            '${ApiWebServer.server_name}/api/v-1/workday/workday-report/$wk/worker-report/'),
        headers: {"Authorization": "Token $token"});

    var resBody = json.decode(res.body);
    print(res.statusCode);

    /*setState(() {
      rows = resBody;
    });*/
    if (res.statusCode == 200) {
      setState(() {
        rows = resBody;
        if (rows.isNotEmpty) {
          isData = 'Y';
        } else {
          isData = 'N';
        }
      });
    }

    print(rows);

    return rows;
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

  void _showWorker(data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        contentPadding: EdgeInsets.only(top: 10.0),
        content: Container(
          height: 200,
          width: 340,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    "Datos de Ausencia",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 15),
                    child: Text('Motivo: ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: Colors.black)),
                  ),
                  Container(
                    // margin: EdgeInsets.only(left: 10),
                    child: Text(
                      data['worker_status'] == '2'
                          ? 'Ausente por Enfermedad'
                          : data['worker_status'] == '3'
                              ? 'Ausente por accidente'
                              : data['worker_status'] == '4'
                                  ? 'Abandono del Trabajo'
                                  : data['worker_status'] == '5'
                                      ? 'Ausente sin justificación'
                                      : data['worker_status'] == '6'
                                          ? 'Ausente con permiso de trabajo'
                                          : 'No lo sé',
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  margin: EdgeInsets.only(left: 15),
                  height: 20,
                  child: ListView(
                    children: <Widget>[
                      Text(
                        data['absence_excuse'],
                        style: TextStyle(fontSize: 17, color: Colors.black),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  )),
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

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayReportSJ()
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '200') {
          /*  Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReport3(
                      user: user,
                      workday: this.widget.workday,
                      report: this.widget.report,
                      contract: this.widget.contract,
                    )),
          );*/
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
                          // deleteWV();
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
                          Icons.check,
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
            Row(
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 30),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Image.asset(
                        'assets/ausente.png',
                        color: HexColor('EA6012'),
                        width: 45,
                      ),
                    )),
                Column(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            '${l10n.select_the_str}\n${l10n.w_present}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: HexColor('EA6012')),
                          ),
                        )),
                  ],
                ),

                /* Container(
                    margin: EdgeInsets.only(
                      left: 5,
                      right: 20,
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Chequee a los',
                        style: GoogleFonts.montserrat(
                            textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                color: HexColor('EA6012'))),
                      ),
                    ))*/
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.01,
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
            ),
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
                      isData == ''
                          ? Center(
                              child: CircularProgressIndicator(),
                            )
                          : isData == 'Y'
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.45,
                                  margin: EdgeInsets.only(left: 15, right: 20),
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
                                                    if (rows[ind]
                                                            ['worker_status'] ==
                                                        '1') {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    EditAbsent(
                                                                      user: rows[
                                                                          ind],
                                                                      contract:
                                                                          widget
                                                                              .contract,
                                                                      report: widget
                                                                              .report![
                                                                          'id'],
                                                                    )),
                                                      );
                                                    } else {
                                                      // _showWorker(rows[ind]);
                                                    }
                                                    /* setState(() {
                                            tc.text = rows[ind]['first_name'];
                                            query = rows[ind]['btn_id'];
                                            setResults(query);
                                          });*/
                                                    print('estoy tocando');
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 30,
                                                        child: Container(
                                                          child: Checkbox(
                                                            activeColor:
                                                                HexColor(
                                                                    'EA6012'),
                                                            value: _driversWorkers!
                                                                .contains(
                                                                    rows[ind]
                                                                        ['id']),
                                                            onChanged:
                                                                (selected) {
                                                              _onWorkerSelected(
                                                                  selected!,
                                                                  rows[ind]
                                                                      ['id'],
                                                                  rows[ind][
                                                                      'first_name'],
                                                                  rows[ind][
                                                                      'last_name'],
                                                                  rows[ind][
                                                                      'btn_id']);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 2),
                                                        child: Text(
                                                          'ID#${rows[ind]['btn_id']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey,
                                                              // fontWeight: FontWeight.bold,
                                                              fontSize: 18),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 4),
                                                        child: Text(
                                                          '${rows[ind]['last_name']}, ${rows[ind]['first_name']}',
                                                          style: TextStyle(
                                                              // fontWeight: FontWeight.bold,
                                                              fontSize: 18),
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
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              EditAbsent(
                                                                user: results![
                                                                    ind],
                                                                contract: widget
                                                                    .contract,
                                                                report: widget
                                                                        .report![
                                                                    'id'],
                                                              )),
                                                    );
                                                    /* setState(() {
                                            tc.text =
                                                results[ind]['first_name'];
                                            query = results[ind]['btn_id'];
                                            setResults(query);
                                          });*/
                                                  },
                                                  child: Row(
                                                    children: <Widget>[
                                                      SizedBox(
                                                        height: 15,
                                                        child: Container(
                                                          child: Checkbox(
                                                            activeColor:
                                                                HexColor(
                                                                    'EA6012'),
                                                            value: _driversWorkers!
                                                                .contains(
                                                                    results![
                                                                            ind]
                                                                        ['id']),
                                                            onChanged:
                                                                (selected) {
                                                              _onWorkerSelected(
                                                                  selected!,
                                                                  results![ind]
                                                                      ['id'],
                                                                  results![ind][
                                                                      'first_name'],
                                                                  results![ind][
                                                                      'last_name'],
                                                                  results![ind][
                                                                      'btn_id']);
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 10),
                                                        child: Icon(
                                                          Icons.cancel,
                                                          color: results![ind][
                                                                      'worker_status'] !=
                                                                  '1'
                                                              ? Colors.green
                                                              : Colors.red,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 2),
                                                        child: Text(
                                                          'ID#${results![ind]['btn_id']}',
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.grey,
                                                              // fontWeight: FontWeight.bold,
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(
                                                            left: 4),
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
                                )
                              : Center(
                                  child: Text(l10n.clockout_18),
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewWorkdayReportSJ2(
                              user: user,
                              report: widget.report,
                              contract: widget.contract,
                              workers: _driversWorkers,
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
            elem['last_name']
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
