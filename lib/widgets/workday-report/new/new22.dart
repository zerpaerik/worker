import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worker/providers/workday.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../../../model/user.dart';
import '../../global.dart';
import '../../widgets.dart';
import 'new3.dart';

class NewWorkdayReport22 extends StatefulWidget {
  static const routeName = '/new-workday';
  final User? user;
  final int? workday;
  final int? report;
  Map<String, dynamic>? contract;
  List<dynamic>? workers_drivers;

  NewWorkdayReport22(
      {required this.user,
      required this.workday,
      required this.report,
      this.contract,
      this.workers_drivers});

  @override
  _NewWorkdayReport22State createState() => _NewWorkdayReport22State(
      user, workday, report, contract, workers_drivers);
}

class _NewWorkdayReport22State extends State<NewWorkdayReport22> {
  User? user;
  int? workday;
  int? report;
  Map<String, dynamic>? contract;
  List<dynamic>? workers_drivers;

  _NewWorkdayReport22State(this.user, this.workday, this.report, this.contract,
      this.workers_drivers);

  // ignore: unused_field
  int? _selectedIndex = 4;
  var selectedValue;
  int? vehicle;
  bool selec = false;
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
  List data = [];
  List? _vehicles;
  //List _workersForDisplay = List();

  List _driversWorkInfo = [];
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

  Future<void> _submit() async {
    setState(() {
      isLoading = true;
    });
    print('se fue');
    try {
      Provider.of<WorkDay>(context, listen: false)
          .addWorkdayVehicleWorkers(
              widget.workday, _driversWorkInfo, widget.report)
          .then((response) {
        setState(() {
          isLoading = false;
        });
        if (response['status'] == '201') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => NewWorkdayReport3(
                      user: user,
                      workday: widget.workday,
                      report: widget.report,
                      contract: widget.contract,
                      workday_vehicle: response['data'],
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

  void _onWorkerSelected(vehicle, worker_id) {
    int existe =
        _driversWorkInfo.indexWhere((item) => item['worker_id'] == worker_id);
    if (existe == -1) {
      print('no existe');
      setState(() {
        _driversWorkInfo.add({"worker_id": worker_id, "vehicle": vehicle});
      });
    } else {
      print('existe');

      setState(() {
        print(_driversWorkInfo);
      });
    }

    /* if (_driversWorkInfo.contains(worker_id)) {
      print('ya esta en la lista');
    } else {
      setState(() {
        _driversWorkInfo.add({"worker_id": worker_id, "vehicle": vehicle});
      });
    }*/

    print(_driversWorkInfo);
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
    getSWData();
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
                    l10n.w_vehicle_assigned,
                    style: TextStyle(fontSize: 18, color: HexColor('EA6012')),
                  ),
                )),
            Container(
              height: MediaQuery.of(context).size.height * 0.40,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.workers_drivers!.length,
                itemBuilder: (con, ind) {
                  return Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: Row(
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.only(left: 30),
                              child: Text(
                                'ID#${widget.workers_drivers![ind]['worker_btn']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(left: 4),
                              child: Text(
                                '${widget.workers_drivers![ind]['worker_lastname']} ${widget.workers_drivers![ind]['worker_name']}',
                                style: TextStyle(
                                    // fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.01,
                      ),
                      Container(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Vehículos Disponibles.',
                              style: TextStyle(
                                fontSize: 18,
                              ),
                            ),
                          )),
                      if (_vehicles != null) ...[
                        Container(
                          margin: EdgeInsets.only(left: 30, right: 30),
                          child: FormField(
                            builder: (state) {
                              return DropdownButton(
                                isExpanded: true,
                                iconEnabledColor: HexColor('EA6012'),
                                hint: Text(
                                  l10n.select_one_option,
                                  style: TextStyle(color: HexColor('EA6012')),
                                ),
                                items: _vehicles!.map((item) {
                                  return DropdownMenuItem(
                                    child: Text(
                                      item['brand'] +
                                          ' ' +
                                          item['license_plate'],
                                    ),
                                    value: item,
                                  );
                                }).toList(),
                                value: selectedValue,
                                onChanged: (value) => setState(() {
                                  selectedValue = value;
                                  vehicle = 0;
                                  state.didChange(value);
                                  _onWorkerSelected(
                                      vehicle,
                                      widget.workers_drivers![ind]
                                          ['worker_id']);
                                }),
                              );
                            },
                          ),
                        )
                      ]
                    ],
                  );
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.02,
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
                      onPressed: _submit,
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
            elem['btn_id']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();
  }

  // ignore: unused_element
}
